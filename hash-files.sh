#!/bin/bash
# ------------------------------------------------------------------
# [Eason] hash並保存重要檔案
#         hash並保存重要log檔案
#         可自選hash演算法
# ------------------------------------------------------------------
SUBJECT=hash-files
VERSION=1.0
USAGE="Usage: command"
LOCK_FILE=/tmp/${SUBJECT}.lock
if [ -f "$LOCK_FILE" ]; then
    echo "Script is already running"
    exit
fi
# -----------------------------------------------------------------
trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE

# 設置目標目錄，依實際需求調整
DEST_DIR="/root/log"
# 定義保留天數變數，依實際需求調整
RETENTION_DAYS=200
# 定義日誌文件匹配模式，依實際需求調整
FILE_PATTERN="/var/log/secure-*"
# 預設哈希算法
DEFAULT_HASH_ALGO="sha256"

# 函數：移動文件並生成SHA256哈希
move_and_hash() {
    local file="$1"
    local filename
    filename=$(basename "$file")
    local dest_file="$DEST_DIR/$filename"
    local hash_algo="${2:-$DEFAULT_HASH_ALGO}"  # 哈希算法參數，預設為 sha256
    local hash_file="${dest_file}.${hash_algo}"
    # 檢查文件是否存在且可讀
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        logger -p user.err "Error: $file is not a readable file."
        return 1
    fi
    # 移動文件到目標目錄
    mv "$file" "$dest_file"
    # 生成哈希
    case $hash_algo in
        "md5")
            md5sum "$dest_file" > "$hash_file"
            ;;
        "sha1")
            sha1sum "$dest_file" > "$hash_file"
            ;;
        "sha256")
            sha256sum "$dest_file" > "$hash_file"
            ;;
        "sha512")
            sha512sum "$dest_file" > "$hash_file"
            ;;
        *)
            logger -p user.err "Error: Unsupported hash algorithm."
            exit 1
            ;;
    esac
    # 檔案權限改為唯獨
    chmod 400 "$dest_file"
    chmod 400 "$hash_file"
    logger -p user.info "Moved and hashed $file using $hash_algo"
}

# 函數：刪除超過指定天數的文件
delete_old_files() {
    find "$DEST_DIR" -type f -mtime +"$RETENTION_DAYS" -exec rm {} +
    logger -p user.info "Deleted files older than $RETENTION_DAYS days in $DEST_DIR"
}

# 主要邏輯
main() {
    # 檢查目標目錄是否存在，如果不存在則創建
    if [ ! -d "$DEST_DIR" ]; then
        mkdir -p "$DEST_DIR" || { logger -p user.err "Error creating $DEST_DIR"; exit 1; }
    fi
    # 檢查日誌文件是否存在，如果存在則處理
    shopt -s nullglob
    files=($FILE_PATTERN)
    if [ ${#files[@]} -eq 0 ]; then
        logger -p user.warning "No files matching $FILE_PATTERN found."
        exit 1
    fi
    # 逐個處理文件
    for file in "${files[@]}"; do
        move_and_hash "$file" "$1" || continue
    done
    # 刪除超過指定天數的文件
    delete_old_files
}

# 執行主要邏輯，哈希算法參數默認為 sha256
main "$1"