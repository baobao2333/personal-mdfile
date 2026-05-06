---
name: xiaohongshu-browser-collector
description: Collect and summarize Xiaohongshu (RED) public notes via browser automation without MCP. Use when user wants keyword monitoring, trend scanning, Top-N note extraction, or daily Xiaohongshu reports. Focus on read-only collection (no publish/like/comment).
---

# Xiaohongshu Browser Collector

Use browser-first workflow to collect public RED search results and note metadata.

## Hard constraints

- Keep this skill read-only: do not publish, like, comment, or favorite.
- Collect only public content visible in web pages.
- Never store passwords/cookies/tokens in files.
- If login/captcha blocks collection, return a clear blocker and stop.
- Always run browser actions on the paired host node: set `target="node"` for browser tool calls in this workflow.

## Quick workflow

1. Open search page:
   - `https://www.xiaohongshu.com/search_result?keyword=<kw>&source=web_explore_feed`
   - Browser tool call must include `target="node"` (do not use `target="host"` here).
2. Wait for rendering, then snapshot with `refs="aria"`.
3. Extract initial cards (title, author, relative date, likes, note link).
4. Scroll 2-4 times, snapshot again, merge results.
5. De-duplicate by note id from URL path `/search_result/<noteId>`.
6. Keep Top N (default 20) by page order.
7. Output markdown table and short insights.

## Output format

- Section 1: `采集参数` (keyword, time, N, collected count)
- Section 2: `Top N 笔记` table
  - `序号 | 标题 | 作者 | 时间 | 互动(赞) | 链接`
- Section 3: `主题观察` (3-5 bullets)
- Section 4: `风险与备注`

## References

- Read `references/workflow.md` for detailed steps and anti-failure handling.
- Read `references/schema.md` for output schema and quality checklist.
