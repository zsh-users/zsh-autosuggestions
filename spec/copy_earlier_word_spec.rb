describe '`copy-earlier-word`' do
  let(:before_sourcing) do
    -> do
      session.
        run_command('autoload -Uz copy-earlier-word').
        run_command('zle -N copy-earlier-word').
        send_string('bindkey "').
        send_keys('C-n').
        send_string('" copy-earlier-word').
        send_keys('enter')
    end
  end

  it 'should copy the first word' do
    session.clear_screen
    session.send_string('foo bar baz')
    3.times { session.send_keys('C-n') }
    wait_for { session.content }.to eq('foo bar bazfoo')
  end
end
