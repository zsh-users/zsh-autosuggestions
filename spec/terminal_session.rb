require 'securerandom'

class TerminalSession
  ZSH_BIN = ENV['TEST_ZSH_BIN'] || 'zsh'

  def initialize(width: 80, height: 24, prompt: '', term: 'xterm-256color')
    tmux_command("new-session -d -x #{width} -y #{height} 'PS1=#{prompt} TERM=#{term} #{ZSH_BIN} -f'")
  end

  def run_command(command)
    send_string(command)
    send_keys('enter')
  end

  def send_string(str)
    tmux_command("send-keys -t 0 -l '#{str.gsub("'", "\\'")}'")
  end

  def send_keys(*keys)
    tmux_command("send-keys -t 0 #{keys.join(' ')}")
  end

  def content(esc_seqs: false)
    cmd = 'capture-pane -p -t 0'
    cmd += ' -e' if esc_seqs
    tmux_command(cmd).strip
  end

  def clear
    send_keys('C-l')
    sleep(0.1) until content == ''
  end

  def destroy
    tmux_command('kill-session')
  end

  def cursor
    tmux_command("display-message -t 0 -p '\#{cursor_x},\#{cursor_y}'").
      strip.
      split(',').
      map(&:to_i)
  end

  private

  def socket_name
    @socket_name ||= SecureRandom.hex(6)
  end

  def tmux_command(cmd)
    out = `tmux -u -L #{socket_name} #{cmd}`

    raise('tmux error') unless $?.success?

    out
  end
end
