describe 'a running zpty command' do
  it 'is not affected by running zsh-autosuggestions' do
    session.run_command('zmodload zsh/zpty')
    session.run_command('zpty -b kitty cat')
    session.run_command('zpty -w kitty cat')
    sleep 1
    session.run_command('zpty -r kitty')

    wait_for(session.content).to end_with("\ncat")
  end
end
