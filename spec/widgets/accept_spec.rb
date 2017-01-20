describe 'accept widget' do
  let(:session) { TerminalSession.new }

  before do
    session.run_command('source zsh-autosuggestions.zsh')
    session.run_command(select_keymap)
    session.run_command('fc -p')
    session.run_command('echo hello world')

    session.clear

    session.send_string('echo')
    wait_for { session.content }.to start_with('echo')
  end

  after do
    session.destroy
  end

  describe 'emacs keymap' do
    let(:select_keymap) { 'bindkey -e' }

    context 'forward-char' do
      subject { session.send_keys('right') }

      context 'when the cursor is at the end of the buffer' do
        it 'accepts the suggestion' do
          expect { subject }.to change { session.content(esc_seqs: true) }.to('echo hello world')
        end

        it 'moves the cursor to the end of the buffer' do
          expect { subject }.to change { session.cursor }.from([4, 0]).to([16, 0])
        end
      end

      context 'when the cursor is not at the end of the buffer' do
        before { 2.times { session.send_keys('left') } }

        it 'does not accept the suggestion' do
          expect { subject }.not_to change { session.content(esc_seqs: true) }
        end

        it 'moves the cursor forward one character' do
          expect { subject }.to change { session.cursor }.from([2, 0]).to([3, 0])
        end
      end
    end

    context 'end-of-line' do
      subject { session.send_keys('C-e') }

      context 'when the cursor is at the end of the buffer' do
        it 'accepts the suggestion' do
          expect { subject }.to change { session.content(esc_seqs: true) }.to('echo hello world')
        end

        it 'moves the cursor to the end of the buffer' do
          expect { subject }.to change { session.cursor }.from([4, 0]).to([16, 0])
        end
      end

      context 'when the cursor is not at the end of the buffer' do
        before { 2.times { session.send_keys('left') } }

        it 'does not accept the suggestion' do
          expect { subject }.not_to change { session.content(esc_seqs: true) }
        end

        it 'moves the cursor to the end of the line' do
          expect { subject }.to change { session.cursor }.from([2, 0]).to([4, 0])
        end
      end
    end
  end

  describe 'vi keymap' do
    let(:select_keymap) { 'bindkey -v' }

    before { session.send_keys('escape') }

    context 'vi-forward-char' do
      subject { session.send_keys('l') }

      context 'when the cursor is at the end of the buffer' do
        it 'accepts the suggestion' do
          expect { subject }.to change { session.content(esc_seqs: true) }.to('echo hello world')
        end

        it 'moves the cursor to the end of the buffer' do
          wait_for { session.cursor }.to eq([3, 0])
          expect { subject }.to change { session.cursor }.from([3, 0]).to([15, 0])
        end
      end

      context 'when the cursor is not at the end of the buffer' do
        before { 2.times { session.send_keys('h') } }

        it 'does not accept the suggestion' do
          expect { subject }.not_to change { session.content(esc_seqs: true) }
        end

        it 'moves the cursor forward one character' do
          expect { subject }.to change { session.cursor }.from([1, 0]).to([2, 0])
        end
      end
    end

    context 'vi-end-of-line' do
      subject { session.send_keys('$') }

      context 'when the cursor is at the end of the buffer' do
        it 'accepts the suggestion' do
          expect { subject }.to change { session.content(esc_seqs: true) }.to('echo hello world')
        end

        it 'moves the cursor to the end of the buffer' do
          wait_for { session.cursor }.to eq([3, 0])
          expect { subject }.to change { session.cursor }.from([3, 0]).to([15, 0])
        end
      end

      context 'when the cursor is not at the end of the buffer' do
        before { 2.times { session.send_keys('h') } }

        it 'does not accept the suggestion' do
          expect { subject }.not_to change { session.content(esc_seqs: true) }
        end

        it 'moves the cursor to the end of the line' do
          expect { subject }.to change { session.cursor }.from([1, 0]).to([3, 0])
        end
      end
    end

    context 'vi-add-eol' do
      subject { session.send_keys('A') }

      context 'when the cursor is at the end of the buffer' do
        it 'accepts the suggestion' do
          expect { subject }.to change { session.content(esc_seqs: true) }.to('echo hello world')
        end

        it 'moves the cursor to the end of the buffer' do
          wait_for { session.cursor }.to eq([3, 0])
          expect { subject }.to change { session.cursor }.from([3, 0]).to([16, 0])
        end
      end

      context 'when the cursor is not at the end of the buffer' do
        before { 2.times { session.send_keys('h') } }

        it 'does not accept the suggestion' do
          expect { subject }.not_to change { session.content(esc_seqs: true) }
        end

        it 'moves the cursor to the end of the line' do
          expect { subject }.to change { session.cursor }.from([1, 0]).to([4, 0])
        end
      end
    end
  end
end
