#!/bin/bash
# Cursor 稳定命令模板
# 复制这些模板，替换相应部分即可避免随机失败

# ============================================
# 模板 1：创建/写入文件
# ============================================
create_file() {
    local file="$1"
    local content="$2"
    
    echo "$content" > "$file" && \
      sync && \
      test -f "$file" && \
      echo "✓ 文件 $file 创建成功" && \
      cat "$file"
}

# 使用示例：
# create_file "config.json" '{"debug": true}'

# ============================================
# 模板 2：修改文件内容
# ============================================
modify_file() {
    local file="$1"
    local old="$2"
    local new="$3"
    
    sed -i "s/$old/$new/g" "$file" && \
      sync && \
      grep -q "$new" "$file" && \
      echo "✓ 文件 $file 修改成功" && \
      grep "$new" "$file"
}

# 使用示例：
# modify_file "src/main.py" "old_function" "new_function"

# ============================================
# 模板 3：批量处理文件
# ============================================
batch_process() {
    local pattern="$1"
    local operation="$2"
    
    echo "开始批量处理 $pattern ..."
    local count=0
    local success=0
    
    for file in $pattern; do
        ((count++))
        echo "[$count] 处理: $file"
        
        if eval "$operation"; then
            sync
            ((success++))
            echo "  ✓ 成功"
        else
            echo "  ✗ 失败"
        fi
    done
    
    echo "完成: $success/$count 文件处理成功"
}

# 使用示例：
# batch_process "*.txt" "sed -i 's/old/new/g' \"\$file\""

# ============================================
# 模板 4：编译/构建命令
# ============================================
build_project() {
    local build_cmd="$1"
    local output_file="$2"
    
    echo "开始构建..."
    
    if $build_cmd; then
        sync
        sleep 0.2
        
        if [ -n "$output_file" ] && [ -f "$output_file" ]; then
            echo "✓ 构建成功"
            ls -lh "$output_file"
        else
            echo "✓ 构建命令执行完成"
        fi
    else
        echo "✗ 构建失败，退出码: $?"
        return 1
    fi
}

# 使用示例：
# build_project "make build" "./output/binary"
# build_project "cargo build --release" "./target/release/myapp"

# ============================================
# 模板 5：复杂命令链
# ============================================
command_chain() {
    echo "执行命令链..."
    
    # 第 1 步
    echo "[1/4] 步骤 1..."
    command1 && sync && echo "  ✓ 完成" || { echo "  ✗ 失败"; return 1; }
    
    # 第 2 步
    echo "[2/4] 步骤 2..."
    command2 && sync && echo "  ✓ 完成" || { echo "  ✗ 失败"; return 1; }
    
    # 第 3 步
    echo "[3/4] 步骤 3..."
    command3 && sync && echo "  ✓ 完成" || { echo "  ✗ 失败"; return 1; }
    
    # 第 4 步
    echo "[4/4] 步骤 4..."
    command4 && sync && echo "  ✓ 完成" || { echo "  ✗ 失败"; return 1; }
    
    echo "所有步骤完成！"
}

# ============================================
# 模板 6：安全的文件移动/重命名
# ============================================
safe_move() {
    local src="$1"
    local dst="$2"
    
    if [ ! -f "$src" ]; then
        echo "✗ 源文件不存在: $src"
        return 1
    fi
    
    mv "$src" "$dst" && \
      sync && \
      test -f "$dst" && \
      ! test -f "$src" && \
      echo "✓ 文件已移动: $src -> $dst" && \
      ls -lh "$dst"
}

# 使用示例：
# safe_move "old_name.txt" "new_name.txt"

# ============================================
# 模板 7：Git 操作
# ============================================
safe_git_commit() {
    local message="$1"
    
    echo "准备提交..."
    
    git add . && \
      echo "文件已暂存:" && \
      git status --short && \
      git commit -m "$message" && \
      echo "✓ 提交成功" && \
      git log -1 --oneline
}

# 使用示例：
# safe_git_commit "Update configuration"

# ============================================
# 模板 8：测试运行
# ============================================
run_tests() {
    local test_cmd="$1"
    
    echo "运行测试..."
    echo "命令: $test_cmd"
    echo "---"
    
    if $test_cmd; then
        echo "---"
        echo "✓ 测试通过"
        return 0
    else
        local exit_code=$?
        echo "---"
        echo "✗ 测试失败，退出码: $exit_code"
        return $exit_code
    fi
}

# 使用示例：
# run_tests "pytest tests/"
# run_tests "npm test"
# run_tests "cargo test"

# ============================================
# 模板 9：目录操作
# ============================================
safe_mkdir() {
    local dir="$1"
    
    mkdir -p "$dir" && \
      sync && \
      test -d "$dir" && \
      echo "✓ 目录创建成功: $dir" && \
      ls -ld "$dir"
}

# 使用示例：
# safe_mkdir "src/components/new_feature"

# ============================================
# 模板 10：下载文件
# ============================================
safe_download() {
    local url="$1"
    local output="$2"
    
    echo "下载: $url"
    
    if curl -fsSL "$url" -o "$output"; then
        sync
        test -f "$output" && \
          echo "✓ 下载成功: $output" && \
          ls -lh "$output"
    else
        echo "✗ 下载失败"
        return 1
    fi
}

# 使用示例：
# safe_download "https://example.com/file.zip" "file.zip"

# ============================================
# 通用包装器函数
# ============================================
safe_exec() {
    local description="$1"
    shift
    local cmd="$@"
    
    echo "[$description]"
    echo "执行: $cmd"
    
    if eval "$cmd"; then
        sync
        echo "✓ 成功"
        return 0
    else
        local exit_code=$?
        echo "✗ 失败，退出码: $exit_code"
        return $exit_code
    fi
}

# 使用示例：
# safe_exec "编译项目" "make build"
# safe_exec "安装依赖" "npm install"

# ============================================
# 使用说明
# ============================================

show_usage() {
    cat << 'EOF'

Cursor 稳定命令模板使用说明
============================

1. 加载此文件：
   source /workspace/.cursor_commands_template.sh

2. 使用任意模板函数，例如：
   create_file "test.txt" "Hello World"
   modify_file "config.txt" "debug=false" "debug=true"
   safe_git_commit "Update feature"

3. 或直接复制模板代码，替换其中的变量

关键技巧：
- 所有关键操作后调用 sync
- 使用 && 链接命令确保顺序
- 添加显式的 echo 输出
- 验证操作结果（test -f, grep -q 等）

============================
EOF
}

# 如果直接运行此脚本，显示使用说明
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    show_usage
fi
