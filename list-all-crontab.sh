#!/bin/bash
# 印出系統上所有帳號的crontab

# 遍歷系統上的所有帳號
getent passwd | while IFS=: read -r username _; do
  # 嘗試獲取用戶的crontab
  crontab_content=$(crontab -l -u "$username" 2>/dev/null)

  # 檢查用戶是否有crontab設定
  if [[ -n $crontab_content ]]; then
    echo "帳號: $username"
    echo "Crontab 內容:"
    echo "$crontab_content"
    echo "---------------------------------"
  fi
  # 如果沒有crontab設定，則跳過當前循環的剩餘部分
done
