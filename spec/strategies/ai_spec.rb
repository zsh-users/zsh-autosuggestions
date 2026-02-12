describe 'the `ai` suggestion strategy' do
 let(:options) { ["ZSH_AUTOSUGGEST_STRATEGY=(ai history)"] }

 let(:before_sourcing) do
 -> {
 session.run_command('curl() {
  if [[ "$*" == *"max-time"* ]]; then
  cat <<EOF
{"choices":[{"message":{"content":"git status --short"}}]}
200
EOF
   fi
  }')
  }
 end

  context 'when API key is not set' do
  it 'returns no suggestion and falls through to next strategy' do
 with_history('git status --short') do
   session.send_string('git st')
  wait_for { session.content }.to eq('git status --short')
  end
 end
  end

 context 'when API key is set' do
  let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_STRATEGY=(ai history)"] }

  context 'and curl/jq are available' do
  it 'suggests completion from AI' do
  session.send_string('git st')
  wait_for { session.content }.to eq('git status --short')
  end
  end

  context 'when input is below minimum threshold' do
  let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_AI_MIN_INPUT=5", "ZSH_AUTOSUGGEST_STRATEGY=(ai history)"] }

  it 'returns no suggestion for short input' do
   with_history('git status') do
  session.send_string('git')
   wait_for { session.content }.to eq('git status')
   end
  end
  end
 end

 context 'when curl fails' do
  let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_STRATEGY=(ai history)"] }

 let(:before_sourcing) do
  -> {
  session.run_command('curl() { return 1 }')
 }
 end

 it 'falls through to next strategy' do
  with_history('git status') do
  session.send_string('git st')
  wait_for { session.content }.to eq('git status')
  end
  end
  end

 context 'when API returns HTTP error' do
  let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_STRATEGY=(ai history)"] }

 let(:before_sourcing) do
  -> {
  session.run_command('curl() {
  if [[ "$*" == *"max-time"* ]]; then
  cat <<EOF
{"error":"Unauthorized"}
401
EOF
  fi
 }')
 }
 end

 it 'falls through to next strategy' do
   with_history('git status') do
   session.send_string('git st')
  wait_for { session.content }.to eq('git status')
  end
 end
 end

 context 'when API returns malformed JSON' do
  let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_STRATEGY=(ai history)"] }

 let(:before_sourcing) do
  -> {
  session.run_command('curl() {
  if [[ "$*" == *"max-time"* ]]; then
  cat <<EOF
not valid json
200
EOF
   fi
 }')
  }
 end

 it 'falls through to next strategy' do
 with_history('git status') do
  session.send_string('git st')
  wait_for { session.content }.to eq('git status')
  end
 end
 end

 context 'response normalization' do
 let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_STRATEGY=(ai)"] }

  context 'when response has markdown code fences' do
 let(:before_sourcing) do
  -> {
  session.run_command('curl() {
  if [[ "$*" == *"max-time"* ]]; then
  cat <<EOF
{"choices":[{"message":{"content":"```\\ngit status\\n```"}}]}
200
EOF
   fi
  }')
  }
  end

  it 'strips the code fences' do
  session.send_string('git st')
  wait_for { session.content }.to eq('git status')
  end
  end

  context 'when response includes the input prefix' do
  let(:before_sourcing) do
  -> {
   session.run_command('curl() {
  if [[ "$*" == *"max-time"* ]]; then
  cat <<EOF
{"choices":[{"message":{"content":"git status --short"}}]}
200
EOF
  fi
   }')
  }
 end

  it 'uses the complete command' do
  session.send_string('git st')
  wait_for { session.content }.to eq('git status --short')
 end
  end
 end

 context 'fallback strategy' do
 let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_STRATEGY=(ai history)"] }

 let(:before_sourcing) do
 -> {
  session.run_command('curl() { return 1 }')
 }
 end

 it 'uses history when AI fails' do
 with_history('git status --long') do
  session.send_string('git st')
  wait_for { session.content }.to eq('git status --long')
 end
 end
 end
