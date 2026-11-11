"""Extract the final rating and wall-clock time from one successful run."""
import json
import re
import sys
from pathlib import Path

folder, date, rounds = sys.argv[1:]
path = Path(folder)
state_path = path / "AAPL" / "TradingAgentsStrategy_logs" / f"full_states_log_{date}.json"
state = json.loads(state_path.read_text())
if (
    state["company_of_interest"] != "AAPL"
    or state["trade_date"] != date
    or state["run_settings"]["max_debate_rounds"] != int(rounds)
):
    raise SystemExit("The saved state does not match the requested run.")
timer = re.search(r"^real ([0-9.]+)$", (path / "run.log").read_text(), re.M)
if not timer:
    raise SystemExit("Wall-clock time is missing from run.log.")
print(f"AAPL,{date},{rounds},{state['final_rating']},{timer.group(1)}")
