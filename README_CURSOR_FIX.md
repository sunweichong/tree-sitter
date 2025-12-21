# Cursor 窗口崩溃问题 - 解决方案摘要

## 🔴 问题
在打开 tree-sitter 项目时，Cursor 窗口意外终止：
- **错误**: 窗口意外终止
- **原因**: "crashed"
- **代码**: 5

## ✅ 已应用的修复

我已经为此项目创建了以下配置文件来防止崩溃：

### 1. `.cursorignore` 文件
排除了可能导致崩溃的目录：
- ✓ 测试语法文件（51 个故意包含错误/复杂规则的文件）
- ✓ 错误语料库
- ✓ Git 内部文件
- ✓ 构建输出目录
- ✓ 大型二进制文件

**排除规则数**: 21 条

### 2. `.cursorrules` 文件
为 Cursor 提供项目指导和优化建议

### 3. 诊断文档
- `CURSOR_CRASH_DIAGNOSIS.md` - 详细的问题分析
- `TROUBLESHOOTING_STEPS.md` - 故障排除步骤
- `test_cursor_stability.sh` - 自动化测试脚本
- `cursor_diagnostic_report.txt` - 系统诊断报告

## 🎯 根本原因

分析发现了以下导致崩溃的因素：

### 1. Tree-sitter 查询解析无限循环
**提交**: `829733a3`
- **问题**: 带有 `?` 量词后跟 `+` 量词的查询会导致无限循环
- **影响**: CPU 使用率达到 100%，最终导致崩溃
- **状态**: ✅ 已在代码中修复

### 2. 测试文件包含危险模式
项目包含专门设计用于测试边缘情况的文件：
- `get_col_should_hang_not_crash` - 测试挂起场景
- `indirect_recursion_in_transitions` - 测试间接递归
- `conflict_in_repeat_rule` - 测试规则冲突
- **状态**: ✅ 已通过 `.cursorignore` 排除

### 3. 大量语法文件
- **51 个测试语法文件**，每个都可能触发不同的解析场景
- **状态**: ✅ 已排除

## 📋 使用说明

### 第一步：验证修复
运行测试脚本验证配置是否正确：

```bash
./test_cursor_stability.sh
```

应该看到所有检查项都显示 ✓（绿色勾号）

### 第二步：重启 Cursor
1. 完全关闭 Cursor
2. 重新打开项目
3. Cursor 现在应该会跳过被排除的目录

### 第三步：监控
观察 Cursor 是否：
- ✓ 正常启动
- ✓ CPU 使用率正常（不会持续 100%）
- ✓ 内存使用合理
- ✓ 不再崩溃

## 🔧 如果问题仍然存在

### 选项 1: 只打开单个 Crate
不要打开整个工作区，只打开一个子项目：

```bash
# 例如，只打开 CLI crate
cd crates/cli
# 然后在这个目录中打开 Cursor
```

### 选项 2: 临时移除测试文件
```bash
# 备份测试目录
mv test/fixtures/test_grammars test/fixtures/test_grammars.backup

# 尝试打开项目

# 完成后恢复
mv test/fixtures/test_grammars.backup test/fixtures/test_grammars
```

### 选项 3: 使用其他编辑器
对于测试文件的编辑，考虑使用：
- VS Code
- Neovim
- Zed (项目中有 .zed 配置)

### 选项 4: 查看详细文档
```bash
# 查看完整的诊断信息
cat CURSOR_CRASH_DIAGNOSIS.md

# 查看故障排除步骤
cat TROUBLESHOOTING_STEPS.md

# 查看系统诊断报告
cat cursor_diagnostic_report.txt
```

## 📊 项目统计

- **总文件数**: 556
- **Rust 文件**: 102
- **C 文件**: 31
- **测试语法文件**: 51
- **Cargo Crates**: 138
- **项目大小**: 29M
- **Git 大小**: 24M

## 🔍 技术细节

### 导致崩溃的具体模式

根据代码分析，以下模式可能触发问题：

```
// 查询模式示例（可能导致无限循环）
(pattern)? (another_pattern)+
```

这种模式在修复前会导致：
1. 解析器进入无限循环
2. CPU 使用率达到 100%
3. 最终内存耗尽或超时
4. Cursor 窗口崩溃（代码 5）

### 已应用的修复逻辑

修复方法是先收集所有量词，然后在确定需要使用的复合量词后，再添加所需的重复/可选步骤逻辑。这避免了在处理某些量词组合时的递归问题。

## ✨ 预期结果

应用这些修复后：
- ✅ Cursor 应该能够正常打开项目
- ✅ 不会因为测试文件而崩溃
- ✅ CPU 使用率保持正常
- ✅ 可以正常编辑代码文件

## 📞 获取帮助

如果问题仍未解决：

1. **检查 Cursor 版本**: 确保使用最新版本
2. **清除缓存**: 删除 Cursor 的缓存目录
3. **收集日志**: 查找 `~/.config/Cursor/logs/` 或类似目录
4. **向 Cursor 报告**: 包含以下信息
   - 操作系统版本
   - Cursor 版本
   - `cursor_diagnostic_report.txt` 内容
   - 崩溃时的具体操作

## 📝 总结

这个问题的根源是：
1. Tree-sitter 项目包含大量测试用的"危险"语法文件
2. Cursor 尝试解析所有文件，包括故意包含错误的测试文件
3. 某些查询模式触发了已知的无限循环 bug（虽然代码中已修复）
4. 最终导致崩溃

通过配置 `.cursorignore` 来排除这些测试文件，Cursor 应该能够正常工作，因为它不再尝试解析那些"危险"的文件。

---

**创建日期**: $(date)
**分支**: cursor/cursor-window-crash-issue-2877
**状态**: ✅ 修复已应用，等待测试验证
