#!/bin/bash
# install_mdx.sh
# 安装增强版终端 Markdown 系统 mdx（兼容 Glow v1.10+）

# 安装依赖
echo "安装依赖：glow、fzf、ripgrep、vim"
if command -v brew >/dev/null 2>&1; then
    brew install glow fzf ripgrep vim
else
    echo "请先安装 Homebrew 或自行安装 glow/fzf/ripgrep/vim"
    exit 1
fi

# 创建 mdx 命令
MDX_PATH="$HOME/.local/bin/mdx"
mkdir -p "$(dirname "$MDX_PATH")"

cat > "$MDX_PATH" << 'EOF'
#!/bin/bash
# mdx: 终端 Markdown 管理系统（增强版 v2）

# 默认搜索目录，可修改增加 docs/api 等
SEARCH_DIRS=(. docs)

# 支持文件类型
GLOB_PATTERN='*.{md,txt,rst}'

# Glow 主题，可通过环境变量切换
GLOW_STYLE=${GLOW_STYLE:-dark}

# rg 搜索命令
RG_CMD="rg --files-with-matches --iglob '$GLOB_PATTERN' ${SEARCH_DIRS[*]} 2>/dev/null"

# fzf 预览 + 编辑
file=$(eval $RG_CMD \
       | fzf --ansi --history="$HOME/.mdx_history" \
             --preview "glow --pager=false --style=$GLOW_STYLE --width=$(tput cols) {}" \
             --preview-window=right:80%:wrap \
             --bind "enter:execute(vim {})+abort" \
             --prompt "MDX 🔎> ")

# 打开文件编辑
if [[ -n "$file" ]]; then
    vim "$file"
fi
EOF

chmod +x "$MDX_PATH"

# 自动添加 PATH 到 shell 配置文件
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    # 检测当前 shell 并确定配置文件
    SHELL_CONFIG=""
    if [[ "$SHELL" == *"zsh"* ]] || [[ -n "$ZSH_VERSION" ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]] || [[ -n "$BASH_VERSION" ]]; then
        SHELL_CONFIG="$HOME/.bashrc"
        # 如果 .bashrc 不存在，尝试 .bash_profile
        if [[ ! -f "$SHELL_CONFIG" ]] && [[ -f "$HOME/.bash_profile" ]]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        fi
    fi
    
    if [[ -n "$SHELL_CONFIG" ]]; then
        PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
        # 检查是否已经存在
        if ! grep -q "$HOME/.local/bin" "$SHELL_CONFIG" 2>/dev/null; then
            echo "" >> "$SHELL_CONFIG"
            echo "# Added by install_mdx.sh" >> "$SHELL_CONFIG"
            echo "$PATH_LINE" >> "$SHELL_CONFIG"
            echo "✅ 已自动将 PATH 添加到 $SHELL_CONFIG"
            echo "💡 请运行 'source $SHELL_CONFIG' 或重新打开终端以使配置生效"
        else
            echo "✅ PATH 配置已存在于 $SHELL_CONFIG"
        fi
    else
        echo "⚠️  无法自动检测 shell 类型，请手动将以下内容添加到你的 shell 配置文件:"
        echo 'export PATH="$HOME/.local/bin:$PATH"'
    fi
fi

echo "增强版 mdx v2 安装完成！使用 'mdx' 命令即可。"
echo "切换 Glow 主题示例：export GLOW_STYLE=light 或 export GLOW_STYLE=dark"