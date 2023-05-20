describe 'a suggestion' do
  let(:term_opts) { { width: 200 } }
  let(:command) { "echo foobar" }

  around do |example|
    with_history(command) { example.run }
  end

  it 'is provided for any buffer length' do
    session.send_string(command[0...-1])
    wait_for { session.content }.to eq(command)
  end

  context 'when ZSH_AUTOSUGGEST_BUFFER_MIN_SIZE is specified' do
    let(:buffer_min_size) { 5 }
    let(:options) { ["ZSH_AUTOSUGGEST_BUFFER_MIN_SIZE=#{buffer_min_size}"] }

    it 'is provided when the buffer is longer than the specified length' do
      session.send_string(command[0...(buffer_min_size + 1)])
      wait_for { session.content }.to eq(command)
    end

    it 'is provided when the buffer is equal to the specified length' do
      session.send_string(command[0...(buffer_min_size)])
      wait_for { session.content }.to eq(command)
    end

    it 'is not provided when the buffer is shorter than the specified length' do
      session.send_string(command[0...(buffer_min_size - 1)])
      wait_for { session.content }.to eq(command[0...(buffer_min_size - 1)])
    end
  end
end
