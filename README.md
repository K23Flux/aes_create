# VPS 密钥生成工具 (VPS Key Generator)

一个轻量级密钥生成工具，可在本地生成 Shadowsocks-2022、VLESS/Reality、UUID 和 Socks5 账号密码。项目同时提供 Shell 终端版和浏览器静态页面版。

## 特性

- 本地生成：密钥生成过程不上传到服务器。
- Shell 版：适合直接在 VPS SSH 终端中使用。
- Web 版：单文件静态页面，可用 Nginx 或任意静态站点托管。
- Reality 支持：优先使用 `xray` 或 `sing-box` 生成官方格式密钥对。

## 快速使用

在 VPS 终端执行：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/K23Flux/aes_create/main/go/keygen.sh)
```

也可以先下载再运行：

```bash
curl -fsSL https://raw.githubusercontent.com/K23Flux/aes_create/main/go/run.sh | bash
```

## Reality 密钥说明

Reality 使用 X25519 密钥对，输出格式为 URL-safe Base64 且不带 `=` padding。

Shell 版生成 Reality 密钥时会按顺序尝试：

1. `xray x25519`
2. `sing-box generate reality-keypair`
3. 支持 X25519 的 `openssl`

如果系统自带的是 `LibreSSL` 或较旧版本 `openssl`，可能不支持 X25519。此时请先安装 `xray` 或 `sing-box`。

## Web 版

直接打开：

```text
html/index.html
```

Web 版依赖浏览器的 `crypto.getRandomValues()`，Reality 密钥生成依赖页面加载的 `tweetnacl` 库。

## Docker 部署

从仓库根目录构建：

```bash
docker build -f docker/Dockerfile -t aes-create .
docker run --rm -p 8080:80 aes-create
```

然后访问：

```text
http://localhost:8080
```
