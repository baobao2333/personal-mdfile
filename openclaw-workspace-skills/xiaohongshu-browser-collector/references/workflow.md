# Workflow

## 1) Open and load
- Open RED search URL with encoded keyword using browser tool with `target="node"` (paired host node).
- Wait 3-5s.
- If page shows login wall/captcha, record blocker and stop.

## 2) Snapshot and extract
From each card region, extract:
- title
- author name
- relative date/time text
- like count text
- note URL (contains `/search_result/<id>`)

## 3) Scroll pagination
- Run evaluate scroll to bottom.
- Wait 2-3s.
- Repeat 2-4 rounds.
- Snapshot after each round.

## 4) Merge and de-duplicate
- Build key using note id from URL.
- Keep first appearance order.

## 5) Quality gates
- At least 15 unique notes for Top20 target; otherwise mark partial.
- Link must be present for each retained row.
- Unknown fields set `N/A` and counted in `风险与备注`.

## 6) Failure handling
- login required: `BLOCKED_LOGIN`
- captcha/human check: `BLOCKED_CAPTCHA`
- render timeout: `BLOCKED_RENDER_TIMEOUT`
- extraction < 5 rows: `BLOCKED_LOW_RECALL`
