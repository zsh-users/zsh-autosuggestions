describe 'rebinding [' do
  context 'initialized before sourcing the plugin' do
    before do
      session.send_string("function [ { $commands[\\[] \"$@\" }")
      session.send_keys("'enter'")
      session.clear_screen
    end

    it 'executes the custom behavior and the built-in behavior' do
      session.send_string('asdf')
      wait_for { session.content }.to eq('asdf')
    end
  end
end
