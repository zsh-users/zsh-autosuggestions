describe 'the `completion` suggestion strategy' do
  let(:options) { ['ZSH_AUTOSUGGEST_STRATEGY=completion'] }
  let(:before_sourcing) do
    -> do
      session.
        run_command('autoload compinit && compinit').
        run_command('_foo() { compadd bar; compadd bat }').
        run_command('compdef _foo baz')
    end
  end

  it 'suggests the first completion result' do
    session.send_string('baz ')
    wait_for { session.content }.to eq('baz bar')
  end

  it 'does not add extra carriage returns when prefix has a line feed' do
    skip '`stty` does not work inside zpty below zsh version 5.0.3' if session.zsh_version < Gem::Version.new('5.0.3')
    session.send_string('baz \\').send_keys('C-v', 'C-j')
    wait_for { session.content }.to eq("baz \\\nbar")
  end

  context 'when `_complete` is aliased' do
    let(:before_sourcing) do
      -> do
        session.
          run_command('autoload compinit && compinit').
          run_command('_foo() { compadd bar; compadd bat }').
          run_command('compdef _foo baz').
          run_command('alias _complete=_complete')
      end
    end

    it 'suggests the first completion result' do
      session.send_string('baz ')
      wait_for { session.content }.to eq('baz bar')
    end
  end

  context 'when async mode is enabled' do
    let(:options) { ['ZSH_AUTOSUGGEST_USE_ASYNC=true', 'ZSH_AUTOSUGGEST_STRATEGY=completion'] }

    it 'suggests the first completion result' do
      session.send_string('baz ')
      wait_for { session.content }.to eq('baz bar')
    end

    it 'does not add extra carriage returns when prefix has a line feed' do
      skip '`stty` does not work inside zpty below zsh version 5.0.3' if session.zsh_version < Gem::Version.new('5.0.3')
      session.send_string('baz \\').send_keys('C-v', 'C-j')
      wait_for { session.content }.to eq("baz \\\nbar")
    end
  end
end

