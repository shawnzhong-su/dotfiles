# ==========================================
# 1. 性能加速 (P10K Instant Prompt)
# ==========================================
# 必须放在文件顶部。如果初始化代码需要控制台输入，请将其移至此块上方。
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export COLORTERM=truecolor

# ==========================================
# 3. 环境变量与路径 (Path)
# ==========================================
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
# export LANG=en_US.UTF-8
export PATH="$HOME/.local/bin:$PATH"
# ==========================================
# 4. 现代 CLI 工具集成 (Rust-based Tools)
# ==========================================

# Zoxide: 现代化的 cd 替换工具 (使用 z 代替 cd)
eval "$(zoxide init zsh)"

# 别名映射 (Aliases)
# 使用 eza 替代 ls (更漂亮的图标和颜色)
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'


alias claude='claude --dangerously-skip-permissions'
# 使用 bat 替代 cat (支持代码高亮)
alias cat='bat'

# 使用 ripgrep 替代 grep (极速搜索)
alias grep='rg'
alias mux='tmuxinator'

# ==========================================
# 5. 主题与插件加载 (Homebrew 路径)
# ==========================================
# 这些工具通过 Homebrew 安装，需要手动 source 其脚本
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

# ==========================================
# 6. P10K 个性化配置
# ==========================================
# 运行 `p10k configure` 可以重新生成此文件
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

. "$HOME/.local/bin/env"

# ==========================================
# 7. 自动化配置脚本
# ==========================================
# ── Brew 自动化管理 ──────────────────────────────────────────
brew() {
  # 解析参数，提取 --comment 的值
  local args=()
  local comment=""
  local pkg=""
  local is_cask=false
  local skip_next=false

  for arg in "$@"; do
    if $skip_next; then
      comment="$arg"
      skip_next=false
    elif [[ "$arg" == "--comment" ]]; then
      skip_next=true
    else
      args+=("$arg")
      [[ "$arg" == "--cask" ]] && is_cask=true
      # 跳过所有 -- 开头的 flag，取最后一个非 flag 参数作为包名
      # 支持：brew install pkg
      #       brew install --cask pkg
      #       brew install --cask --no-quarantine pkg
      if [[ "${args[1]}" == "install" && "$arg" != --* ]]; then
        pkg="$arg"
      fi
    fi
  done

  # 执行真正的 brew（已去除 --comment 参数）
  command brew "${args[@]}"
  local brew_exit=$?

  # 只在安装成功时记录
  if [[ "${args[1]}" == "install" && $brew_exit -eq 0 && -n "$pkg" ]]; then

    # 获取官方描述（cask 无 desc，用固定文字替代）
    local desc=""
    if $is_cask; then
      desc="(cask - no brew desc available)"
    else
      desc=$(command brew desc "$pkg" 2>/dev/null | sed 's/.*: //')
      [[ -z "$desc" ]] && desc="(no description found)"
    fi

    # 获取安装日期
    local install_date
    install_date=$(date +%Y-%m-%d)

    # 移除旧记录（如果重装同一个包）
    # 找到对应块的起止行并删除
    local notes=~/dotfiles/Brewfile.notes
    if grep -q "^# ── $pkg " "$notes" 2>/dev/null; then
      # 删除从块头到下一个空行（含空行）
      sed -i '' "/^# ── $pkg /,/^$/d" "$notes"
    fi

    # 写入新记录块
    {
      echo ""
      echo "# ── $pkg ──────────────────────────────────"
      echo "installed: $install_date"
      echo "comment:   ${comment:-(无备注)}"
      echo "desc:      $desc"
    } >> "$notes"

    echo "📝 已记录："
    echo "   包名：$pkg"
    echo "   日期：$install_date"
    echo "   备注：${comment:-(无备注)}"
    echo "   描述：$desc"

    # 同步 Brewfile 并注入备注
    ~/dotfiles/brew-sync.sh

    # Git 自动提交
    local commit_msg="brew: install $pkg"
    [[ -n "$comment" ]] && commit_msg="brew: install $pkg ($comment)"

    cd ~/dotfiles
    git add Brewfile Brewfile.notes
    git commit -m "$commit_msg"
    cd - > /dev/null

  elif [[ "${args[1]}" == "uninstall" && $brew_exit -eq 0 ]]; then
    # 卸载时同步 Brewfile（不删除 notes 记录，保留历史）
    ~/dotfiles/brew-sync.sh

    cd ~/dotfiles
    git add Brewfile
    git commit -m "brew: uninstall $pkg"
    cd - > /dev/null

  elif [[ "${args[1]}" == "tap" || "${args[1]}" == "untap" ]]; then
    ~/dotfiles/brew-sync.sh

    cd ~/dotfiles
    git add Brewfile
    git commit -m "brew: ${args[1]} $pkg"
    cd - > /dev/null
  fi

  return $brew_exit
}
# ────────────────────────────────────────────────────────────
#
#
#
#
#
#
#
#
#
#
#
# 先执行 hushlogin 逻辑，然后手动打印自定义内容
# clear
# fastfetch

[[ -t 0 ]] && stty -ixon
bindkey -r '^S'

# 自动进入 tmux
if [[ -z "$TMUX" ]]; then
  tmux attach 2>/dev/null || tmux new-session
fi
