#!/bin/bash
# Cursor 环境诊断脚本

echo "==================================="
echo "Cursor 环境诊断报告"
echo "==================================="
echo ""

echo "【1. 基本环境信息】"
echo "- 当前用户: $(whoami)"
echo "- 工作目录: $(pwd)"
echo "- Shell: $SHELL"
echo "- PATH: $PATH"
echo ""

echo "【2. 权限检查】"
echo "- 当前目录写权限: $(test -w . && echo '✓ 有' || echo '✗ 无')"
echo "- /tmp 目录写权限: $(test -w /tmp && echo '✓ 有' || echo '✗ 无')"
echo "- 可执行脚本: $(test -x /usr/bin/python3 && echo '✓ 是' || echo '✗ 否')"
echo ""

echo "【3. 进程信息】"
echo "- 进程 ID: $$"
echo "- 父进程 ID: $PPID"
echo "- 终端: $(tty 2>/dev/null || echo '无 TTY（可能在沙盒中）')"
echo ""

echo "【4. 文件系统测试】"
TEST_FILE="/tmp/cursor_test_$$"
if echo "test" > "$TEST_FILE" 2>/dev/null; then
    echo "- 创建文件: ✓ 成功"
    if cat "$TEST_FILE" > /dev/null 2>&1; then
        echo "- 读取文件: ✓ 成功"
    else
        echo "- 读取文件: ✗ 失败"
    fi
    rm -f "$TEST_FILE" 2>/dev/null && echo "- 删除文件: ✓ 成功" || echo "- 删除文件: ✗ 失败"
else
    echo "- 创建文件: ✗ 失败（沙盒限制）"
fi
echo ""

echo "【5. 网络检查】"
if command -v curl > /dev/null 2>&1; then
    echo "- curl 可用: ✓ 是"
    if timeout 2 curl -s -o /dev/null -w "%{http_code}" https://www.google.com 2>/dev/null | grep -q "200\|301\|302"; then
        echo "- 网络连接: ✓ 可用"
    else
        echo "- 网络连接: ✗ 受限或超时"
    fi
else
    echo "- curl 可用: ✗ 否"
fi
echo ""

echo "【6. 命令可用性】"
for cmd in python3 node npm git make cargo rustc; do
    if command -v $cmd > /dev/null 2>&1; then
        echo "- $cmd: ✓ $(command -v $cmd)"
    else
        echo "- $cmd: ✗ 未安装"
    fi
done
echo ""

echo "【7. 环境变量】"
echo "- HOME: $HOME"
echo "- USER: $USER"
echo "- TERM: $TERM"
echo "- CURSOR 相关变量:"
env | grep -i cursor || echo "  (无)"
echo ""

echo "==================================="
echo "诊断完成"
echo "==================================="
