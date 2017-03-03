describe 'the `autosuggest-enable` widget' do
  before do
    session.
      run_command('typeset -g _ZSH_AUTOSUGGEST_DISABLED').
      run_command('bindkey ^B autosuggest-enable')
  end

  it 'enables suggestions and fetches a suggestion' do
    with_history('echo world', 'echo hello') do
      session.send_string('echo')
      sleep 1
      expect(session.content).to eq('echo')

      session.send_keys('C-b')
      wait_for { session.content }.to eq('echo hello')

      session.send_string(' w')
      wait_for { session.content }.to eq('echo world')
    end
  end
end
