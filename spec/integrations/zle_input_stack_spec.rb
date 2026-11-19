describe 'using `zle -U`' do
  let(:before_sourcing) do
    -> do
      session.
        run_command('_zsh_autosuggest_strategy_test() { sleep 1; _zsh_autosuggest_strategy_history "$1" }').
        run_command('foo() { zle -U - "echo hello" }; zle -N foo; bindkey ^B foo')
    end
  end

  let(:options) { ['unset ZSH_AUTOSUGGEST_USE_ASYNC', 'ZSH_AUTOSUGGEST_STRATEGY=test'] }

  # TODO: This is only possible with the $KEYS_QUEUED_COUNT widget parameter, coming soon...
  xit 'does not fetch a suggestion for every inserted character' do
    session.send_keys('C-b')
    wait_for { session.content }.to eq('echo hello')
  end

  it 'shows a suggestion when the widget completes' do
    with_history('echo hello world') do
      session.send_keys('C-b')
      wait_for { session.content(esc_seqs: true) }.to match(/\Aecho hello\e\[[0-9]+m world/)
    end
  end
end

describe 'handling queued input after modifying the buffer' do
  it 'does not restore a stale suggestion when more input is pending' do
    with_history('echo hello world') do
      session.send_string('echo h')
      wait_for { session.content(esc_seqs: true) }.to match(/echo h.*world/)

      session.send_keys('x', 'right', 'enter')

      wait_for { session.content }.to include("hx\n")
      expect(session.content).not_to include('hxello world')
    end
  end
end
