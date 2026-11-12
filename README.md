# twitter-collector-api

Agent Skill repository (standalone Git repo). Suggested remote name: `twitter-collector-api`.

## Important notice

**This skill depends on our private / local Twitter Collector system. This is not a public, ready-to-use service.**

- This repository does **not** include a reachable service URL. Cloning it alone does **not** let outsiders use the API.
- It is only useful to authorized callers who already have API access and configure the required environment variables themselves.
- Do not treat this repository as a public SaaS or open API.

## What this skill allows

- Create **your own** watchlist group
- Edit **only that** group’s account list
- Fetch collected tweets for your group
- Keep category taxonomies in the **agent’s local workspace**

Collection is **periodic** (not live). Engagement metrics are snapshots and go stale — see `SKILL.md`.

## Out of scope

- Other groups
- Workflows, reports, graphs, feeds
- Collect jobs / task execution / admin APIs

## Setup (authorized caller only)

| Variable | Required | Description |
|----------|----------|-------------|
| `TWITTER_COLLECTOR_URL` | Yes | API base URL, **no trailing slash** |
| `TWITTER_COLLECTOR_API_KEY` | Yes | API key (`tc_…`) |
| `TWITTER_COLLECTOR_PROTECTED_GROUP_IDS` | No | Extra group IDs that must never be modified |
| `TWITTER_COLLECTOR_AGENT_GROUP_ID` | No | Your agent-owned group id after create |

Copy `.env.example` as a template. Never commit real URLs or keys.

Point your agent runtime at this skill directory (or the published repo) per that runtime’s skill-loading docs.

## Layout

| Path | Purpose |
|------|---------|
| [`SKILL.md`](SKILL.md) | Agent instructions |
| [`reference.md`](reference.md) | Allowed HTTP endpoints |
| [`scripts/request.sh`](scripts/request.sh) | Optional curl helper |

## Security

- Omits production hostnames and internal infrastructure details.
- Callers supply credentials via environment variables only.
