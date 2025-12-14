#!/usr/bin/env python3
"""
从 coverage.py 生成的 HTML 覆盖率报告中恢复 Python 源代码

使用方法:
    python recover_from_htmlcov.py <htmlcov目录路径> <输出目录路径>

示例:
    python recover_from_htmlcov.py ./htmlcov ./recovered_code
"""

import os
import sys
import re
from pathlib import Path
from html.parser import HTMLParser
from html import unescape


class CoverageHTMLParser(HTMLParser):
    """解析 coverage.py 生成的 HTML 文件，提取源代码"""
    
    def __init__(self):
        super().__init__()
        self.in_source = False
        self.in_line = False
        self.in_text = False
        self.lines = []
        self.current_line = ""
        self.line_number = 0
        
    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)
        
        # 检测源代码区域
        if tag == 'div' and attrs_dict.get('id') == 'source':
            self.in_source = True
        
        # 检测代码行 (coverage.py 格式)
        if self.in_source:
            if tag == 'p' and 'class' in attrs_dict:
                classes = attrs_dict.get('class', '')
                if any(c in classes for c in ['src', 'run', 'mis', 'par', 'exc']):
                    self.in_line = True
                    self.current_line = ""
            
            # 检测文本内容 span
            if tag == 'span' and 'class' in attrs_dict:
                self.in_text = True
                
    def handle_endtag(self, tag):
        if tag == 'div' and self.in_source:
            # 可能结束源代码区域
            pass
            
        if tag == 'p' and self.in_line:
            self.lines.append(self.current_line)
            self.in_line = False
            
        if tag == 'span':
            self.in_text = False
            
    def handle_data(self, data):
        if self.in_line:
            self.current_line += data
            
    def get_source_code(self):
        return '\n'.join(self.lines)


class CoverageHTMLParserV2(HTMLParser):
    """备用解析器 - 适用于不同版本的 coverage.py"""
    
    def __init__(self):
        super().__init__()
        self.lines = []
        self.in_pre = False
        self.in_code = False
        self.in_td_text = False
        self.current_line = ""
        self.capture_text = False
        
    def handle_starttag(self, tag, attrs):
        attrs_dict = dict(attrs)
        
        if tag == 'pre':
            self.in_pre = True
            
        if tag == 'code':
            self.in_code = True
            
        # 查找包含源代码的 td 元素
        if tag == 'td' and attrs_dict.get('class') and 'text' in attrs_dict.get('class', ''):
            self.in_td_text = True
            self.capture_text = True
            
        # 新版本 coverage.py 的格式
        if tag == 'span' and 'id' in attrs_dict:
            span_id = attrs_dict.get('id', '')
            if span_id.startswith('t') and span_id[1:].isdigit():
                self.capture_text = True
                self.current_line = ""
                
    def handle_endtag(self, tag):
        if tag == 'pre':
            self.in_pre = False
            
        if tag == 'code':
            self.in_code = False
            
        if tag == 'td' and self.in_td_text:
            self.in_td_text = False
            if self.current_line:
                self.lines.append(self.current_line)
                self.current_line = ""
            self.capture_text = False
            
        if tag == 'span' and self.capture_text:
            if self.current_line:
                self.lines.append(self.current_line)
                self.current_line = ""
            self.capture_text = False
            
    def handle_data(self, data):
        if self.capture_text or self.in_pre or self.in_code:
            self.current_line += data
            
    def get_source_code(self):
        return '\n'.join(self.lines)


def extract_source_from_html(html_content):
    """从 HTML 内容中提取源代码"""
    
    # 方法 1: 使用正则表达式直接提取 (最可靠)
    # coverage.py 通常将代码放在 <span id="tN">...</span> 格式中
    pattern1 = r'<span[^>]*id="t(\d+)"[^>]*>([^<]*)</span>'
    matches = re.findall(pattern1, html_content)
    
    if matches:
        # 按行号排序
        lines_dict = {}
        for line_num, code in matches:
            lines_dict[int(line_num)] = unescape(code)
        
        if lines_dict:
            max_line = max(lines_dict.keys())
            lines = []
            for i in range(1, max_line + 1):
                lines.append(lines_dict.get(i, ''))
            return '\n'.join(lines)
    
    # 方法 2: 查找 <p class="...">...</p> 格式
    pattern2 = r'<p[^>]*class="[^"]*(?:src|run|mis|par|exc)[^"]*"[^>]*>([^<]*(?:<[^/p][^<]*)*)</p>'
    matches = re.findall(pattern2, html_content, re.DOTALL)
    
    if matches:
        lines = []
        for match in matches:
            # 清理 HTML 标签
            clean_line = re.sub(r'<[^>]+>', '', match)
            lines.append(unescape(clean_line))
        return '\n'.join(lines)
    
    # 方法 3: 查找 <pre> 标签内的代码
    pre_pattern = r'<pre[^>]*>(.*?)</pre>'
    pre_matches = re.findall(pre_pattern, html_content, re.DOTALL)
    
    if pre_matches:
        for pre_content in pre_matches:
            # 清理 HTML 标签
            clean_content = re.sub(r'<[^>]+>', '', pre_content)
            clean_content = unescape(clean_content)
            if len(clean_content) > 100:  # 确保是实际代码内容
                return clean_content
    
    # 方法 4: 使用 HTML 解析器
    parser1 = CoverageHTMLParser()
    try:
        parser1.feed(html_content)
        result = parser1.get_source_code()
        if result.strip():
            return result
    except:
        pass
    
    parser2 = CoverageHTMLParserV2()
    try:
        parser2.feed(html_content)
        result = parser2.get_source_code()
        if result.strip():
            return result
    except:
        pass
    
    return None


