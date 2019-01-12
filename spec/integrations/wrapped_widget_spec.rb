describe 'a wrapped widget' do
  let(:widget) { 'backward-delete-char' }

  let(:initialize_widget) do
    -> do
      session.run_command(<<~ZSH)
        if [[ "$widgets[#{widget}]" == "builtin" ]]; then
          _orig_#{widget}() { zle .#{widget} }
          zle -N orig-#{widget} _orig_#{widget}
        else
          zle -N orig-#{widget} ${widgets[#{widget}]#*:}
        fi

        #{widget}-magic() { zle orig-#{widget}; BUFFER+=b }
        zle -N #{widget} #{widget}-magic
      ZSH
    end
  end

  context 'initialized before sourcing the plugin' do
    let(:before_sourcing) { initialize_widget }

    it 'executes the custom behavior and the built-in behavior' do
      with_history('foobar', 'foodar') do
        session.send_string('food').send_keys('C-h')
        wait_for { session.content }.to eq('foobar')
      end
    end
  end

  context 'initialized after sourcing the plugin' do
    let(:after_sourcing) { initialize_widget }

    it 'executes the custom behavior and the built-in behavior' do
      with_history('foobar', 'foodar') do
        session.send_string('food').send_keys('C-h')
        wait_for { session.content }.to eq('foobar')
      end
    end
  end
end
