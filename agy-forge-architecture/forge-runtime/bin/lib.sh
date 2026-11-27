# Shared helpers for forge scripts. Source from bash after setting id.
[ -n "${BASH_SOURCE[0]:-}" ] || { echo "lib.sh must be sourced from bash" >&2; return 1; }
FORGE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
task="$FORGE/tasks/$id"
wt="$FORGE/worktrees/$id"
state="$FORGE/logs/$id"
accept_dir="$FORGE/accept/$id"
mkdir -p "$state"

PI_MODEL="${PI_MODEL:-google/gemini-4-neon}"
PI_LIGHT_MODEL="${PI_LIGHT_MODEL:-google/gemini-4-hydrogen}"
PI_EXEC_MODEL="${PI_EXEC_MODEL:-openai/gpt-6.2-sol}"
PI_EXEC_OVERFLOW_MODEL="${PI_EXEC_OVERFLOW_MODEL:-google/gemini-4-neon}"
PI_EXEC_THINKING="${PI_EXEC_THINKING:-xhigh}"
PI_EXEC_OVERFLOW_THINKING="${PI_EXEC_OVERFLOW_THINKING:-$PI_EXEC_THINKING}"
SOL_MAX_PROCS="${SOL_MAX_PROCS:-2}"
FORGE_EXEC_SCHED="${FORGE_EXEC_SCHED:-auto}"
FORGE_SCHED_DIR="${FORGE_SCHED_DIR:-$FORGE/logs/.sched}"

if [ -z "${PI_EXEC_FALLBACK_MODEL:-}" ]; then
  if [ "$PI_EXEC_MODEL" = "openai/gpt-6.2-sol" ]; then
    PI_EXEC_FALLBACK_MODEL="openai/gpt-6.2-astra"
  else
    PI_EXEC_FALLBACK_MODEL="openai/gpt-6.2-sol"
  fi
fi
PI_REVIEW_LOGIC_MODEL="${PI_REVIEW_LOGIC_MODEL:-openai/gpt-6.2-astra}"
PI_REVIEW_STYLE_MODEL="${PI_REVIEW_STYLE_MODEL:-openai/gpt-6.2-sol}"
PI_REVIEW_THINKING="${PI_REVIEW_THINKING:-high}"
PI_REVIEW_MODEL="${PI_REVIEW_MODEL:-$PI_REVIEW_LOGIC_MODEL}"
PI_AUDIT_MODEL="${PI_AUDIT_MODEL:-google/gemini-4-neon}"

AGY_BIN="${AGY_BIN:-$(command -v agy 2>/dev/null || echo "$HOME/.local/bin/agy")}"
AGY_ARBITER_AGENT="${AGY_ARBITER_AGENT:-pragmatic-arbiter}"
AGY_ARBITER_MODEL="${AGY_ARBITER_MODEL:-gemini-4-carbon-medium}"
ARBITER_ENABLED="${ARBITER_ENABLED:-1}"
ARBITER_MIN_ROUND="${ARBITER_MIN_ROUND:-1}"
ARBITER_TIMEOUT="${ARBITER_TIMEOUT:-420}"
TOP_AUDIT="${TOP_AUDIT:-0}"

# pi_run <timeout_s> <log> <pi args...>: run pi non-interactively with a hard timeout
pi_run() {
  local to="$1" log="$2"; shift 2
  local margs=()
  local has_model=0 arg
  for arg in "$@"; do
    if [ "$arg" = "--model" ]; then has_model=1; break; fi
  done
  if [ "$has_model" = 0 ] && [ -n "${PI_MODEL:-}" ]; then
    margs=(--model "$PI_MODEL")
  fi
  perl -e 'alarm shift; exec @ARGV' "$to" pi -p --mode json ${margs[@]+"${margs[@]}"} "$@" > "$log" 2>&1
}

# lasttext <log>: final assistant text from a pi json event stream (ignores non-JSON warning lines)
lasttext() {
  jq -R 'fromjson? | select(type=="object")' "$1" 2>/dev/null \
    | jq -rs '[.[] | select(.type=="message_end" and .message.role=="assistant")]
              | last | .message.content // [] | map(select(.type=="text").text) | join("\n")' 2>/dev/null
}

# exec_transport_error <log>: true iff the final assistant message ended in an upstream load/rate/transport error
exec_transport_error() {
  jq -R 'fromjson? | select(type=="object")' "$1" 2>/dev/null \
    | jq -ers '[.[] | select(.type=="message_end" and .message.role=="assistant")] | last
               | select(. != null and ((.message.stopReason // .stopReason // "") == "error"))
               | (.message.errorMessage // .errorMessage // "")
               | select(test("429|502|503|504|rate[_ -]?limit|overloaded|capacity|ECONNRESET|ETIMEDOUT|UND_ERR|other side closed|socket disconnected|fetch failed|terminated|location is not supported|server_error"; "i"))' >/dev/null 2>&1
}

# criteria_sha: fingerprint of the acceptance criteria and fixtures Pi must not change
criteria_sha() {
  {
    if [ -d "$task" ]; then
      (
        cd "$task"
        find . -type f ! -name 'status.json' ! -name 'report.md' ! -name 'pid' ! -name '.DS_Store' \
          | LC_ALL=C sort \
          | while IFS= read -r f; do
              [ -n "$f" ] && shasum -a 256 "$f"
            done
      )
    fi
    if [ -d "$accept_dir" ]; then
      (
        cd "$accept_dir"
        find . -type f ! -name '.DS_Store' \
          | LC_ALL=C sort \
          | while IFS= read -r f; do
              [ -n "$f" ] && printf 'accept/' && shasum -a 256 "$f"
            done
      )
    fi
  } | shasum -a 256 | cut -c1-16
}

# diff_churn <base> <branch>: total added + deleted lines across diff
diff_churn() {
  local base_ref="$1" target_ref="$2"
  git -C "$REPO" diff --numstat "$base_ref" "$target_ref" 2>/dev/null \
    | awk '{ if ($1 ~ /^[0-9]+$/) a+=$1; if ($2 ~ /^[0-9]+$/) d+=$2 } END { print a+d+0 }'
}

# diff_bytes <base> <branch>: byte size of full git diff
diff_bytes() {
  local base_ref="$1" target_ref="$2"
  git -C "$REPO" diff "$base_ref" "$target_ref" 2>/dev/null | wc -c | tr -d ' '
}

# Target repo: tasks/<id>/repo may name an external git repo (one path line); default is forge itself.
# For external repos, tasks/<id>/base_ref names the start point (default HEAD of that repo).
REPO="$FORGE"
if [ -f "$task/repo" ]; then
  REPO="$(head -1 "$task/repo")"
fi
