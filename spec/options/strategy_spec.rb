describe 'a suggestion for a given prefix' do
  let(:options) { ['_zsh_autosuggest_strategy_default() { suggestion="echo foo" }'] }

  it 'is determined by calling the default strategy function' do
    session.send_string('e')
    wait_for { session.content }.to eq('echo foo')
  end

  context 'when ZSH_AUTOSUGGEST_STRATEGY is set' do
    let(:options) { [
      '_zsh_autosuggest_strategy_custom() { suggestion="echo foo" }',
      'ZSH_AUTOSUGGEST_STRATEGY=custom'
    ] }

    it 'is determined by calling the specified strategy function' do
      session.send_string('e')
      wait_for { session.content }.to eq('echo foo')
    end
  end
end
