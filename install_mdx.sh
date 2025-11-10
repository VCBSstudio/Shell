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

# 提示添加 PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo "请将以下路径添加到你的 shell 配置文件中（.zshrc 或 .bashrc）:"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
fi

echo "增强版 mdx v2 安装完成！使用 'mdx' 命令即可。"
echo "切换 Glow 主题示例：export GLOW_STYLE=light 或 export GLOW_STYLE=dark"