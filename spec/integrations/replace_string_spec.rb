describe 'the replace-string widget' do
  let(:options) { ['ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(replace-string)'] }
  let(:after_sourcing) do
    -> do
      session.
        run_command('autoload -Uz replace-string').
        run_command('zle -N replace-string').
        run_command("bindkey '^B' replace-string")
    end
  end

  it 'preserves the command line while reading search and replacement text' do
    session.send_string('echo this is my test string').send_keys('C-b')
    session.send_string('my').send_keys('C-m')

    wait_for { session.content }.to include('echo this is my test string')

    session.send_string('your').send_keys('C-m')
    wait_for { session.content }.to include('echo this is your test string')

    session.send_keys('C-m')
    wait_for { session.content }.to include('this is your test string')
  end
end