end

 context 'prompt artifact stripping' do
 let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_STRATEGY=(ai)"] }

 let(:before_sourcing) do
 -> {
 session.run_command('curl() {
 if [[ "$*" == *"max-time"* ]]; then
 cat <<EOFCURL
{"choices":[{"message":{"content":"$ git status"}}]}
200
EOFCURL
 fi
 }')
 }
 end

 it 'strips $ prompt artifact' do
 session.send_string('git st')
 wait_for { session.content }.to eq('git status')
 end
 end

 context 'empty buffer suggestions' do
 let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_AI_MIN_INPUT=0", "ZSH_AUTOSUGGEST_STRATEGY=(ai)"] }

 let(:before_sourcing) do
 -> {
 session.run_command('curl() {
 if [[ "$*" == *"max-time"* ]]; then
 cat <<EOFCURL
{"choices":[{"message":{"content":"git status"}}]}
200
EOFCURL
 fi
 }')
 }
 end

 it 'suggests command on empty buffer when enabled' do
 session.send_keys('C-c')
 wait_for { session.content(esc_seqs: true) }.to match(/git status/)
 end
 end

 context 'empty buffer with default min input' do
 let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_AI_MIN_INPUT=1", "ZSH_AUTOSUGGEST_STRATEGY=(ai history)"] }

 let(:before_sourcing) do
 -> {
 session.run_command('curl() {
 if [[ "$*" == *"max-time"* ]]; then
 cat <<EOFCURL
{"choices":[{"message":{"content":"git status"}}]}
200
EOFCURL
 fi
 }')
 }
 end

 it 'does not suggest on empty buffer when min input is 1' do
 with_history('git status') do
 sleep 0.5
 expect(session.content).to_not match(/git status/)
 session.send_string('git')
 wait_for { session.content }.to eq('git status')
 end
 end
 end

 context 'endpoint construction' do
 let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_STRATEGY=(ai)"] }

 let(:before_sourcing) do
 -> {
 session.run_command('curl() {
 local url=""
 for arg in "$@"; do
 if [[ "$arg" == http* ]]; then
 url="$arg"
 break
 fi
 done
 if [[ "$url" == */chat/completions ]]; then
 cat <<EOFCURL
{"choices":[{"message":{"content":"correct endpoint"}}]}
200
EOFCURL
 else
 cat <<EOFCURL
{"error":"wrong endpoint"}
400
EOFCURL
 fi
 }')
 }
 end

 it 'appends /chat/completions to base URL' do
 session.send_string('test')
 wait_for { session.content }.to eq('correct endpoint')
 end

 context 'with custom base URL' do
 let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_AI_ENDPOINT=http://custom.api/v1", "ZSH_AUTOSUGGEST_STRATEGY=(ai)"] }

 it 'constructs endpoint correctly' do
 session.send_string('test')
 wait_for { session.content }.to eq('correct endpoint')
 end
 end
 end

 context 'environmental context gathering' do
 let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_STRATEGY=(ai)"] }

 let(:before_sourcing) do
 -> {
 session.run_command('curl() {
 local data=""
 for arg in "$@"; do
 if [[ "$arg" == -d ]]; then
 shift
 data="$1"
 break
 fi
 shift
 done
 if [[ "$data" == *"Directory contents"* ]]; then
 cat <<EOFCURL
{"choices":[{"message":{"content":"has directory context"}}]}
200
EOFCURL
 else
 cat <<EOFCURL
{"choices":[{"message":{"content":"no context"}}]}
200
EOFCURL
 fi
 }')
 session.run_command('ls() { echo "file1.txt\nfile2.txt"; }')
 }
 end

 it 'includes directory contents in context' do
 session.send_string('test')
 wait_for { session.content }.to eq('has directory context')
 end
 end

 context 'dual prompt modes' do
 let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_AI_MIN_INPUT=0", "ZSH_AUTOSUGGEST_STRATEGY=(ai)"] }

 context 'empty buffer mode' do
 let(:before_sourcing) do
 -> {
 session.run_command('curl() {
 local data=""
 for arg in "$@"; do
 if [[ "$arg" == -d ]]; then
 shift
 data="$1"
 break
 fi
 shift
 done
 if [[ "$data" == *"prediction engine"* ]]; then
 cat <<EOFCURL
{"choices":[{"message":{"content":"prediction mode active"}}]}
200
EOFCURL
 elif [[ "$data" == *"auto-completion engine"* ]]; then
 cat <<EOFCURL
{"choices":[{"message":{"content":"completion mode active"}}]}
200
EOFCURL
 fi
 }')
 }
 end

 it 'uses prediction prompt for empty buffer' do
 session.send_keys('C-c')
 wait_for { session.content(esc_seqs: true) }.to match(/prediction mode/)
 end

 it 'uses completion prompt for partial input' do
 session.send_string('git')
 wait_for { session.content }.to match(/completion mode/)
 end
 end
 end

 context 'temperature configuration' do
 let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_AI_MIN_INPUT=0", "ZSH_AUTOSUGGEST_STRATEGY=(ai)"] }

 let(:before_sourcing) do
 -> {
 session.run_command('curl() {
 local data=""
 for arg in "$@"; do
 if [[ "$arg" == -d ]]; then
 shift
 data="$1"
 break
 fi
 shift
 done
 if [[ "$data" == *"\"temperature\": 0.5"* ]]; then
 cat <<EOFCURL
{"choices":[{"message":{"content":"temp 0.5"}}]}
200
EOFCURL
 elif [[ "$data" == *"\"temperature\": 0.3"* ]]; then
 cat <<EOFCURL
{"choices":[{"message":{"content":"temp 0.3"}}]}
200
EOFCURL
 fi
 }')
 }
 end

 it 'uses temperature 0.5 for empty buffer' do
 session.send_keys('C-c')
 wait_for { session.content(esc_seqs: true) }.to match(/temp 0.5/)
 end

 it 'uses temperature 0.3 for partial input' do
 session.send_string('test')
 wait_for { session.content }.to eq('temp 0.3')
 end
 end

 context 'suggestion buffer validation' do
 let(:options) { ["ZSH_AUTOSUGGEST_AI_API_KEY=test-key", "ZSH_AUTOSUGGEST_STRATEGY=(ai)"] }

 context 'when suggestion does not match current buffer' do
 let(:before_sourcing) do
 -> {
 session.run_command('curl() {
 if [[ "$*" == *"max-time"* ]]; then
 cat <<EOFCURL
{"choices":[{"message":{"content":"git status --long"}}]}
200
EOFCURL
 fi
 }')
 }
 end

 it 'discards suggestion that does not match buffer' do
 # Suggestion is "git status --long" but buffer is unrelated
 session.send_string('ls')
 wait_for { session.content }.to_not match(/git status/)
 end
 end
 end
end
