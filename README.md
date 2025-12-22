# VPS 密钥生成工具 (VPS Key Generator)

这是一个纯 Shell 编写的轻量级工具，零依赖，用于在任何 Linux VPS 上快速生成 Shadowsocks-2022、VLESS/Reality 和 Socks5 的密钥及配置参数。

## ✨ 特性

- **零依赖**：不需要 Python、Node.js 或其他运行环境，系统自带 `bash` 和 `openssl` 即可运行。
- **安全**：所有密钥均在本地内存中生成，不经过网络传输。
- **Reality 支持**：自动生成 X25519 密钥对（Private/Public Key）。
- **方便快捷**：一行命令即可启动。

## 🚀 快速使用

在你的 VPS 终端（SSH）中执行以下命令即可启动工具：

```
bash <(curl -sL https://raw.githubusercontent.com/K23Flux/aes_create/main/go/keygen.sh)
```
