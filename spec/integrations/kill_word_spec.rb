describe 'multiple words killed with `backward-kill-word`' do
  before do
    session.
      send_string('echo first second').
      send_keys('C-w').
      send_keys('C-w')
    wait_for { session.content }.to eq('echo')
  end

  it 'can be yanked back with `yank`' do
    session.send_keys('C-y')
    wait_for { session.content }.to eq('echo first second')
  end
end
