#!/bin/bash
# install_mdt.sh
# 一键安装终端 Markdown 系统 mdx v3（终极版）

# 安装依赖
echo "安装依赖：glow、fzf、ripgrep、vim/neovim"
echo "提示：强烈推荐安装 bat 以获得更好的 markdown 预览颜色支持"
if command -v brew >/dev/null 2>&1; then
    brew install glow fzf ripgrep vim
    # bat 是可选的，但强烈推荐安装以获得更好的 markdown 预览颜色
    if ! command -v bat >/dev/null 2>&1; then
        echo ""
        echo "⚠️  建议安装 bat 以获得更好的 markdown 预览颜色支持："
        echo "   brew install bat"
        echo ""
    fi
else
    echo "请先安装 Homebrew 或自行安装 glow/fzf/ripgrep/vim"
    exit 1
fi

# 创建 mdt 命令
MDX_PATH="$HOME/.local/bin/mdt"
mkdir -p "$(dirname "$MDX_PATH")"

cat > "$MDX_PATH" << 'EOF'
#!/bin/bash
# mdt: 终极终端 Markdown 管理系统

# 默认搜索目录，可按需增加
SEARCH_DIRS=(. docs README.md)

# 支持文件类型
GLOB_PATTERN='*.{md,txt,rst,adoc}'

# Glow 主题
GLOW_STYLE=${GLOW_STYLE:-dark}

# RG 搜索命令 - 列出匹配的文件
RG_CMD="rg --files -g '$GLOB_PATTERN' ${SEARCH_DIRS[@]} 2>/dev/null"

# FZF 交互
# 优先使用 glow，如果未安装则退回到 bat（颜色表现较好）
if command -v glow >/dev/null 2>&1; then
    PREVIEW_CMD="bat --color=always --style=full --pager=never --language=markdown {}"
elif command -v bat >/dev/null 2>&1; then
    PREVIEW_CMD="GLOW_FORCE_COLOR=1 glow --pager=false --style=$GLOW_STYLE --width=\$(tput cols) {}"
else
    PREVIEW_CMD="cat {}"
fi

files=$(eval "$RG_CMD" \
       | fzf --ansi --multi --history="$HOME/.mdt_history" \
             --preview "$PREVIEW_CMD" \
             --preview-window=right:80%:wrap \
             --bind "ctrl-r:reload($RG_CMD)" \
             --prompt "MDX v3 🔎> ")

# 打开文件
if [[ -n "$files" ]]; then
    file_array=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && file_array+=("$file")
    done <<< "$files"

    if [[ ${#file_array[@]} -gt 0 ]]; then
        vim "${file_array[@]}"
    fi
fi
EOF

chmod +x "$MDX_PATH"

# PATH 提示
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo "请将以下路径添加到你的 shell 配置文件中（.zshrc 或 .bashrc）:"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
fi

echo "终极版 mdx v3 安装完成！使用 'mdt' 即可。"
echo "切换 Glow 主题：export GLOW_STYLE=light 或 export GLOW_STYLE=dark"