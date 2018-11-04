describe 'the `autosuggest-next` widget' do
  context 'when suggestions are disabled' do
    before do
      session.
        run_command('bindkey ^B autosuggest-disable').
        run_command('bindkey ^K autosuggest-next').
        send_keys('C-b')
    end

    it 'will fetch and display a suggestion' do
      with_history('echo hello', 'echo world', 'echo joe') do
        session.send_string('echo h')
        sleep 1
        expect(session.content).to eq('echo h')

        session.send_keys('C-k')
        wait_for { session.content }.to eq('echo hello')

        session.send_string('e')
        wait_for { session.content }.to eq('echo hello')
      end
    end
  end

  context 'invoked on a populated history' do
    before do
      session.
        run_command('bindkey ^K autosuggest-next')
    end

    it 'will cycle, fetch, and display a suggestion' do
      with_history('echo hello', 'echo world', 'echo joe') do
        session.send_string('echo')
        sleep 1
        expect(session.content).to eq('echo joe')

        session.send_keys('C-k')
        wait_for { session.content }.to eq('echo world')

        session.send_keys('C-k')
        wait_for { session.content }.to eq('echo hello')

        session.send_keys('C-k')
        wait_for { session.content }.to eq('echo hello')
      end
    end
  end
end
