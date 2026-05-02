#!/bin/bash

# --- 颜色定义 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- 辅助函数 ---

print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e " ${1}"
    echo -e "${CYAN}========================================${NC}"
}

print_result() {
    local label=$1
    local value=$2
    local color=${3:-$GREEN} 
    echo -e "${label}:"
    echo -e "${color}${value}${NC}\n"
}

# Hex 转 Reality 需要的 URL-safe Base64，无 padding
hex_to_base64_url() {
    local hex_clean
    hex_clean=$(echo "$1" | tr -d ':[:space:]')

    if [ -z "$hex_clean" ]; then
        return 1
    fi

    if command -v xxd >/dev/null 2>&1; then
        printf '%s' "$hex_clean" | xxd -r -p | base64 | tr '+/' '-_' | tr -d '=\n'
    else
        local escape_hex
        escape_hex=$(echo "$hex_clean" | sed 's/../\\x&/g')
        printf '%b' "$escape_hex" | base64 | tr '+/' '-_' | tr -d '=\n'
    fi
}

extract_key_value() {
    echo "$1" | awk -F': *' -v name="$2" 'tolower($1) == name {print $2; exit}'
}

# --- 功能模块 ---

generate_ss() {
    print_header "Shadowsocks-2022 密钥生成"
    echo "1. 2022-blake3-aes-128-gcm (16 bytes)"
    echo "2. 2022-blake3-aes-256-gcm (32 bytes)"
    read -p "请选择类型 [1/2]: " choice

    local len=16
    if [ "$choice" == "2" ]; then
        len=32
    fi

    local key
    key=$(openssl rand -base64 "$len")
    print_result "Key (${len} bytes)" "$key"
}

generate_uuid() {
    print_header "VLESS / VMESS UUID"
    local uuid=""
    if [ -f /proc/sys/kernel/random/uuid ]; then
        uuid=$(cat /proc/sys/kernel/random/uuid)
    else
        uuid=$(uuidgen)
    fi
    uuid=$(echo "$uuid" | tr '[:upper:]' '[:lower:]')
    print_result "UUID" "$uuid"
}

generate_socks() {
    print_header "Socks5 账号密码"
    local rand_user
    rand_user=$(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom | head -c 6)
    local user="user_$rand_user"
    local pass
    pass=$(LC_ALL=C tr -dc 'a-zA-Z0-9!@#%^&*' < /dev/urandom | head -c 20)
    
    print_result "Username" "$user"
    print_result "Password" "$pass"
}

generate_reality() {
    print_header "Reality (X25519) 密钥对"

    local output=""
    local priv_b64=""
    local pub_b64=""

    if command -v xray >/dev/null 2>&1; then
        output=$(xray x25519 2>/dev/null)
        priv_b64=$(extract_key_value "$output" "private key")
        pub_b64=$(extract_key_value "$output" "public key")
    elif command -v sing-box >/dev/null 2>&1; then
        output=$(sing-box generate reality-keypair 2>/dev/null)
        priv_b64=$(extract_key_value "$output" "privatekey")
        pub_b64=$(extract_key_value "$output" "publickey")
    fi

    if [ -n "$priv_b64" ] && [ -n "$pub_b64" ]; then
        print_result "Private Key (服务端)" "$priv_b64" "$RED"
        print_result "Public Key (客户端)" "$pub_b64" "$GREEN"
        return
    fi

    if ! command -v openssl >/dev/null 2>&1; then
        echo -e "${RED}错误: 未找到 xray、sing-box 或 openssl，无法生成 Reality 密钥对。${NC}"
        return 1
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)
    local priv_pem="$tmp_dir/priv.pem"
    
    if ! openssl genpkey -algorithm x25519 -out "$priv_pem" 2>/dev/null; then
        rm -rf "$tmp_dir"
        echo -e "${RED}错误: 当前 openssl 不支持 X25519，请安装 xray 或 sing-box 后重试。${NC}"
        return 1
    fi
    
    local full_text
    full_text=$(openssl pkey -in "$priv_pem" -text -noout 2>/dev/null)
    local priv_hex
    local pub_hex
    priv_hex=$(echo "$full_text" | awk '/priv:/{flag=1; next} /pub:/{flag=0} flag {print}' | tr -d '\n:[:space:]')
    pub_hex=$(echo "$full_text" | awk '/pub:/{flag=1; next} flag {print}' | tr -d '\n:[:space:]')

    priv_b64=$(hex_to_base64_url "$priv_hex")
    pub_b64=$(hex_to_base64_url "$pub_hex")

    rm -rf "$tmp_dir"

    if [ -z "$priv_b64" ] || [ -z "$pub_b64" ]; then
        echo -e "${RED}错误: Reality 密钥解析失败，请安装 xray 或 sing-box 后重试。${NC}"
        return 1
    fi

    print_result "Private Key (服务端)" "$priv_b64" "$RED"
    print_result "Public Key (客户端)" "$pub_b64" "$GREEN"
}

# --- 主程序 ---

while true; do
    echo -e "\n${YELLOW}--- VPS 密钥生成工具 (Shell版) ---${NC}"
    echo "1. Shadowsocks-2022 Key"
    echo "2. VLESS / Reality Key Pair"
    echo "3. UUID (VLESS/VMESS)"
    echo "4. Socks5 User/Pass"
    echo "0. 退出"
    
    read -p "请输入选项: " opt
    
    case $opt in
        1) generate_ss ;;
        2) generate_reality; generate_uuid ;;
        3) generate_uuid ;;
        4) generate_socks ;;
        0) echo "再见!"; exit 0 ;;
        *) echo -e "${RED}无效选项${NC}" ;;
    esac
    
    echo -e "${CYAN}按回车键继续...${NC}"
    read temp
done
