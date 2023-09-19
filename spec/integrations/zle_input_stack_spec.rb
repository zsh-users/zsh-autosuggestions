describe 'using `zle -U`' do
  let(:before_sourcing) do
    -> do
      session.
        run_command('_zsh_autosuggest_strategy_test() { sleep 1; _zsh_autosuggest_strategy_history "$1" }').
        run_command('foo() { zle -U - "echo hello" }; zle -N foo; bindkey ^B foo')
    end
  end

  let(:options) { ['unset ZSH_AUTOSUGGEST_USE_ASYNC', 'ZSH_AUTOSUGGEST_STRATEGY=test'] }

  # This is only possible with the $KEYS_QUEUED_COUNT widget parameter
  it 'does not fetch a suggestion for every inserted character' do
    session.send_keys('C-b')

    # Check if zsh >= 5.4
    version_arr = ENV['TEST_ZSH_BIN'].split('zsh-')[1].split('.')
    if version_arr[0].to_i >= 6 || (version_arr[0].to_i == 5 && version_arr[1].to_i >= 4)
      wait_for { session.content }.to eq('echo hello')
    else
      skip "depends on KEYS_QUEUED_COUNT which requires zsh 5.4 or above"
    end
  end

  it 'shows a suggestion when the widget completes' do
    with_history('echo hello world') do
      session.send_keys('C-b')
      wait_for { session.content(esc_seqs: true) }.to match(/\Aecho hello\e\[[0-9]+m world/)
    end
  end
end
