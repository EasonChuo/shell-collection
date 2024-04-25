#!/bin/bash
# CONFIG_FILE 應包含一些腳本配置的變量設定。例如：
# VERSION_REGEX_BASE='v{version}\.\d+\.\d+' # 用於特定版本號的正則表達式
# 該文件應該位於腳本同一目錄下，並用於覆蓋上述的預設值。
# 設定 Bash 指令稿在指令失敗、使用未定義變數或管道指令失敗時立即退出。
set -Eeuo pipefail
# 如果未指定版本，預設下載的 Tomcat 版本。
readonly SUPPORTED_VERSIONS=("8" "9")
# 用於在 HTML 中找到 Tomcat 版本號的正則表達式模式。
readonly VERSION_REGEX_BASE='v{version}\.\d+\.\d+'
# 可選的配置檔案路徑。
readonly CONFIG_FILE="config.cfg"
# 預設下載路徑，可以透過 CONFIG_FILE 或命令行參數修改。
DOWNLOAD_PATH="/home/tomcat"

# 在標準輸出上輸出帶時間戳的訊息。
log() {
    echo "[$(date +%Y-%m-%dT%H:%M:%S%z)] $@"
}

# 在標準錯誤上輸出錯誤訊息並退出。
error_exit() {
    log "$1" 1>&2
    exit 1
}

# 檢查環境中是否存在必要的指令。
check_dependency() {
    local dependency=$1
    command -v $dependency >/dev/null 2>&1 || error_exit "所需的指令未找到：$dependency"
}

# 如果可用，從檔案載入配置，否則記錄使用預設值。
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    else
        log "配置檔案未找到，使用預設值。"
    fi
}

# 使用 curl 從給定的 URL 取得 HTML 內容。
fetch_html() {
    local url=$1
    log "從 $url 取得 HTML 內容"
    curl -s "$url"
}

# 解析 HTML 內容以使用正則表達式模式找到 Tomcat 的最新版本。
find_latest_version() {
    local html_content=$1
    local version_pattern=$2
    echo "$html_content" | grep -oP "$version_pattern" | sort -V | tail -1
}

# 使用 curl 將檔案從 URL 下載到指定路徑。
download_file() {
    local url=$1
    local file_name=$2
    local download_path=$3
    if [[ -f "$download_path/$file_name" ]]; then
        log "$file_name 已存在於 $download_path 中。"
        read -p "是否覆蓋現有檔案？(y/N): " confirm
        if [[ "$confirm" != [yY] ]]; then
            log "跳過下載 $file_name"
            return 0
        fi
    fi
    log "從 $url 下載 $file_name 到 $download_path"
    curl -o "$download_path/$file_name" "$url" || error_exit "下載失敗：$file_name"
}

# 使用 SHA512 校驗和驗證下載的檔案的完整性。
verify_file() {
    local file_name=$1
    local download_path=$2
    log "驗證 $download_path/$file_name"
    (cd "$download_path" && sha512sum -c "${file_name}.sha512") || error_exit "檔案驗證失敗，哈希值不匹配！"
}

# 將 tar.gz 檔案解壓縮到指定目錄。
extract_file() {
    local file_name=$1
    local target_directory=$2
    local version_number=$3
    log "將 $file_name 解壓縮到 $target_directory"
    mkdir -p "$target_directory"
    tar -xzf "$file_name" -C "$target_directory" || error_exit "解壓縮 $file_name 失敗"
    chown -R tomcat:tomcat "$target_directory"
    chown -R root:root "${target_directory}/apache-tomcat-${version_number}/logs"
}

# 主函式，協調下載、驗證和解壓 Tomcat。
main() {
    # 載入配置
    load_config
    local versions=("$@")
    if [[ ${#versions[@]} -eq 0 ]]; then
        versions=("${SUPPORTED_VERSIONS[@]}")
    fi
    for version in "${versions[@]}"; do
        local base_url="https://downloads.apache.org/tomcat/tomcat-$version"
        local version_regex=$(echo "$VERSION_REGEX_BASE" | sed "s/{version}/$version/")
        local html=$(fetch_html "$base_url/") || error_exit "無法檢索 Tomcat 下載頁面。"
        local latest_version=$(find_latest_version "$html" "$version_regex")
        if [[ -z "$latest_version" ]]; then
            error_exit "未找到 Tomcat $version 的最新版本。"
        fi
        log "Tomcat $version 的最新版本：$latest_version"
        local version_number=${latest_version#v}
        local file_name="apache-tomcat-${version_number}.tar.gz"
        local download_url="$base_url/v${version_number}/bin/${file_name}"
        local sha512_url="${download_url}.sha512"
        download_file "$download_url" "$file_name" "$DOWNLOAD_PATH"
        download_file "$sha512_url" "${file_name}.sha512" "$DOWNLOAD_PATH"
        verify_file "$DOWNLOAD_PATH/$file_name" "$DOWNLOAD_PATH"
        extract_file "$DOWNLOAD_PATH/$file_name" "$DOWNLOAD_PATH" "$version_number"
    done
}
# 呼叫主函式並傳遞所有命令列參數。
main "$@"