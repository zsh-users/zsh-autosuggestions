describe 'a running zpty command' do
  let(:before_sourcing) { -> { session.run_command('zmodload zsh/zpty && zpty -b kitty cat') } }

  it 'is not affected by running zsh-autosuggestions' do
    sleep 1 # Give a little time for precmd hooks to run
    session.run_command('zpty -t kitty; echo $?')

    wait_for { session.content }.to end_with("\n0")
  end
end
