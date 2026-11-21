describe 'a wrapped widget' do
  let(:widget) { 'backward-delete-char' }

  context 'initialized before sourcing the plugin' do
    let(:before_sourcing) do
      -> do
        session.
          run_command("_orig_#{widget}() { zle .#{widget} }").
          run_command("zle -N orig-#{widget} _orig_#{widget}").
          run_command("#{widget}-magic() { zle orig-#{widget}; BUFFER+=b }").
          run_command("zle -N #{widget} #{widget}-magic")
      end
    end

    it 'executes the custom behavior and the built-in behavior' do
      with_history('foobar', 'foodar') do
        session.send_string('food').send_keys('C-h')
        wait_for { session.content }.to eq('foobar')
      end
    end
  end

  context 'initialized after sourcing the plugin' do
    before do
      session.
        run_command("zle -N orig-#{widget} ${widgets[#{widget}]#*:}").
        run_command("#{widget}-magic() { zle orig-#{widget}; BUFFER+=b }").
        run_command("zle -N #{widget} #{widget}-magic").
        clear_screen
    end

    it 'executes the custom behavior and the built-in behavior' do
      with_history('foobar', 'foodar') do
        session.send_string('food').send_keys('C-h')
        wait_for { session.content }.to eq('foobar')
      end
    end
  end

  context 'when a built-in widget is called with arguments' do
    let(:widget) { 'copy-region-as-kill' }

    before do
      session.run_command('copy-with-argument() { zle copy-region-as-kill -- "hello"; BUFFER=$CUTBUFFER }')
      session.run_command('zle -N copy-with-argument')
      session.run_command("bindkey -M emacs '^X^F' copy-with-argument")
      session.clear_screen
    end

    it 'forwards the arguments to the built-in widget' do
      session.send_keys('C-x').send_keys('C-f')
      wait_for { session.content }.to eq('hello')
    end
  end
end
