# Twitter Collector API — reference (agent scope)

All paths are relative to `TWITTER_COLLECTOR_URL`. Send header `X-API-Key: $TWITTER_COLLECTOR_API_KEY`.

This reference lists **only** endpoints this skill expects agents to use (read path).

**Auth note:** With a typical API key, **GET** watchlist/tweet routes work. **POST/PATCH/DELETE** watchlist routes return `401 missing bearer token` on the current deployment. Group creation and membership edits are done by the operator in the console; agents receive `TWITTER_COLLECTOR_AGENT_GROUP_ID`.

## Errors

| HTTP | Typical cause |
|------|----------------|
| 401 | Missing/invalid credentials, or write route requiring JWT |
| 403 | Missing scope / not allowed |
| 404 | Resource missing for this tenant |
| 4xx/5xx | See JSON `detail` |

## Identity

### `GET /api/auth/api-key/me`

Connectivity / identity check.

## Watchlist (read)

### `GET /api/watchlist/groups`

List groups (awareness only). Do not mutate any of them.

### `GET /api/watchlist/groups-with-members`

Read-only overview.

### `GET /api/watchlist/groups/{group_id}/members`

Prefer `group_id=$TWITTER_COLLECTOR_AGENT_GROUP_ID`.

### `GET /api/watchlist/targets`

Optional read of targets.

## Tweets

### `GET /api/tweets`

| Query | Notes |
|-------|--------|
| `page` | Default `1` |
| `page_size` | Default `20`, max `100`; keep small |
| `q` | Text search |
| `tweet_type` | Optional type filter |
| `group_id` | Use **`$TWITTER_COLLECTOR_AGENT_GROUP_ID`** |
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

- Any `POST` / `PATCH` / `DELETE` under `/api/watchlist/**`
- `/api/workflows/**`
- `/api/reports/**`
- `/api/user-feed/**`
- `/api/jobs/**`
- `/api/admin/**`
- `/api/graph/**`
- Any endpoint that “runs”, “generates”, or schedules tasks
