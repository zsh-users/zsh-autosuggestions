describe 'when using vi mode' do
  let(:before_sourcing) do
    -> do
      session.run_command('bindkey -v')
    end
  end

  describe 'moving the cursor after exiting insert mode' do
    it 'should not clear the current suggestion' do
      with_history('foobar foo') do
        session.
          send_string('foo').
          send_keys('escape').
          send_keys('h')

        wait_for { session.content }.to eq('foobar foo')
      end
    end
  end
end

