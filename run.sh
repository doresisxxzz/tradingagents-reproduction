#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")"
root="$PWD"
if [[ $# != 2 || ! $1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ || ! $2 =~ ^[12]$ ]]; then
  echo "Usage: bash run.sh YYYY-MM-DD {1|2}" >&2
  exit 2
fi
day="$1"
rounds="$2"
revision=9fa1196fffbcfd9de5146d2dd2869df84ab99838
if [[ "$(git -C upstream rev-parse HEAD 2>/dev/null)" != "$revision" ]]; then
  echo "Check out the pinned upstream revision first. See README.md." >&2
  exit 1
fi
if [[ ! -s .env ]]; then
  echo "Configure DEEPSEEK_API_KEY in the local .env file first." >&2
  exit 1
fi
mkdir -p "$root/runs"
out="$(mktemp -d "$root/runs/AAPL-${day}-r${rounds}.XXXXXX")"
cd upstream
export TRADINGAGENTS_RESULTS_DIR="$out"
export TRADINGAGENTS_CACHE_DIR="$out/cache"
export TRADINGAGENTS_MEMORY_LOG_PATH="$out/memory.md"
export TRADINGAGENTS_LLM_PROVIDER=deepseek
export TRADINGAGENTS_QUICK_THINK_LLM=deepseek-v4-flash
export TRADINGAGENTS_DEEP_THINK_LLM=deepseek-v4-flash
export TRADINGAGENTS_OUTPUT_LANGUAGE=English
export TRADINGAGENTS_MAX_RISK_ROUNDS=1
export TRADINGAGENTS_CHECKPOINT_ENABLED=false
export TRADINGAGENTS_MAX_DEBATE_ROUNDS="$rounds"
set +e
/usr/bin/time -p uv run --no-sync --env-file "$root/.env" tradingagents \
  --ticker AAPL --date "$day" --analysts market,sentiment,news,fundamentals \
  --save --no-show --html > "$out/run.log" 2>&1
status=$?
set -e
printf '%s\n' "$status" > "$out/exit-code"
printf 'Outputs: %s\n' "$out"
if [[ "$status" -eq 0 ]]; then
  uv run --no-sync python "$root/read_run.py" "$out" "$day" "$rounds"
fi
exit "$status"
