describe 'using up-line-or-beginning-search when async is enabled' do
  let(:options) { ["ZSH_AUTOSUGGEST_USE_ASYNC="] }
  let(:before_sourcing) do
    -> do
      session.
        run_command('autoload -U up-line-or-beginning-search').
        run_command('zle -N up-line-or-beginning-search').
        send_string('bindkey "').
        send_keys('C-v').send_keys('up').
        send_string('" up-line-or-beginning-search').
        send_keys('enter')
    end
  end

  it 'should show previous history entries' do
    with_history(
      'echo foo',
      'echo bar',
      'echo baz'
    ) do
      session.clear_screen
      3.times { session.send_keys('up') }
      wait_for { session.content }.to eq("echo foo")
    end
  end
end

