describe 'the `autosuggest-next` widget' do
  let(:options) { ['unset ZSH_AUTOSUGGEST_USE_ASYNC', 'ZSH_AUTOSUGGEST_STRATEGY=history'] }

  before do
    session.run_command('bindkey ^N autosuggest-next')
  end

  it 'cycles through history suggestions and wraps around' do
    with_history do
      session.run_command('echo foo')
      session.run_command('echo bar')
      session.run_command('echo baz')
      session.clear_screen

      session.send_string('echo ')
      wait_for { session.content }.to eq('echo baz')

      session.send_keys('C-n')
      wait_for { session.content }.to eq('echo bar')

      session.send_keys('C-n')
      wait_for { session.content }.to eq('echo foo')

      session.send_keys('C-n')
      wait_for { session.content }.to eq('echo baz')
    end
  end

  it 'leaves the buffer untouched when no suggestions are available' do
    with_history do
      session.send_string('foo')
      wait_for { session.content }.to eq('foo')

      session.send_keys('C-n')
      wait_for { session.content }.to eq('foo')
    end
  end
end
