# Twitter Collector API — reference (agent scope)

All paths are relative to `TWITTER_COLLECTOR_URL`. Send header `X-API-Key: $TWITTER_COLLECTOR_API_KEY`.

This reference lists **only** endpoints this skill expects agents to use: own group, own watch list, tweets.

## Errors

| HTTP | Typical cause |
|------|----------------|
| 401 | Missing/invalid credentials |
| 403 | Missing scope / not allowed |
| 404 | Resource missing for this tenant |
| 409 | Conflict (e.g. duplicate group name) |
| 4xx/5xx | See JSON `detail` |

## Identity

### `GET /api/auth/api-key/me`

Connectivity / identity check.

## Watchlist groups

### `GET /api/watchlist/groups`

List groups. Use to find your agent-owned group by name before creating another.

### `POST /api/watchlist/groups`

```json
{ "name": "agent-<your-unique-name>" }
```

Create **your** group only. Use a distinctive name. Persist the returned `id`.

### `GET /api/watchlist/groups/{group_id}/members`

List members. Call only for **your** group id.

### `GET /api/watchlist/groups-with-members`

Read-only overview. Do not use discovered foreign group ids as mutation targets.

### `POST /api/watchlist/groups/{group_id}/members`

```json
{ "target_ids": [1, 2] }
```

Only for **your** `group_id`.

### `DELETE /api/watchlist/groups/{group_id}/members`

```json
{ "target_ids": [1, 2] }
```

Only for **your** `group_id`. (Send JSON body with `Content-Type: application/json`.)

Do **not** `PATCH`/`DELETE` the group resource for any group you do not own. Do not disable or rename other groups.

## Targets (accounts)

### `POST /api/watchlist/targets`

```json
{
  "twitter_handle": "example",
  "notes": null,
  "disabled": false,
  "group_ids": [<your_group_id>],
  "manual_score_boost": 0
}
```

Always attach **your** group id. Do not pass other groups’ ids.

### `PATCH /api/watchlist/targets/{target_id}`

Update handle/notes/disabled/`group_ids` only for targets in **your** group. Never reassign targets into/out of other groups.

### `POST /api/watchlist/targets/bulk-import`

```json
{
  "handles": ["alice", "bob"],
  "group_id": <your_group_id>
}
```

`group_id` must be **yours**.

### `GET /api/watchlist/targets`

Optional read of targets. Prefer group members endpoints when working from your group.

## Tweets

### `GET /api/tweets`

| Query | Notes |
|-------|--------|
| `page` | Default `1` |
| `page_size` | Default `20`, max `100`; keep small |
| `q` | Text search |
| `tweet_type` | Optional type filter |
| `group_id` | Prefer **your** group id |
| `ungrouped_only` | Avoid unless explicitly needed |
| `target_id` | Optional single target |
| `start_time` / `end_time` | Window as accepted by the API |
| `include_noise` | Default `false` |
| `sort_by` | Default `created_at` |
| `sort_order` | Default `desc` |

Example item fields (extras may appear; treat unknown fields as opaque):

```json
{
  "tweet_id": "...",
  "author_twitter_id": "...",
  "author_handle": "...",
  "author_name": "...",
  "tweet_type": "...",
  "text": "...",
  "created_at_twitter": "...",
  "like_count": 0,
  "retweet_count": 0,
  "reply_count": 0,
  "quote_count": 0,
  "view_count": 0,
  "bookmark_count": 0,
  "collected_at": "...",
  "is_noise": false
}
```

**Freshness:** engagement counts are collect-time snapshots and become outdated. Prefer text + timestamps over stale metrics.

## Explicitly out of scope (do not call)

- `/api/workflows/**`
- `/api/reports/**`
- `/api/user-feed/**`
- `/api/jobs/**`
- `/api/admin/**`
- `/api/graph/**` (standalone)
- Any endpoint that “runs”, “generates”, or schedules tasks
