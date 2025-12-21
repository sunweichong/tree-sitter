# Cursor 窗口崩溃问题 - 解决方案总结

## 📌 快速概览

您的 Cursor 窗口崩溃问题（错误代码 5）已被诊断并应用了修复。

**问题原因**: Tree-sitter 项目包含 51 个测试语法文件，这些文件故意包含错误或复杂的解析规则来测试边缘情况。Cursor 尝试解析这些文件时触发了崩溃。

**解决方案**: 创建 `.cursorignore` 文件排除这些问题文件。

---

## ✅ 已创建的文件

### 1. 核心配置文件
- **`.cursorignore`** (542 字节)
  - 排除 21 条规则
  - 阻止 Cursor 索引测试语法文件和错误语料库
  
- **`.cursorrules`** (667 字节)
  - 为 Cursor 提供项目指导
  - 优化性能建议

### 2. 文档文件
- **`README_CURSOR_FIX.md`** (4.8 KB)
  - 问题和解决方案的完整摘要
  - 使用说明和故障排除建议
  
- **`CURSOR_CRASH_DIAGNOSIS.md`** (2.8 KB)
  - 详细的根本原因分析
  - 可能的崩溃因素
  - 推荐的解决方案
  
- **`TROUBLESHOOTING_STEPS.md`** (4.4 KB)
  - 逐步故障排除指南
  - 高级诊断方法
  - 验证修复的步骤

### 3. 工具脚本
- **`test_cursor_stability.sh`** (可执行)
  - 自动化稳定性测试
  - 验证配置正确性
  - 生成诊断报告

### 4. 诊断报告
- **`cursor_diagnostic_report.txt`**
  - 系统状态快照
  - 项目统计信息
  - 配置详情

---

## 🚀 立即行动 - 3 步解决

### 步骤 1: 验证修复
```bash
# 运行测试脚本
./test_cursor_stability.sh
```

**期望输出**: 所有检查项显示绿色 ✓

### 步骤 2: 重启 Cursor
1. 完全关闭 Cursor
2. 重新打开项目
3. 观察是否正常启动

### 步骤 3: 验证正常工作
- ✓ Cursor 启动成功
- ✓ CPU 使用率正常（非持续 100%）
- ✓ 内存使用合理
- ✓ 不再崩溃

---

## 📊 项目状态

```
项目大小:        29 MB
总文件数:        556 个
Rust 文件:       102 个
测试语法文件:     51 个 (已排除)
Cargo Crates:    138 个
Git 分支:        cursor/cursor-window-crash-issue-2877
```

---

## 🔍 技术详情

### 根本原因

1. **查询解析无限循环** (已在代码中修复 - 提交 829733a3)
   - 问题: `?` 量词后跟 `+` 量词导致无限循环
   - 影响: CPU 100% 使用率，最终崩溃
   
2. **危险的测试文件**
   - 51 个测试语法文件包含故意的错误
   - 测试场景: 挂起、递归、冲突规则
   - 示例: `get_col_should_hang_not_crash`

3. **Cursor 解析器过载**
   - Cursor 尝试索引所有文件
   - 遇到复杂/错误语法时崩溃

### 应用的修复

```
.cursorignore 排除的目录:
  ├─ test/fixtures/test_grammars/    (51 个语法文件)
  ├─ test/fixtures/error_corpus/     (错误测试)
  ├─ test/fixtures/grammars/         (语法定义)
  ├─ .git/                           (Git 内部)
  ├─ target/                         (构建输出)
  └─ node_modules/                   (依赖)
```

---

## 🔧 如果问题持续

### 选项 A: 分区工作
```bash
# 只打开单个 crate
cd crates/cli
# 然后在此目录打开 Cursor
```

### 选项 B: 临时移除测试文件
```bash
# 备份并移除
mv test/fixtures/test_grammars test/fixtures/test_grammars.backup
# 完成后恢复
mv test/fixtures/test_grammars.backup test/fixtures/test_grammars
```

### 选项 C: 使用其他编辑器
- VS Code
- Neovim
- Zed (已有配置: `.zed/settings.json`)

### 选项 D: 查看详细文档
```bash
# 完整诊断
cat CURSOR_CRASH_DIAGNOSIS.md

# 故障排除
cat TROUBLESHOOTING_STEPS.md

# 系统报告
cat cursor_diagnostic_report.txt
```

---

## 📞 获取更多帮助

### 查看相关提交
```bash
# 无限循环修复
git show 829733a3

# stdin 崩溃修复
git show 0cf6e7c5
```

### 向 Cursor 团队报告
如需报告问题,请包含:
- 操作系统: Linux 6.1.147
- Cursor 版本: (您的版本)
- 崩溃日志位置: `~/.config/Cursor/logs/` 或 `~/.cursor/logs/`
- 附件: `cursor_diagnostic_report.txt`

---

## 📚 文件结构

```
/workspace/
├── .cursorignore              ← 核心修复文件
├── .cursorrules               ← 项目规则
├── README_CURSOR_FIX.md       ← 完整解决方案指南
├── CURSOR_CRASH_DIAGNOSIS.md  ← 问题诊断
├── TROUBLESHOOTING_STEPS.md   ← 故障排除步骤
├── SOLUTION_SUMMARY_zh.md     ← 本文件 (快速参考)
├── test_cursor_stability.sh   ← 测试脚本
└── cursor_diagnostic_report.txt ← 系统报告
```

---

## ✨ 预期结果

应用这些修复后:

✅ Cursor 正常启动  
✅ 不会因测试文件崩溃  
✅ CPU 使用率正常  
✅ 内存使用合理  
✅ 可以正常编辑代码  

---

## 🎯 下一步

1. **立即执行**: 运行 `./test_cursor_stability.sh`
2. **重启 Cursor**: 完全关闭并重新打开
3. **监控**: 观察 CPU 和内存使用
4. **测试**: 尝试编辑一些 Rust 文件
5. **报告**: 如果问题持续，查看 TROUBLESHOOTING_STEPS.md

---

## 💡 关键要点

- **问题**: Cursor 尝试解析 51 个"危险"测试文件
- **解决**: 通过 `.cursorignore` 排除这些文件
- **状态**: 修复已应用，等待测试验证
- **时间**: 2025年12月21日创建
- **分支**: cursor/cursor-window-crash-issue-2877

---

**祝顺利! 🚀**

如有问题，请参考其他文档或运行测试脚本获取更多信息。
