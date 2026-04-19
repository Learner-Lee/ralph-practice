#!/bin/bash
# Ralph Loop 练习脚本（模块1版本）
MAX=${1:-5}   # 默认最多跑5轮，可传参：bash loop.sh 3
COUNT=0

echo "==============================="
echo " Ralph Loop 启动"
echo " 最大轮数：$MAX"
echo " 任务文件：PROMPT.md"
echo "==============================="

while [ $COUNT -lt $MAX ]; do
  COUNT=$((COUNT + 1))
  echo ""
  echo "-------------------------------"
  echo " 第 $COUNT 轮 / 最多 $MAX 轮"
  echo "-------------------------------"

  cat PROMPT.md | claude -p --allowedTools "Bash Edit Write Read Glob Grep"

  echo ""
  echo "[第 $COUNT 轮完成]"

  # 检查完成标志
  if [ -f "progress.md" ] && head -1 progress.md | grep -q "^DONE"; then
    echo ""
    echo ">>> 任务完成！退出循环。"
    break
  fi

  echo ">>> 未检测到完成标志，继续下一轮..."
done

echo ""
echo "==============================="
echo " 循环结束，共跑了 $COUNT 轮"
echo "==============================="
