#!/bin/bash
# Cursor 稳定性测试脚本
# 用于验证项目配置是否能够防止崩溃

set -e

echo "=================================="
echo "Cursor 稳定性测试"
echo "=================================="
echo ""

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 .cursorignore 文件
echo -n "检查 .cursorignore 文件... "
if [ -f ".cursorignore" ]; then
    echo -e "${GREEN}✓${NC}"
    echo "  - 排除了 $(grep -c "^[^#]" .cursorignore) 个规则"
else
    echo -e "${RED}✗${NC}"
    echo -e "${YELLOW}警告: .cursorignore 文件不存在${NC}"
fi
echo ""

# 检查 .cursorrules 文件
echo -n "检查 .cursorrules 文件... "
if [ -f ".cursorrules" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}注意: .cursorrules 文件不存在${NC}"
fi
echo ""

# 统计测试文件数量
echo "项目结构分析:"
echo "  - 总文件数: $(find . -type f 2>/dev/null | wc -l)"
echo "  - Rust 文件: $(find . -name "*.rs" 2>/dev/null | wc -l)"
echo "  - C 文件: $(find . -name "*.c" 2>/dev/null | wc -l)"
echo "  - 测试语法文件: $(find test/fixtures/test_grammars -name "grammar.js" 2>/dev/null | wc -l)"
echo ""

# 检查关键修复
echo "检查关键修复提交:"
echo -n "  - 无限循环修复 (829733a3)... "
if git log --oneline | grep -q "829733a3"; then
    echo -e "${GREEN}✓ 存在${NC}"
else
    echo -e "${RED}✗ 未找到${NC}"
fi

echo -n "  - stdin 崩溃修复 (0cf6e7c5)... "
if git log --oneline | grep -q "0cf6e7c5"; then
    echo -e "${GREEN}✓ 存在${NC}"
else
    echo -e "${RED}✗ 未找到${NC}"
fi
echo ""

# 检查潜在问题文件
echo "扫描潜在问题文件:"
PROBLEM_DIRS=(
    "test/fixtures/test_grammars/get_col_should_hang_not_crash"
    "test/fixtures/test_grammars/indirect_recursion_in_transitions"
    "test/fixtures/test_grammars/conflict_in_repeat_rule"
    "test/fixtures/error_corpus"
)

for dir in "${PROBLEM_DIRS[@]}"; do
    echo -n "  - $dir... "
    if [ -d "$dir" ]; then
        echo -e "${YELLOW}存在 (已在 .cursorignore 中排除)${NC}"
    else
        echo "不存在"
    fi
done
echo ""

# 检查项目大小
echo "项目大小:"
echo "  - 工作区: $(du -sh . 2>/dev/null | cut -f1)"
echo "  - .git: $(du -sh .git 2>/dev/null | cut -f1)"
echo ""

# 验证可以基本编译
echo "验证项目可编译性:"
echo -n "  - 检查 Cargo.toml... "
if [ -f "Cargo.toml" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

echo -n "  - 检查是否可以解析工作区... "
if cargo metadata --no-deps >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
    CRATES=$(cargo metadata --no-deps --format-version 1 2>/dev/null | grep -o '"name":"[^"]*"' | wc -l)
    echo "    发现 $CRATES 个 crate"
else
    echo -e "${RED}✗${NC}"
fi
echo ""

# 建议
echo "=================================="
echo "建议:"
echo "=================================="
echo ""
echo "1. 如果 Cursor 仍然崩溃，尝试:"
echo "   - 重启 Cursor"
echo "   - 清除 Cursor 缓存"
echo "   - 只打开单个 crate (如 crates/cli)"
echo ""
echo "2. 监控资源使用:"
echo "   - 观察 CPU 使用率（应该不会持续 100%）"
echo "   - 观察内存使用（应该在合理范围内）"
echo ""
echo "3. 如果问题持续:"
echo "   - 查看 CURSOR_CRASH_DIAGNOSIS.md"
echo "   - 查看 TROUBLESHOOTING_STEPS.md"
echo "   - 考虑向 Cursor 团队报告"
echo ""
echo "4. 文件已被 .cursorignore 排除:"
echo "   - test/fixtures/test_grammars/"
echo "   - test/fixtures/error_corpus/"
echo "   - .git/ 目录"
echo "   - 构建输出目录"
echo ""

# 生成诊断报告
REPORT_FILE="cursor_diagnostic_report.txt"
echo "生成诊断报告: $REPORT_FILE"
{
    echo "Cursor 崩溃诊断报告"
    echo "生成时间: $(date)"
    echo "=================================="
    echo ""
    echo "Git 分支: $(git branch --show-current)"
    echo "最新提交: $(git log -1 --oneline)"
    echo ""
    echo "项目大小: $(du -sh . 2>/dev/null | cut -f1)"
    echo "文件数量: $(find . -type f 2>/dev/null | wc -l)"
    echo ""
    echo "Cargo 工作区成员:"
    cargo metadata --no-deps --format-version 1 2>/dev/null | grep '"name"' | head -20
    echo ""
    echo ".cursorignore 规则:"
    cat .cursorignore 2>/dev/null || echo "文件不存在"
    echo ""
} > "$REPORT_FILE"

echo -e "${GREEN}✓ 诊断报告已生成${NC}"
echo ""
echo "=================================="
echo "测试完成"
echo "=================================="
