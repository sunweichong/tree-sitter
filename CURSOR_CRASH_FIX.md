# Cursor 崩溃问题修复指南

## 问题描述
Cursor 窗口意外终止（原因: "crashed"，代码: "5"）

## 已实施的修复

1. **创建了 `.cursor/settings.json` 配置文件**
   - 将 rust-analyzer 的 features 从 "all" 改为 "default"，减少内存占用
   - 添加了文件监控排除规则，减少系统负担
   - 优化了搜索和文件排除设置

2. **更新了 `.zed/settings.json`**
   - 将 features 从 "all" 改为 "default"
   - 添加了 checkOnSave 配置

## 其他建议

如果问题仍然存在，请尝试：

1. **清理构建缓存**
   ```bash
   cargo clean
   ```

2. **重启 Cursor**
   - 完全关闭 Cursor
   - 重新打开项目

3. **检查系统资源**
   - 确保有足够的可用内存（建议至少 4GB）
   - 检查磁盘空间是否充足

4. **更新 Cursor**
   - 确保使用最新版本的 Cursor

5. **临时禁用扩展**
   - 如果安装了 Rust 相关扩展，尝试临时禁用以排除冲突

6. **检查日志**
   - 查看 Cursor 的日志文件以获取更多错误信息
   - 日志位置通常在：`~/.cursor/logs/` 或 `~/.config/Cursor/logs/`

## 如果问题持续

如果以上方法都无法解决问题，可能需要：
- 报告 bug 到 Cursor 的 GitHub 仓库
- 提供崩溃日志和系统信息
- 尝试在另一个项目中复现问题
