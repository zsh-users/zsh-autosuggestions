context 'after positioning cursor before a word' do
  before do
    session.send_string('echo hello world bye')
  end

  describe '`yank` then `yank-pop`' do
    it 'should insert text in correct position before word' do
      session.send_keys('C-w').send_keys('C-h').send_keys('C-w')
      wait_for { session.content }.to eq('echo hello')

      session.send_keys('M-b').send_keys('C-y')
      wait_for { session.content }.to eq('echo worldhello')

      session.send_keys('M-y')
      wait_for { session.content }.to eq('echo byehello')
    end
  end
end
