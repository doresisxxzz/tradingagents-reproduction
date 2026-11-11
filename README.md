# TradingAgents AAPL Debate Reproduction

FTEC5660 individual reproducibility project. This experiment reproduces the
role-based AAPL workflow illustrated in Appendix 8.4 of the
[TradingAgents paper](https://arxiv.org/abs/2412.20138) and compares one versus
two research debate rounds over five historical dates.

## Setup

The original runs used macOS, Python 3.12.14, uv, and hosted DeepSeek V4 Flash.
You need Git, Bash, uv, an active DeepSeek API key, and access to the market
data providers. These steps assume you are in this repository's root directory.

```bash
git clone https://github.com/TauricResearch/TradingAgents.git upstream
git -C upstream checkout 9fa1196fffbcfd9de5146d2dd2869df84ab99838
cp uv.lock upstream/uv.lock
(cd upstream && uv sync --locked --python 3.12.14)
cp .env.example .env
```

Edit the local `.env` file and fill in `DEEPSEEK_API_KEY`. Git ignores that
file. Keep the key local. No FRED key was configured in the original runs.

## Run the comparison

Start with the paper's example date:

```bash
bash run.sh 2024-11-19 1
bash run.sh 2024-11-19 2
```

Run the five dates sequentially:

```bash
for day in 2024-11-13 2024-11-14 2024-11-15 2024-11-18 2024-11-19; do
  bash run.sh "$day" 1 || break
  bash run.sh "$day" 2 || break
done
```

Each invocation writes a fresh folder under `runs/`. It prints the final rating
and elapsed seconds on success. The folder also contains the command log, saved
state, and complete report. The script sets `max_debate_rounds` to the requested
value through `TRADINGAGENTS_MAX_DEBATE_ROUNDS`. Both settings use the market,
sentiment, news and fundamentals analysts, the same quick and deep model, and one
risk discussion round.

## Recorded results

[results.csv](results.csv) contains the ten successful runs from the report.
Ratings differed on two of five dates. The mean elapsed times were 374.31
seconds for one round and 475.46 seconds for two rounds. Times include the
complete command, including model and data requests and any in-process retries.

[evidence/](evidence/) includes selected fields from the two November 13 saved
states: run settings, final rating, and actual research debate history. The
one-round run returned Hold and the two-round run returned Underweight.

The original runs scheduled different dates concurrently and started from
copies of a pilot cache. The commands above start with fresh per-run caches and
the loop runs sequentially. Model sampling, provider availability, cache state
and concurrency can affect ratings and latency. Historical news and sentiment
feeds were unavailable in the pilot. The November 15 one-round attempt failed
on an empty model response and was restarted. The CSV includes the successful
attempt's timing. This comparison evaluates the workflow, ratings and elapsed
time. The paper's portfolio-return simulation is outside its scope.
