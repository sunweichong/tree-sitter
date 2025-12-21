# Cursor 崩溃问题故障排除步骤

## 问题概述
Cursor 窗口在打开 tree-sitter 项目时崩溃（错误代码 5）

## 根本原因分析

基于代码库分析，发现了以下已知问题：

### 1. 查询解析无限循环（已修复）
**提交**: `829733a3` - fix(query): prevent infinite loop with `+` and `?` quantifiers

**问题**: 带有 `?` 量词后跟 `+` 量词的查询会导致 100% CPU 使用率的无限循环

**影响**: 这可能导致 Cursor 在尝试解析某些语法文件时挂起或崩溃

### 2. 解析 stdin 时的崩溃（已修复）
**提交**: `0cf6e7c5` - fix(cli): prevent crash when parsing stdin

**问题**: 从管道或 heredoc 解析 stdin 时，源计数为 0，导致 XML 输出时崩溃

### 3. 测试语法文件
项目包含多个故意设计的错误语法文件，用于测试边缘情况：
- `test/fixtures/test_grammars/get_col_should_hang_not_crash/` - 测试挂起场景
- `test/fixtures/error_corpus/` - 包含错误语法
- `test/fixtures/test_grammars/conflict_in_repeat_rule/` - 测试冲突场景
- `test/fixtures/test_grammars/indirect_recursion_in_transitions/` - 测试间接递归

## 立即解决步骤

### 步骤 1: 应用忽略规则
我已创建 `.cursorignore` 文件，排除了可能导致问题的目录：

```bash
# 验证文件已创建
cat .cursorignore
```

### 步骤 2: 重启 Cursor
1. 完全关闭 Cursor
2. 清除 Cursor 缓存（如果可能）
3. 重新打开项目

### 步骤 3: 逐步测试
如果问题仍然存在，尝试：

```bash
# 1. 只打开单个 crate 而不是整个工作区
# 例如，只打开 crates/cli

# 2. 检查哪些文件可能触发崩溃
find test/fixtures/test_grammars -name "*.js" | wc -l
# 应该有大量测试语法文件

# 3. 临时重命名测试目录
mv test/fixtures/test_grammars test/fixtures/test_grammars.bak
# 然后尝试打开项目
```

### 步骤 4: 验证代码版本
确认您使用的是最新版本的代码，包含所有修复：

```bash
# 检查是否包含关键修复
git log --oneline | grep -E "infinite loop|crash|hang"
```

## 高级诊断

### 监控资源使用

```bash
# 如果可以访问系统，监控 Cursor 进程
# (需要在本地机器上运行)
top -p $(pgrep cursor)
```

### 检查特定文件

以下文件可能导致解析问题：

1. **查询文件** (.scm 文件) - 可能包含导致无限循环的模式
2. **复杂的语法文件** - 包含递归或冲突的规则
3. **大型测试文件** - 可能占用过多内存

### 二分查找问题文件

```bash
# 如果需要找到具体导致崩溃的文件，可以二分排除
# 1. 先排除一半测试目录
# 2. 测试是否还崩溃
# 3. 重复直到找到问题文件
```

## 预防措施

### 1. Cursor 设置优化
如果可以访问 Cursor 设置，考虑：
- 禁用自动索引大型测试目录
- 限制并发文件处理数量
- 增加超时时间

### 2. 项目结构建议
对于 tree-sitter 开发：
- 使用单独的工作区打开各个 crate
- 排除 test/fixtures 目录
- 只在需要时打开测试文件

### 3. 替代方案
如果 Cursor 继续崩溃：
- 使用其他编辑器进行测试文件编辑
- 使用远程开发环境隔离问题
- 在容器中运行开发环境

## 验证修复

创建一个简单的测试来验证问题是否解决：

```bash
# 1. 确保工作树干净
git status

# 2. 尝试构建项目
cargo build --release

# 3. 运行测试套件
cargo test --workspace

# 4. 如果成功，则代码本身没有问题
# 问题可能在于 Cursor 如何处理这些文件
```

## 已应用的修复

在这个分支上，我已经创建了以下文件：

1. **`.cursorignore`** - 排除问题目录
2. **`.cursorrules`** - 提供项目指导
3. **`CURSOR_CRASH_DIAGNOSIS.md`** - 详细的诊断文档
4. **`TROUBLESHOOTING_STEPS.md`** - 本文件

## 下一步

1. ✅ 创建忽略规则文件
2. ⏳ 重启 Cursor 并测试
3. ⏳ 如果问题持续，收集详细日志
4. ⏳ 向 Cursor 团队报告问题
5. ⏳ 考虑创建最小复现案例

## 联系支持

如果问题持续存在，准备以下信息：
- Cursor 版本
- 操作系统版本
- 崩溃时的具体操作
- 崩溃日志（如果可访问）
- 是否可以稳定复现

## 参考资料

- tree-sitter 文档: https://tree-sitter.github.io
- 相关提交:
  - `829733a3`: 无限循环修复
  - `0cf6e7c5`: stdin 崩溃修复
  - `47c92569`: 清理挂起测试
