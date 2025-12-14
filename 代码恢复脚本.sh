#!/bin/bash

echo "=== 代码恢复诊断脚本 ==="
echo ""

echo "1. 检查 Git 状态..."
git status
echo ""

echo "2. 检查最近的 reflog 记录..."
git reflog --all -30
echo ""

echo "3. 检查所有分支..."
git branch -a
echo ""

echo "4. 检查是否有 stash..."
git stash list
if [ $? -eq 0 ] && [ -n "$(git stash list)" ]; then
    echo "发现 stash，可以使用 'git stash pop' 恢复"
fi
echo ""

echo "5. 检查最近删除的文件..."
git log --diff-filter=D --summary --oneline -20
echo ""

echo "6. 检查未跟踪的文件..."
git status -u
echo ""

echo "7. 检查 .git/objects 完整性..."
git fsck --no-progress 2>&1 | head -20
echo ""

echo "8. 检查 Cursor 相关目录..."
if [ -d ".cursor" ]; then
    echo "发现 .cursor 目录:"
    ls -la .cursor/
else
    echo "未发现 .cursor 目录"
fi
echo ""

echo "9. 检查最近的提交历史..."
git log --all --oneline --graph -20
echo ""

echo "=== 诊断完成 ==="
echo ""
echo "建议操作："
echo "1. 如果发现丢失的提交在 reflog 中，使用: git checkout <commit-hash>"
echo "2. 如果有 stash，使用: git stash pop"
echo "3. 检查其他分支: git checkout <branch-name>"
echo "4. 恢复已删除的文件: git checkout <commit-hash> -- <file-path>"
