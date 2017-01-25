describe 'default strategy' do
  let(:session) { TerminalSession.new }

  before do
    session.run_command('source zsh-autosuggestions.zsh')
    session.run_command('fc -p')
    session.clear
  end

  after do
    session.destroy
  end

  context 'with some simple history entries' do
    before do
      session.run_command('ls foo')
      session.run_command('ls bar')

      session.clear
    end

    it 'suggests nothing if there is no match' do
      session.send_string('ls q')
      wait_for { session.content }.to eq('ls q')
    end

    it 'suggests the most recent matching history item' do
      session.send_string('ls')
      wait_for { session.content }.to eq('ls bar')
    end
  end

  xcontext 'with a multiline hist entry' do
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

  context 'with a newline hist entry' do
    before do
      session.send_string('echo "\n"')
      session.send_keys('enter')

      session.clear
    end

    it do
      session.send_keys('e')
      wait_for { session.content }.to eq 'echo "\n"'
    end
  end

  context 'with a hist entry with a backslash' do
    before do
      session.run_command('echo "hello\nworld"')
      session.clear
    end

    it do
      session.send_string('echo "hello\\')
      wait_for { session.content }.to eq('echo "hello\nworld"')
    end
  end

  context 'with a hist entry with double backslashes' do
    before do
      session.run_command('echo "\\\\"')
      session.clear
    end

    it do
      session.send_string('echo "\\\\')
      wait_for { session.content }.to eq('echo "\\\\"')
    end
  end

  context 'with a hist entry with a tilde' do
    before do
      session.run_command('ls ~/foo')
      session.clear
    end

    it do
      session.send_string('ls ~')
      wait_for { session.content }.to eq('ls ~/foo')
    end

    context 'with extended_glob set' do
      before do
        session.run_command('setopt local_options extended_glob')
        session.clear
      end

      it do
        session.send_string('ls ~')
        wait_for { session.content }.to eq('ls ~/foo')
      end
    end
  end

  context 'with a hist entry with parentheses' do
    before do
      session.run_command('echo "$(ls foo)"')
      session.clear
    end

    it do
      session.send_string('echo "$(')
      wait_for { session.content }.to eq('echo "$(ls foo)"')
    end
  end

  context 'with a hist entry with square brackets' do
    before do
      session.run_command('echo "$history[123]"')
      session.clear
    end

    it do
      session.send_string('echo "$history[')
      wait_for { session.content }.to eq('echo "$history[123]"')
    end
  end

  context 'with a hist entry with pound sign' do
    before do
      session.run_command('echo "#yolo"')
      session.clear
    end

    it do
      session.send_string('echo "#')
      wait_for { session.content }.to eq('echo "#yolo"')
    end
  end
end
