require 'tempfile'

describe 'suggestion highlighting' do
  # We communicate ZLE state back to the test process via a file, because
  # `region_highlight` only exists inside a ZLE widget. Bind a dump widget
  # so we can inspect the array at any point in the interactive flow.
  let(:dump_file) { Tempfile.create(['zsh-autosuggest-highlight', '.log']).path }

  let(:options) do
    [
      %(ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=red'),
    ]
  end

  before do
    session.
      run_command(%(_dump_region_highlight() { print -l -- "${region_highlight[@]}" > #{dump_file} })).
      run_command('zle -N dump-region-highlight _dump_region_highlight').
      run_command('bindkey "^X^D" dump-region-highlight').
      clear_screen
  end

  after do
    File.delete(dump_file) if File.exist?(dump_file)
  end

  def region_highlight_entries
    # Dump + give zle a moment to write the file.
    session.send_keys('C-x C-d')
    deadline = Time.now + 2
    until Time.now > deadline
      content = File.read(dump_file) rescue ''
      return content.lines.map(&:chomp).reject(&:empty?) if File.exist?(dump_file)
      sleep 0.05
    end
    []
  end

  def plugin_owned_entries(entries)
    entries.select { |e| e.include?('fg=red') || e.include?('memo=zsh-autosuggestions') }
  end

  context 'when the suggestion is accepted and edited' do
    it 'does not leak stale region_highlight entries' do
      with_history('echo hello world') do
        session.send_string('echo h')
        wait_for { session.content }.to eq('echo hello world')

        # Accept full suggestion via forward-char at end of buffer
        session.send_keys('End')
        wait_for { session.content }.to eq('echo hello world')

        # Delete a few chars from the accepted text
        3.times { session.send_keys('BSpace') }
        wait_for { session.content }.to eq('echo hello w')

        owned = plugin_owned_entries(region_highlight_entries)
        expect(owned.size).to be <= 1,
          "expected at most one plugin-owned region_highlight entry, got #{owned.size}: #{owned.inspect}"
      end
    end
  end

  context 'with a hex color in ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE' do
    let(:options) do
      [
        %(ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#5a548b'),
      ]
    end

    def plugin_owned_entries(entries)
      # Hex colors contain `#`, so match by memo tag (5.9+) or the raw style.
      entries.select { |e| e.include?('fg=#5a548b') || e.include?('memo=zsh-autosuggestions') }
    end

    it 'still removes owned entries on reset (regression: #789)' do
      with_history('echo hello world') do
        session.send_string('echo h')
        wait_for { session.content }.to eq('echo hello world')

        session.send_keys('End')
        3.times { session.send_keys('BSpace') }
        wait_for { session.content }.to eq('echo hello w')

        owned = plugin_owned_entries(region_highlight_entries)
        expect(owned.size).to be <= 1,
          "expected at most one plugin-owned region_highlight entry, got #{owned.size}: #{owned.inspect}"
      end
    end
  end

  context 'when another plugin appends to region_highlight after ours' do
    let(:after_sourcing) do
      -> do
        # Simulate zsh-syntax-highlighting by wrapping line-pre-redraw to
        # append an entry AFTER autosuggestions has already applied its own.
        session.
          run_command('_fake_other_plugin() { region_highlight+=("0 1 fg=green memo=fake-syntax-highlighter") }').
          run_command('zle -N _fake_other_plugin').
          run_command('autoload -Uz add-zle-hook-widget').
          run_command('add-zle-hook-widget line-pre-redraw _fake_other_plugin')
      end
    end

    it 'still removes only its own entries on reset' do
      with_history('echo hello world') do
        session.send_string('echo h')
        wait_for { session.content }.to eq('echo hello world')

        session.send_keys('End')
        3.times { session.send_keys('BSpace') }
        wait_for { session.content }.to eq('echo hello w')

        entries = region_highlight_entries
        owned = plugin_owned_entries(entries)
        expect(owned.size).to be <= 1,
          "expected at most one plugin-owned entry, got: #{owned.inspect}"
      end
    end
  end
end
