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
    echo -e "${1}:"
    echo -e "${color}${value}${NC}\n"
}

# Hex 转 Base64 (兼容纯 Shell 环境)
hex_to_base64() {
    local hex_clean=$(echo "$1" | tr -d ': ')
    if command -v xxd >/dev/null 2>&1; then
        echo -n "$hex_clean" | xxd -r -p | base64 | tr -d '\n'
    else
        local escape_hex=$(echo "$hex_clean" | sed 's/../\\x&/g')
        printf "$escape_hex" | base64 | tr -d '\n'
    fi
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

    local key=$(openssl rand -base64 $len)
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
    print_result "UUID" "$uuid"
}

generate_socks() {
    print_header "Socks5 账号密码"
    local rand_user=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 6)
    local user="user_$rand_user"
    local pass=$(tr -dc 'a-zA-Z0-9!@#%^&*' < /dev/urandom | head -c 20)
    
    print_result "Username" "$user"
    print_result "Password" "$pass"
}

generate_reality() {
    print_header "Reality (X25519) 密钥对"
    
    if ! command -v openssl >/dev/null 2>&1; then
        echo -e "${RED}错误: 未找到 openssl，请先安装 (apt/yum install openssl)${NC}"
        return
    fi

    local tmp_dir=$(mktemp -d)
    local priv_pem="$tmp_dir/priv.pem"
    
    # 生成私钥 PEM
    openssl genpkey -algorithm x25519 -out "$priv_pem" 2>/dev/null
    
    # 提取 hex 数据
    local full_text=$(openssl pkey -in "$priv_pem" -text 2>/dev/null)
    local priv_hex=$(echo "$full_text" | awk '/priv:/{flag=1; next} /pub:/{flag=0} flag {print}' | tr -d '\n: ')
    local pub_hex=$(echo "$full_text" | awk '/pub:/{flag=1; next} flag {print}' | tr -d '\n: ')

    # 转换为 Base64
    local priv_b64=$(hex_to_base64 "$priv_hex")
    local pub_b64=$(hex_to_base64 "$pub_hex")

    print_result "Private Key (服务端)" "$priv_b64" "$RED"
    print_result "Public Key (客户端)" "$pub_b64" "$GREEN"

    rm -rf "$tmp_dir"
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