def get_original_filename(html_filename):
    """从 HTML 文件名推断原始 Python 文件名"""
    # 移除前缀 (如 z_61594791deeba68e_)
    name = html_filename
    
    # 移除 .html 后缀
    if name.endswith('.html'):
        name = name[:-5]
    
    # 查找 _py 后缀并替换为 .py
    if name.endswith('_py'):
        name = name[:-3] + '.py'
    
    # 移除前缀 (格式: z_<hash>_)
    parts = name.split('_')
    if len(parts) > 2 and parts[0] == 'z':
        # 跳过 'z' 和 hash 部分
        name = '_'.join(parts[2:])
    
    return name


def recover_files(htmlcov_dir, output_dir):
    """从 htmlcov 目录恢复所有 Python 文件"""
    
    htmlcov_path = Path(htmlcov_dir)
    output_path = Path(output_dir)
    
    if not htmlcov_path.exists():
        print(f"错误: htmlcov 目录不存在: {htmlcov_dir}")
        return False
    
    # 创建输出目录
    output_path.mkdir(parents=True, exist_ok=True)
    
    # 要恢复的文件列表
    target_files = [
        'gt_wam_primitive_recognizer_py',
        'gt_wam_primitive_library_py',
        'gt_wam_parameter_extractor_py',
        'gt_wam_ast_extractor_py',
        'gt_wam_primitive_instance_py',
        'gt_wam_wam_compiler_py',
        'gt_wam_instruction_registry_py',
        'gt_wam_wam_instruction_py',
        'gt_wam_wam_program_py',
        'gt_wam_instruction_optimizer_py',
        'gt_wam_wam_program_generator_py',
        'gt_wam_primitive_nlg_py',
        'gt_wam_instruction_nlg_py',
        'gt_wam_coherence_optimizer_py',
        'gt_wam_expression_processor_py',
        'gt_wam_performance_monitor_py',
    ]
    
    recovered_count = 0
    failed_files = []
    
    # 查找所有 HTML 文件
    html_files = list(htmlcov_path.glob('*.html'))
    print(f"找到 {len(html_files)} 个 HTML 文件")
    
    for html_file in html_files:
        # 检查是否是我们要恢复的文件
        should_recover = False
        for target in target_files:
            if target in html_file.name:
                should_recover = True
                break
        
        if not should_recover:
            continue
            
        print(f"\n处理: {html_file.name}")
        
        try:
            # 读取 HTML 内容
            with open(html_file, 'r', encoding='utf-8', errors='ignore') as f:
                html_content = f.read()
            
            # 提取源代码
            source_code = extract_source_from_html(html_content)
            
            if source_code and source_code.strip():
                # 获取原始文件名
                original_name = get_original_filename(html_file.name)
                output_file = output_path / original_name
                
                # 写入恢复的代码
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(source_code)
                
                print(f"  ✓ 已恢复: {original_name} ({len(source_code)} 字符)")
                recovered_count += 1
            else:
                print(f"  ✗ 无法提取源代码")
                failed_files.append(html_file.name)
                
        except Exception as e:
            print(f"  ✗ 错误: {e}")
            failed_files.append(html_file.name)
    
    print(f"\n{'='*50}")
    print(f"恢复完成!")
    print(f"成功恢复: {recovered_count} 个文件")
    print(f"输出目录: {output_path.absolute()}")
    
    if failed_files:
        print(f"\n失败的文件:")
        for f in failed_files:
            print(f"  - {f}")
    
    return recovered_count > 0


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        print("\n请提供 htmlcov 目录和输出目录路径")
        print("\n示例:")
        print("  python recover_from_htmlcov.py /path/to/htmlcov /path/to/output")
        sys.exit(1)
    
    htmlcov_dir = sys.argv[1]
    output_dir = sys.argv[2]
    
    print("=" * 50)
    print("从 HTML 覆盖率报告恢复 Python 源代码")
    print("=" * 50)
    print(f"\n输入目录: {htmlcov_dir}")
    print(f"输出目录: {output_dir}")
    
    success = recover_files(htmlcov_dir, output_dir)
    
    if not success:
        sys.exit(1)


if __name__ == '__main__':
    main()
