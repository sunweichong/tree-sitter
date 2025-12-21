# Cursor 窗口崩溃问题诊断 (Issue #2877)

## 问题描述
窗口意外终止，错误信息：
- 原因: "crashed"
- 代码: 5

## 可能的原因

### 1. Tree-sitter 解析器问题
这个项目是 tree-sitter 本身的仓库，Cursor 使用 tree-sitter 进行语法解析。可能存在：
- 递归解析导致的栈溢出
- 无限循环（注意到最近有修复：`fix(query): prevent infinite loop with + and ? quantifiers`）
- 大型语法文件解析时的内存问题

### 2. 项目规模和复杂度
- 项目大小：约 29MB
- 多个 crates 和复杂的依赖关系
- 包含大量测试语法和测试用例

### 3. Git 历史
- Git 对象数量少（只有 3 个对象文件）
- 可能使用了浅克隆
- 存在多个并行的功能分支

## 推荐的解决方案

### 临时解决方案

#### 1. 禁用 Tree-sitter 索引
创建 `.cursorignore` 文件以排除可能导致问题的目录：

```
test/fixtures/test_grammars/
test/fixtures/grammars/
test/fixtures/error_corpus/
test/fixtures/template_corpus/
.git/
target/
node_modules/
```

#### 2. 限制 Cursor 的解析范围
创建 `.cursorrules` 文件来限制 Cursor 的行为：

```
# 限制文件索引范围
# 避免解析测试语法文件，因为它们可能包含故意的错误语法
```

#### 3. 增加 Cursor 的内存限制
如果可能，在 Cursor 设置中增加内存限制。

### 长期解决方案

#### 1. 更新 Cursor
确保您使用的是最新版本的 Cursor，因为新版本可能已经修复了相关问题。

#### 2. 报告给 Cursor 团队
这个崩溃可能是 Cursor 处理 tree-sitter 项目时的一个 bug。

#### 3. 分离工作环境
考虑使用远程开发环境或容器来隔离这个项目。

## 诊断步骤

### 1. 检查崩溃日志
查找 Cursor 的崩溃日志：
- Linux: `~/.config/Cursor/logs/` 或 `~/.cursor/logs/`
- 查找包含 "crash" 或 "error" 的日志文件

### 2. 测试最小化场景
尝试：
- 只打开单个文件而不是整个项目
- 禁用 Cursor 的各种功能（LSP、索引等）
- 在安全模式下启动 Cursor

### 3. 检查资源使用
监控 Cursor 进程的：
- 内存使用
- CPU 使用
- 文件句柄数量

## 相关代码位置

可能与问题相关的代码提交：
- `829733a3`: fix(query): prevent infinite loop with `+` and `?` quantifiers
- 这个修复表明之前存在查询解析的无限循环问题

## 下一步行动

1. 创建 `.cursorignore` 文件
2. 尝试重启 Cursor
3. 如果问题持续，收集详细的崩溃日志
4. 考虑向 Cursor 团队报告此问题

## 注意事项

- 此分支 (`cursor/cursor-window-crash-issue-2877`) 当前与 master 分支没有差异
- 可能需要在此分支上实施修复或变通方案
- 建议记录所有尝试的解决方案和结果
