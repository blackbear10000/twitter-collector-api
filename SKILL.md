---
name: twitter-collector-api
description: >-
  Uses the Twitter Collector HTTP API so an agent can read its assigned
  watchlist group and fetch collected tweets. Use when monitoring Twitter/X
  accounts or reading collected posts via TWITTER_COLLECTOR_URL and
  TWITTER_COLLECTOR_API_KEY. Does not create groups, edit other groups, run
  workflows, generate reports, or execute jobs.
---

# Twitter Collector API

Caller-facing skill for a **narrow, mostly read-only** slice of the Twitter
Collector HTTP API. Base URL and credentials come **only** from the caller
environment.

**Current deployment constraint:** API keys are accepted on **read** routes.
Watchlist **writes** (create group, add/remove members, create targets) require
a user JWT and are **out of band** for this skill. The operator creates the
agent’s group in the console and passes the id via env.

## Environment

| Variable | Required | Meaning |
|----------|----------|---------|
| `TWITTER_COLLECTOR_URL` | Yes | API base URL, no trailing slash (placeholder shape only: `https://example.com`) |
| `TWITTER_COLLECTOR_API_KEY` | Yes | API key (`tc_…`) |
| `TWITTER_COLLECTOR_AGENT_GROUP_ID` | Yes | Operator-created group id reserved for this agent |
| `TWITTER_COLLECTOR_PROTECTED_GROUP_IDS` | No | Extra group IDs that must never be modified |

If a required variable is missing, stop and ask the operator to set it. Do not invent a URL or group id.

```http
X-API-Key: ${TWITTER_COLLECTOR_API_KEY}
```

Optional helper: [`scripts/request.sh`](scripts/request.sh)

## Data freshness (read carefully)

- Collection is **periodic**, not realtime. Tweet text and timelines can lag behind live Twitter/X.
- Counts such as likes, reposts, replies, quotes, views, and bookmarks are **snapshots from collect time**. They are **not** kept live and will go stale.
- Prefer tweet **text**, author, and `created_at_twitter` / `collected_at` for reasoning.
- **Do not** treat outdated engagement metrics as current signal, and do not build conclusions that depend on “live” virality from this API.

## Local category list

- Keep any **category / taxonomy / labeling checklist** in the **agent’s local workspace** (files you own), not by reshaping watchlist groups on the server.
- Use the remote API group only as the **account watch set** for query. Map categories locally (e.g. handle → category).

## Hard rules (must follow)

1. **Use only `TWITTER_COLLECTOR_AGENT_GROUP_ID`.** Do not create a new group via API. Do not pick another existing group as “yours.”
2. **Never modify other groups** (or any group via write APIs from this skill). Treat all non-agent groups and `TWITTER_COLLECTOR_PROTECTED_GROUP_IDS` as immutable. Listing groups for awareness is OK; mutating is not.
3. **Do not call watchlist write endpoints** (`POST`/`PATCH`/`DELETE` under `/api/watchlist/...`). If membership must change, ask the operator to edit the agent group in the console.
4. **Allowed remote actions only:**
   - `GET /api/auth/api-key/me`
   - list/read groups and members (read-only)
   - `GET /api/tweets` with `group_id=<TWITTER_COLLECTOR_AGENT_GROUP_ID>`
5. **Forbidden:** workflows, reports, user-feed summaries, graphs, collect/jobs triggers, admin APIs, or any “run task / execute pipeline” endpoint.
6. Do not log, commit, or echo the full API key.
7. Keep tweet responses small (`page_size` ≤ 20 unless the user asks for more; max 100).

## Allowed operations

Detail: [reference.md](reference.md).

### Identity

- `GET /api/auth/api-key/me`

### Watchlist (read)

- `GET /api/watchlist/groups`
- `GET /api/watchlist/groups-with-members`
- `GET /api/watchlist/groups/{group_id}/members` — prefer your agent group id
- `GET /api/watchlist/targets`

### Tweets

- `GET /api/tweets` — filter with `group_id=$TWITTER_COLLECTOR_AGENT_GROUP_ID`

## Suggested workflow

1. Confirm env vars, including `TWITTER_COLLECTOR_AGENT_GROUP_ID`.
2. Verify credentials with `GET /api/auth/api-key/me`.
3. Optionally `GET /api/watchlist/groups/{id}/members` for the agent group.
4. Maintain category taxonomy **locally**.
5. Query tweets for the agent `group_id`. Treat engagement fields as possibly stale.
6. If the user wants accounts added/removed, tell them the operator must update that group in the console (API key cannot write).

## Out of scope

- Creating or editing watchlist groups/members via API
- Other groups’ membership or metadata
- Workflows, reports, graphs, feeds, collect jobs, admin
- Hardcoding real deployment URLs or secrets in this repo
