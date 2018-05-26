context 'with asynchronous suggestions enabled' do
  before do
    skip 'Async mode not supported below v5.0.8' if session.zsh_version < Gem::Version.new('5.0.8')
  end

  let(:options) { ["ZSH_AUTOSUGGEST_USE_ASYNC="] }

  describe '`up-line-or-beginning-search`' do
    let(:before_sourcing) do
      -> do
        session.
          run_command('autoload -U up-line-or-beginning-search').
          run_command('zle -N up-line-or-beginning-search').
          send_string('bindkey "').
          send_keys('C-v').send_keys('up').
          send_string('" up-line-or-beginning-search').
          send_keys('enter')
      end
    end

    it 'should show previous history entries' do
      with_history(
        'echo foo',
        'echo bar',
        'echo baz'
      ) do
        session.clear_screen
        3.times { session.send_keys('up') }
        wait_for { session.content }.to eq("echo foo")
      end
    end
  end

  it 'should not add extra carriage returns before newlines' do
    session.
      send_string('echo "').
      send_keys('escape').
      send_keys('enter').
      send_string('"').
      send_keys('enter')

    session.clear_screen

    session.send_string('echo')
    wait_for { session.content }.to eq("echo \"\n\"")
  end

  it 'should treat carriage returns and newlines as separate characters' do
    session.
      send_string('echo "').
      send_keys('C-v').
      send_keys('enter').
      send_string('foo"').
      send_keys('enter')

    session.
      send_string('echo "').
      send_keys('control').
      send_keys('enter').
      send_string('bar"').
      send_keys('enter')

    session.clear_screen

    session.
      send_string('echo "').
      send_keys('C-v').
      send_keys('enter')

    wait_for { session.content }.to eq('echo "^Mfoo"')
  end

  describe 'exiting a subshell' do
    it 'should not cause error messages to be printed' do
      session.run_command('$(exit)')

      sleep 1

      expect(session.content).to eq('$(exit)')
    end
  end
end


