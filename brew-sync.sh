#!/bin/bash

DOTFILES=~/dotfiles
NOTES=$DOTFILES/Brewfile.notes
BREWFILE=$DOTFILES/Brewfile

# ── 迁移旧格式（pkg: comment → 新块格式）──────────────────
TEMP=$(mktemp)
migrated=false

while IFS= read -r line; do
  # 空行直接保留
  if [[ -z "$line" ]]; then
    echo "" >> "$TEMP"
    continue
  fi

  # 已经是新格式的行（# ── 块头、installed:、comment:、desc:）直接保留
  if [[ "$line" == \#* || "$line" =~ ^(installed|comment|desc): ]]; then
    echo "$line" >> "$TEMP"
    continue
  fi

  # 匹配旧格式：pkg: comment
  if [[ "$line" =~ ^([a-zA-Z0-9_@/.+-]+):\ (.+)$ ]]; then
    local_pkg="${BASH_REMATCH[1]}"
    local_comment="${BASH_REMATCH[2]}"

    # 获取官方描述
    local_desc=$(command brew desc "$local_pkg" 2>/dev/null | sed 's/.*: //')
    [[ -z "$local_desc" ]] && local_desc="(no description found)"

    # 写成新格式
    {
      echo ""
      echo "# ── $local_pkg ──────────────────────────────────"
      echo "installed: unknown"
      echo "comment:   $local_comment"
      echo "desc:      $local_desc"
    } >> "$TEMP"

    migrated=true
  else
    echo "$line" >> "$TEMP"
  fi
done < "$NOTES"

# 如果有迁移，替换原文件
if $migrated; then
  mv "$TEMP" "$NOTES"
  echo "🔄 旧格式已迁移完成"
else
  rm "$TEMP"
fi

# ── dump 当前已安装的所有包 ────────────────────────────────
brew bundle dump --force --file=$BREWFILE

# ── 将 Brewfile.notes 的备注注入到 Brewfile ───────────────
current_pkg=""
current_comment=""

while IFS= read -r line; do
  # 匹配块头：# ── pkg ───
  if [[ "$line" =~ ^#\ ──\ ([a-zA-Z0-9_@/.+-]+)\ ─ ]]; then
    current_pkg="${BASH_REMATCH[1]}"
    current_comment=""
  fi

  # 匹配 comment 行
  if [[ "$line" =~ ^comment:[[:space:]]+(.+)$ ]]; then
    current_comment="${BASH_REMATCH[1]}"
  fi

  # 空行代表一个块结束，注入备注
  if [[ -z "$line" && -n "$current_pkg" && -n "$current_comment" && "$current_comment" != "(无备注)" ]]; then
    python3 - "$BREWFILE" "$current_pkg" "$current_comment" <<'PY'
import sys
from pathlib import Path

brewfile = Path(sys.argv[1])
pkg = sys.argv[2]
comment = sys.argv[3]
text = brewfile.read_text()
lines = text.splitlines()
out = []
i = 0
inserted = False
while i < len(lines):
    line = lines[i]
    if line == f'# {comment}':
        i += 1
        continue
    if f'"{pkg}"' in line:
        if not out or out[-1] != f'# {comment}':
            out.append(f'# {comment}')
        out.append(line)
        inserted = True
    else:
        out.append(line)
    i += 1
brewfile.write_text('\n'.join(out) + ('\n' if text.endswith('\n') else ''))
PY
    current_pkg=""
    current_comment=""
  fi
done < "$NOTES"

echo "✅ Brewfile 已同步并注入备注"
