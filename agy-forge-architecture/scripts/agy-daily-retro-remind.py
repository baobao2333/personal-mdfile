#!/usr/bin/env python3
"""Generate a read-only daily coding & Forge stats brief and send a macOS evening retro notification."""

from __future__ import annotations

import datetime
import json
import os
import sqlite3
import subprocess
from pathlib import Path


def _escape_osascript(text: str) -> str:
    return text.replace("\\", "\\\\").replace('"', '\\"').replace("\r", " ").replace("\n", " ")


def _notify(title: str, subtitle: str, message: str, sound: str = "Glass") -> None:
    script = (
        f'display notification "{_escape_osascript(message)}" '
        f'with title "{_escape_osascript(title)}" '
        f'subtitle "{_escape_osascript(subtitle)}" '
        f'sound name "{_escape_osascript(sound)}"'
    )
    subprocess.run(["/usr/bin/osascript", "-e", script], capture_output=True, check=False)


def _count_sessions_today(today_utc_prefix: str, today_local: datetime.date) -> int:
    seen: set[str] = set()
    start_utc = (
        datetime.datetime.combine(today_local, datetime.time.min)
        .astimezone(datetime.timezone.utc)
        .strftime("%Y-%m-%d %H:%M:%S")
    )
    for db_rel in (".gemini/antigravity/conversation_summaries.db", ".gemini/antigravity-cli/conversation_summaries.db"):
        db_path = Path.home() / db_rel
        if not db_path.exists():
            continue
        try:
            conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True, timeout=2.0)
            cur = conn.cursor()
            cur.execute(
                """
                SELECT conversation_id, preview
                FROM conversation_summaries
                WHERE nesting_depth = 0
                  AND last_modified_time >= ?
                """,
                (start_utc,),
            )
            for cid, preview in cur.fetchall():
                if preview and "forge-arbiter" in preview:
                    continue
                seen.add(cid)
            conn.close()
        except Exception:
            continue
    return len(seen)


def _forge_stats_today(today_str: str) -> tuple[int, float, int, list[str]]:
    logs_dir = Path.home() / "forge" / "logs"
    if not logs_dir.is_dir():
        return 0, 0.0, 0, []
    count = 0
    total_min = 0.0
    multi_round = 0
    highlights: list[str] = []
    for entry in sorted(logs_dir.iterdir(), key=lambda p: p.stat().st_mtime):
        if not entry.is_dir() or entry.name.startswith("."):
            continue
        files = [f for f in entry.iterdir() if f.is_file()]
        if not files:
            continue
        end_ts = max(f.stat().st_mtime for f in files)
        if datetime.datetime.fromtimestamp(end_ts).strftime("%Y-%m-%d") != today_str:
            continue
        run_files = [f for f in files if f.name != "base" and not f.name.startswith(".")] or files
        start_ts = min(f.stat().st_mtime for f in run_files)
        dur = max(0.1, (end_ts - start_ts) / 60.0)
        count += 1
        total_min += dur
        if (entry / "round-2.txt").exists():
            multi_round += 1
        highlights.append(f"- `{entry.name}`：{dur:.1f} 分钟")
    return count, total_min, multi_round, highlights


def main() -> int:
    now = datetime.datetime.now().astimezone()
    today_str = now.strftime("%Y-%m-%d")
    sessions_cnt = _count_sessions_today(now.astimezone(datetime.timezone.utc).strftime("%Y-%m-%d"), now.date())
    forge_cnt, forge_min, multi_cnt, highlights = _forge_stats_today(today_str)

    if sessions_cnt == 0 and forge_cnt == 0:
        # Quiet day with zero activity: skip noisy notification.
        return 0

    avg_min = (forge_min / forge_cnt) if forge_cnt else 0.0
    out_dir = Path.home() / ".gemini" / "antigravity-cli" / "daily-retro"
    out_dir.mkdir(parents=True, exist_ok=True)
    brief_path = out_dir / f"retro-{today_str}.md"

    lines = [
        f"# 每日工作复盘速览（{today_str}）",
        "",
        f"- 生成时间：{now.strftime('%Y-%m-%d %H:%M:%S %Z')}",
        f"- 今日活跃主会话：**{sessions_cnt}** 个",
        f"- 今日 Forge 任务：**{forge_cnt}** 单（累计 {forge_min:.1f} 分钟，单均 {avg_min:.1f} 分钟，多轮 {multi_cnt}/{forge_cnt}）",
        "",
        "## 建议复盘三问",
        "1. 今天哪些改动仍靠人工测试/线上巡检兜底？能否沉淀为 <10s 契约单测？",
        "2. 今天是否存在拖慢节奏的重复审查或无效返工？",
        "3. 巡检脚本与自动化工具链今天是否有误报/漏报需要微调？",
    ]
    if highlights:
        lines.extend(["", "## 今日 Forge 任务明细", *highlights[-15:]])
    brief_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    subtitle = f"今日 {sessions_cnt} 个会话 · Forge {forge_cnt} 单 (均值 {avg_min:.1f}m)"
    msg = "花 5 分钟在 AGY 发一句「复盘一下今日工作」，沉淀经验与提效点 ✨"
    _notify("AGY 每日研发复盘提醒", subtitle, msg, sound="Glass")
    print(json.dumps({"date": today_str, "sessions": sessions_cnt, "forge_tasks": forge_cnt, "brief": str(brief_path)}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
