describe 'match_prev_cmd strategy' do
  let(:session) { TerminalSession.new }

  before do
    session.run_command('source zsh-autosuggestions.zsh')
    session.run_command('ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd')
    session.run_command('fc -p')
    session.clear
  end

  after do
    session.destroy
  end

  context 'with some history entries' do
    before do
      session.run_command('echo what')
      session.run_command('ls foo')
      session.run_command('echo what')
      session.run_command('ls bar')
      session.run_command('ls baz')

      session.clear
    end

    it 'suggests nothing if prefix does not match' do
      session.send_string('ls q')
      wait_for { session.content }.to eq('ls q')
    end

    it 'suggests the most recent matching history item' do
      session.send_string('ls')
      wait_for { session.content }.to eq('ls baz')
    end

    it 'suggests the most recent after the previous command' do
      session.run_command('echo what')
      session.clear

      session.send_string('ls')
      wait_for { session.content }.to eq('ls bar')
    end
  end

  context 'with a multiline hist entry' do
    before do
      session.send_string('echo "')
      session.send_keys('enter')
      session.send_string('"')
      session.send_keys('enter')

      session.clear
    end

    it do
      session.send_keys('e')
      wait_for { session.content }.to eq "echo \"\n\""
    end
  end
end
