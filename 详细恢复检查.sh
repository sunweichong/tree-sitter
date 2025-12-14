#!/bin/bash

echo "=== 详细代码恢复检查 ==="
echo ""

# 检查是否有未提交的更改被覆盖
echo "1. 检查工作目录和索引的差异..."
git diff HEAD
echo ""

# 检查是否有未暂存的更改
echo "2. 检查未暂存的更改..."
git diff
echo ""

# 检查所有已删除但可能恢复的文件
echo "3. 查找所有可能恢复的已删除文件..."
git log --all --full-history --diff-filter=D --summary | grep "delete mode" | head -30
echo ""

# 检查最近的提交中是否有大量文件更改
echo "4. 检查最近提交的文件更改统计..."
git log --all --stat -10 | head -100
echo ""

# 检查是否有悬空提交
echo "5. 检查悬空提交（可能包含丢失的代码）..."
git fsck --unreachable --no-progress 2>&1 | grep "unreachable commit" | head -20
echo ""

# 检查是否有悬空对象
echo "6. 检查悬空对象..."
dangling_objects=$(git fsck --no-progress 2>&1 | grep "dangling" | wc -l)
echo "发现 $dangling_objects 个悬空对象"
if [ "$dangling_objects" -gt 0 ]; then
    echo "这些对象可能包含丢失的代码，可以使用以下命令检查："
    echo "  git show <object-hash>"
fi
echo ""

# 检查当前分支和 master 的差异
echo "7. 比较当前分支和 master..."
git diff master..HEAD --name-status
echo ""

# 检查是否有其他本地分支
echo "8. 检查本地分支..."
git branch -vv
echo ""

echo "=== 恢复建议 ==="
echo ""
echo "如果代码在某个提交中："
echo "  git log --all --oneline | grep <关键词>"
echo "  git checkout <commit-hash>"
echo ""
echo "如果代码被意外删除："
echo "  git log --all --full-history -- <file-path>"
echo "  git checkout <commit-hash> -- <file-path>"
echo ""
echo "如果代码从未提交："
echo "  - 检查 Cursor 的本地历史（如果有）"
echo "  - 检查系统回收站"
echo "  - 检查临时文件目录"
