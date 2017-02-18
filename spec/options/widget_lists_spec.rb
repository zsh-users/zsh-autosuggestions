describe 'a zle widget' do
  let(:before_sourcing) { -> { session.run_command('my-widget() {}; zle -N my-widget; bindkey ^B my-widget') } }

  context 'when added to ZSH_AUTOSUGGEST_ACCEPT_WIDGETS' do
    let(:options) { ['ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=(my-widget)'] }

    it 'accepts the suggestion when invoked' do
      with_history('echo hello') do
        session.send_string('e')
        wait_for { session.content }.to eq('echo hello')
        session.send_keys('C-b')
        wait_for { session.content(esc_seqs: true) }.to eq('echo hello')
      end
    end
  end

  context 'when added to ZSH_AUTOSUGGEST_CLEAR_WIDGETS' do
    let(:options) { ['ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(my-widget)'] }

    it 'clears the suggestion when invoked' do
      with_history('echo hello') do
        session.send_string('e')
        wait_for { session.content }.to eq('echo hello')
        session.send_keys('C-b')
        wait_for { session.content }.to eq('e')
      end
    end
  end

  context 'when added to ZSH_AUTOSUGGEST_EXECUTE_WIDGETS' do
    let(:options) { ['ZSH_AUTOSUGGEST_EXECUTE_WIDGETS+=(my-widget)'] }

    it 'executes the suggestion when invoked' do
      with_history('echo hello') do
        session.send_string('e')
        wait_for { session.content }.to eq('echo hello')
        session.send_keys('C-b')
        wait_for { session.content }.to end_with("\nhello")
      end
    end
  end
end

describe 'a zle widget that moves the cursor forward' do
  let(:before_sourcing) { -> { session.run_command('my-widget() { zle forward-char }; zle -N my-widget; bindkey ^B my-widget') } }

  context 'when added to ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS' do
    let(:options) { ['ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(my-widget)'] }

    it 'accepts the suggestion as far as the cursor is moved when invoked' do
      with_history('echo hello') do
        session.send_string('e')
        wait_for { session.content }.to start_with('echo hello')
        session.send_keys('C-b')
        wait_for { session.content(esc_seqs: true) }.to match(/\Aec\e\[[0-9]+mho hello/)
      end
    end
  end
end

describe 'a builtin zle widget' do
  let(:widget) { 'beep' }

  context 'when added to ZSH_AUTOSUGGEST_IGNORE_WIDGETS' do
    let(:options) { ["ZSH_AUTOSUGGEST_IGNORE_WIDGETS=(#{widget})"] }

    it 'should not be wrapped with an autosuggest widget' do
      session.run_command("echo $widgets[#{widget}]")
      wait_for { session.content }.to end_with("\nbuiltin")
    end
  end
end
