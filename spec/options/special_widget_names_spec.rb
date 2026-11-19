describe 'widgets that depend on their invocation name' do
  context 'when invoking run-help' do
    let(:before_sourcing) do
      -> do
        session.run_command('unalias run-help 2>/dev/null')
        session.run_command('run-help() { BUFFER=$1; zle redisplay }')
        session.run_command("bindkey '^Xh' run-help")
      end
    end

    it 'clears the suggestion and invokes the original widget by its canonical name' do
      with_history('git status') do
        session.send_string('git')
        wait_for { session.content }.to end_with('git status')
        session.send_keys('C-x')
        session.send_keys('h')
        wait_for { session.content }.to end_with('git')
      end
    end
  end

  context 'when invoking which-command' do
    let(:before_sourcing) do
      -> do
        session.run_command('capture-widget-name() { BUFFER=$WIDGET; zle redisplay }')
        session.run_command('zle -N which-command capture-widget-name')
        session.run_command("bindkey '^Xw' which-command")
      end
    end

    it 'clears the suggestion and preserves the original widget name' do
      with_history('git status') do
        session.send_string('git')
        wait_for { session.content }.to end_with('git status')
        session.send_keys('C-x')
        session.send_keys('w')
        wait_for { session.content }.to end_with('which-command')
      end
    end
  end
end
