#!/usr/bin/env bash
set -euo pipefail

INTERVAL="${1:-10m}"
WINDOW="${2:-20}"
NAME="${3:-weibo-fresh-posts}"

PROMPT_DIR="${HOME}/.openclaw/prompts"
PROMPT_FILE="${PROMPT_DIR}/${NAME}.prompt"

mkdir -p "${PROMPT_DIR}"

cat > "${PROMPT_FILE}" <<PROMPT
浣跨敤 weibo-fresh-posts 鎶€鑳姐€?瑕佹眰锛?1) 浣跨敤 browser 鐨?profile=openclaw銆乼arget=node 鎵撳紑 https://weibo.com銆?2) 鎶撳彇鍓嶅繀椤荤偣鍑诲乏渚р€滄渶鏂板井鍗氣€濄€?3) 鎸夊彂甯栨椂闂村啓鍏?YYYY-MM-DD HH:mm锛岀姝娇鐢ㄦ姄鍙栨椂闂淬€?4) 鍙戝笘鍐呭鍒楀繀椤诲啓鍘熷璐存枃姝ｆ枃锛屼笉鑳藉啓鎴愭€荤粨銆?5) 鑻ュ崱鐗囨鏂囪鎴柇锛岃繘鍏ュ師甯栬鎯呮彁鍙栧畬鏁存鏂囥€?6) 鎶撳彇绐楀彛涓烘渶杩?${WINDOW} 鍒嗛挓銆?7) 鎸夊師濮嬮摼鎺ュ幓閲嶏紝鍐欏叆 ~/weibo-digest/YYYY-MM-DD.md銆?PROMPT

openclaw cron add \
  --name "${NAME}" \
  --every "${INTERVAL}" \
  --session isolated \
  --message "$(cat "${PROMPT_FILE}")" \
  --timeout-seconds 240 \
  --no-deliver

echo "宸插垱寤哄畾鏃朵换鍔?'${NAME}'锛岄棿闅?${INTERVAL}銆?
echo "鎻愮ず璇嶆枃浠讹細${PROMPT_FILE}"

