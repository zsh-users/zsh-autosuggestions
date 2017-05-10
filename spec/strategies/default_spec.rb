describe 'the default suggestion strategy' do
  it 'suggests the last matching history entry' do
    with_history('ls foo', 'ls bar', 'echo baz') do
      session.send_string('ls')
      wait_for { session.content }.to eq('ls bar')
    end
  end
end
