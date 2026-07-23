# Librenms Nagios監控腳本

本儲存庫提供可掛載到 LibreNMS Services 的 Nagios 相容監控腳本。

## 1. RDAP Domain監控

檔案：

```text
check_domain_rdap
```

功能：

- 使用 RDAP 查詢網域註冊到期時間
- 支援 Warning 與 Critical 剩餘天數門檻
- 將到期時間顯示為台灣時間 UTC+8
- 使用本機快取降低 RDAP 查詢頻率與 HTTP 429 限流
- 查詢暫時失敗時，可使用 7 天內的舊資料
- 符合 Nagios exit code，可直接套用於 LibreNMS Services

### 安裝

安裝相依套件：

```bash
sudo apt update
sudo apt install curl jq util-linux
```

複製腳本：

```bash
sudo cp check_domain_rdap /usr/lib/nagios/plugins/
sudo chown root:librenms /usr/lib/nagios/plugins/check_domain_rdap
sudo chmod 755 /usr/lib/nagios/plugins/check_domain_rdap
```

建立快取目錄：

```bash
sudo install -d \
  -o librenms \
  -g librenms \
  -m 750 \
  /var/cache/librenms/check_domain_rdap
```

測試：

```bash
sudo -u librenms \
  /usr/lib/nagios/plugins/check_domain_rdap \
  -d example.com \
  -w 30 \
  -c 7
```

LibreNMS Service Parameters：

```text
-d example.com -w 30 -c 7
```

## 2. Domain_mx 監控

檔案：

```text
check_domain_mx
```

功能：

- 查詢網域 MX 記錄
- 驗證 MX 主機名稱與 Priority 是否符合預期
- 偵測缺少或多出的 MX 記錄
- 檢查 MX 目標是否可解析 A 或 AAAA
- 可指定 DNS Server
- 可選擇允許額外 MX 記錄
- 符合 Nagios exit code，可直接套用於 LibreNMS Services

### 安裝

安裝相依套件：

```bash
sudo apt update
sudo apt install dnsutils
```

複製腳本：

```bash
sudo cp check_domain_mx /usr/lib/nagios/plugins/
sudo chown root:librenms /usr/lib/nagios/plugins/check_domain_mx
sudo chmod 755 /usr/lib/nagios/plugins/check_domain_mx
```

Google Workspace 範例：

```bash
sudo -u librenms \
  /usr/lib/nagios/plugins/check_domain_mx \
  -d example.com \
  -e "1:aspmx.l.google.com,5:alt1.aspmx.l.google.com,5:alt2.aspmx.l.google.com,10:alt3.aspmx.l.google.com,10:alt4.aspmx.l.google.com" \
  -t 5
```

LibreNMS Service Parameters：

```text
-d example.com -e "1:aspmx.l.google.com,5:alt1.aspmx.l.google.com,5:alt2.aspmx.l.google.com,10:alt3.aspmx.l.google.com,10:alt4.aspmx.l.google.com" -t 5
```

### 其他參數

指定 DNS Server：

```text
-s 8.8.8.8
```

允許預期清單以外的額外 MX：

```text
--allow-extra
```

略過 MX 目標 A/AAAA 解析檢查：

```text
--no-resolve-check
```

## Nagios 狀態碼

| 狀態 | Exit code |
|---|---:|
| OK | 0 |
| WARNING | 1 |
| CRITICAL | 2 |
| UNKNOWN | 3 |
