#!/bin/bash

DOTFILES=~/dotfiles
NOTES=$DOTFILES/Brewfile.notes
BREWFILE=$DOTFILES/Brewfile

# 1. dump 当前已安装的所有包
brew bundle dump --force --file=$BREWFILE

# 2. 读取备注文件，注入到 Brewfile
while IFS= read -r line; do
  # 跳过空行和注释行
  [[ -z "$line" || "$line" == \#* ]] && continue

  # 匹配 "包名: 备注" 格式
  if [[ "$line" =~ ^([a-zA-Z0-9_@/-]+):\ (.+)$ ]]; then
    pkg="${BASH_REMATCH[1]}"
    note="${BASH_REMATCH[2]}"

    # 在 Brewfile 找到对应行，在其上方插入注释
    # 先移除旧注释（避免重复），再插入新注释
    sed -i '' "/^# $note$/d" $BREWFILE
    sed -i '' "s|.*\"$pkg\".*|# $note\n&|" $BREWFILE
  fi
done < $NOTES

echo "✅ Brewfile 已同步并注入备注"
