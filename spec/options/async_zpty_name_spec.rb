context 'when async suggestions are enabled' do
  let(:options) { ["ZSH_AUTOSUGGEST_USE_ASYNC="] }

  describe 'the zpty for async suggestions' do
    it 'is created with the default name' do
      session.run_command('zpty -t zsh_autosuggest_pty &>/dev/null; echo $?')
      wait_for { session.content }.to end_with("\n0")
    end

    context 'when ZSH_AUTOSUGGEST_ASYNC_PTY_NAME is set' do
      let(:options) { super() + ['ZSH_AUTOSUGGEST_ASYNC_PTY_NAME=foo_pty'] }

      it 'is created with the specified name' do
        session.run_command('zpty -t foo_pty &>/dev/null; echo $?')
        wait_for { session.content }.to end_with("\n0")
      end
    end
  end
end
