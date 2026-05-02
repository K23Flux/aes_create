#!/bin/bash

# 定义脚本下载地址
# 注意：这里已经加上了 go/ 路径
GITHUB_USER="K23Flux"
REPO_NAME="aes_create"
BRANCH="main"
SCRIPT_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${REPO_NAME}/${BRANCH}/go/keygen.sh"

# 临时文件路径
TMP_FILE="/tmp/vps_keygen.sh"

# 下载脚本
echo "正在下载脚本..."
curl -fsSL "$SCRIPT_URL" -o "$TMP_FILE"

# 检查下载是否成功
if [ ! -s "$TMP_FILE" ]; then
    echo "下载失败，请检查网络或 URL 地址。"
    echo "尝试访问的地址: $SCRIPT_URL"
    exit 1
fi

# 赋予权限并执行
chmod +x "$TMP_FILE"
bash "$TMP_FILE"

# 运行结束后自动删除
rm "$TMP_FILE"
