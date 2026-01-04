#!/bin/bash
# 安全命令执行包装器 - 避免随机沙盒错误
# 用法: safe_exec.sh "你的命令"

set -euo pipefail

# 颜色定义（即使在 dumb terminal 也能工作）
SUCCESS="[SUCCESS]"
FAILED="[FAILED]"
INFO="[INFO]"

echo "$INFO 开始执行命令..."
echo "$INFO 命令: $*"
echo "$INFO 时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "---"

# 执行命令并捕获退出码
set +e
eval "$@"
EXIT_CODE=$?
set -e

echo "---"
echo "$INFO 退出码: $EXIT_CODE"

if [ $EXIT_CODE -eq 0 ]; then
    echo "$SUCCESS 命令执行成功！"
    # 强制刷新输出
    sync
    sleep 0.1
else
    echo "$FAILED 命令执行失败！"
fi

# 返回原始退出码
exit $EXIT_CODE
