#!/bin/bash
# Ralph Loop 生产版 v2
# 用法：bash loop.sh [plan|build] [最大轮数] [--push]
#   bash loop.sh plan 1          # 规划模式，跑 1 轮
#   bash loop.sh build 10        # 执行模式，最多 10 轮
#   bash loop.sh build 10 --push # 执行模式，每轮结束自动 git push

set -euo pipefail   # 任何命令失败立即退出，未定义变量报错

MODE=${1:-build}
MAX=${2:-10}
PUSH=${3:-""}
PROMPT_FILE="PROMPT_${MODE}.md"
COUNT=0
TOTAL_TIME=0

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # 无颜色

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 前置检查
if [ ! -f "$PROMPT_FILE" ]; then
  log_error "找不到 $PROMPT_FILE，退出。"
  exit 1
fi

if ! command -v claude &> /dev/null; then
  log_error "找不到 claude 命令，请确认 Claude Code 已安装。"
  exit 1
fi

echo "========================================"
log_info "Ralph Loop 启动"
log_info "模式：$MODE | 最大轮数：$MAX | 自动推送：${PUSH:-否}"
echo "========================================"

while [ $COUNT -lt $MAX ]; do
  COUNT=$((COUNT + 1))
  ROUND_START=$(date +%s)

  echo ""
  echo "----------------------------------------"
  log_info "第 $COUNT 轮 / 最多 $MAX 轮 [$MODE 模式] — $(date '+%H:%M:%S')"
  echo "----------------------------------------"

  # 核心：把 PROMPT 喂给 claude
  cat "$PROMPT_FILE" | claude -p --allowedTools "Bash Edit Write Read Glob Grep"

  ROUND_END=$(date +%s)
  ROUND_SEC=$((ROUND_END - ROUND_START))
  TOTAL_TIME=$((TOTAL_TIME + ROUND_SEC))

  log_info "第 $COUNT 轮耗时：${ROUND_SEC}s | 累计：${TOTAL_TIME}s"

  # 可选：自动 git push
  if [ "$PUSH" = "--push" ]; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
    git push origin "$BRANCH" 2>/dev/null && log_info "已推送到 origin/$BRANCH" || log_warn "git push 失败（可能没有远端），继续。"
  fi

  # plan 模式只跑一轮
  if [ "$MODE" = "plan" ]; then
    log_info "规划完成。请运行：bash loop.sh build"
    break
  fi

  # build 模式检查完成标志
  if grep -q "^DONE" IMPLEMENTATION_PLAN.md 2>/dev/null; then
    echo ""
    log_info "所有任务完成！循环退出。"
    break
  fi

  log_info "未检测到完成标志，继续下一轮..."
done

echo ""
echo "========================================"
log_info "循环结束 | 共跑 $COUNT 轮 | 总耗时 ${TOTAL_TIME}s"
echo "========================================"
