describe 'a vicmd mode partial-accept widget' do
  let(:widget) { 'vi-forward-word-end' }

  context 'in vicmd mode' do
#    -> do
#      let(:before_sourcing) do
#        session.
#      end
#    end

    it 'moves the cursor through suggestion as expected' do
      session.run_command("bindkey s vi-cmd-mode")
      with_history('foobar foo') do
        session.send_string('fo').send_keys('s').send_keys('e')
        wait_for { session.content }.to eq('foobar')
      end
    end
  end
end
