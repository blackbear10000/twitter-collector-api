---
name: twitter-collector-api
description: >-
  Uses the Twitter Collector HTTP API so an agent can create its own watchlist
  group, maintain that group's account list, and fetch collected tweets. Use when
  monitoring Twitter/X accounts or reading collected posts via
  TWITTER_COLLECTOR_URL and TWITTER_COLLECTOR_API_KEY. Does not run workflows,
  generate reports, or modify other groups.
---

# Twitter Collector API

Caller-facing skill for a **narrow** slice of the Twitter Collector HTTP API:
create **your own** watchlist group, edit **only that** group's membership, and
fetch tweets. Base URL and credentials come **only** from the caller environment.

## Environment

| Variable | Required | Meaning |
|----------|----------|---------|
| `TWITTER_COLLECTOR_URL` | Yes | API base URL, no trailing slash (placeholder shape only: `https://example.com`) |
| `TWITTER_COLLECTOR_API_KEY` | Yes | API key (`tc_…`) |
| `TWITTER_COLLECTOR_PROTECTED_GROUP_IDS` | No | Extra group IDs that must never be modified |
| `TWITTER_COLLECTOR_AGENT_GROUP_ID` | No | Your agent-owned group id once created (prefer persisting this locally) |

If a required variable is missing, stop and ask the operator to set it. Do not invent a URL.

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

- Keep any **category / taxonomy / labeling checklist** in the **agent’s local workspace** (files you own), not by reshaping other people’s watchlist groups.
- Use the remote API group only as the **account watch set** for collection/query. Map categories locally (e.g. handle → category) in your own notes or config.

## Hard rules (must follow)

1. **Create and use your own watchlist group.** Prefer a distinctive name (include agent or project name). Persist the group `id` locally (env or workspace file). Reuse it on later runs; do not keep creating duplicates without checking first.
2. **Never modify other groups.** Do not rename, disable, delete, or change membership of groups you did not create. Treat `TWITTER_COLLECTOR_PROTECTED_GROUP_IDS` and any shared/public/common groups as immutable. Listing other groups for awareness is OK; mutating them is not.
3. **Allowed remote actions only:**
   - create your own group (if missing)
   - add/update/remove accounts **in your own group**
   - fetch tweets (prefer `group_id=<your group>`)
   - optional: `GET /api/auth/api-key/me` to verify credentials
4. **Forbidden:** workflows, reports, user-feed summaries, graphs, collect/jobs triggers, admin APIs, or any “run task / execute pipeline” style endpoints.
5. Do not log, commit, or echo the full API key.
6. Keep tweet responses small (`page_size` ≤ 20 unless the user asks for more; max 100).

## Allowed operations

Detail: [reference.md](reference.md).

### Identity

- `GET /api/auth/api-key/me`

### Own watchlist group

- `GET /api/watchlist/groups` — find whether your group already exists
- `POST /api/watchlist/groups` — body `{"name":"<your distinctive name>"}` when missing
- `GET /api/watchlist/groups/{group_id}/members` — only for **your** group id
- `GET /api/watchlist/groups-with-members` — read-only overview; mutate only your group afterward

### Edit your own watch list

- `POST /api/watchlist/targets` — include `group_ids: [<your_group_id>]`
- `PATCH /api/watchlist/targets/{target_id}` — only targets that belong to your group
- `POST /api/watchlist/groups/{group_id}/members` — only your group
- `DELETE` member removal on your group only (see reference)
- `POST /api/watchlist/targets/bulk-import` — only with `group_id` set to **your** group

### Tweets

- `GET /api/tweets` — filter with `group_id=<your_group_id>` whenever possible

## Suggested workflow

1. Confirm env vars.
2. Verify credentials with `GET /api/auth/api-key/me`.
3. Resolve your group: use `TWITTER_COLLECTOR_AGENT_GROUP_ID` if set; else list groups, match your name, or create one and save the id locally.
4. Maintain category taxonomy **locally**; sync account handles into **your** group only.
5. Query tweets for your `group_id`. Treat engagement fields as possibly stale.
6. Never touch other groups; never call workflow/report/job endpoints.

## Out of scope

- Other groups’ membership or metadata
- Workflows, reports, graphs, feeds, collect jobs, admin
- Hardcoding real deployment URLs or secrets in this repo
