## Domain_mx 監控

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

### 完整參數說明

| 參數 | 必填 | 預設值 | 說明 |
|---|:---:|---|---|
| `-d <domain>`<br>`--domain <domain>` | 是 | 無 | 要檢查的網域名稱，例如 `example.com`。僅接受英文字母、數字、句點與連字號；腳本會自動轉為小寫並移除結尾句點。 |
| `-e <records>`<br>`--expected <records>` | 否 | 無 | 預期的 MX 清單，格式為 `優先權:主機名稱`，多筆以逗號分隔，例如 `1:mx1.example.com,10:mx2.example.com`。提供此參數後，腳本會檢查缺少的 MX；除非搭配 `--allow-extra`，也會將多出的 MX 判定為 CRITICAL。清單中的空白會自動忽略。 |
| `-s <server>`<br>`--server <server>` | 否 | 系統預設 DNS | 指定供 `dig` 查詢使用的 DNS Server，例如 `8.8.8.8`。同時套用於 MX 查詢與 MX 目標的 A/AAAA 解析檢查。 |
| `-t <seconds>`<br>`--timeout <seconds>` | 否 | `5` | 每一個 `dig` 查詢的逾時秒數；必須是大於 0 的整數。腳本每次查詢只嘗試一次。 |
| `--allow-extra` | 否 | 關閉 | 允許查到預期清單以外的額外 MX 記錄。此選項只在有設定 `-e/--expected` 時影響比對結果；即使開啟，預期 MX 缺少時仍會回傳 CRITICAL。 |
| `--no-resolve-check` | 否 | 關閉 | 略過每個 MX 目標的 A／AAAA 解析檢查。適用於 DNS 分割視域或 MX 主機無法從監控主機解析的情況。 |
| `-h`<br>`--help` | 否 | 無 | 顯示使用方式與參數概要後結束，exit code 為 `0`。 |

範例：使用指定 DNS Server、允許額外 MX，並將每次 DNS 查詢逾時設為 10 秒：

```text
-d example.com -e "1:mx1.example.com,10:mx2.example.com" -s 8.8.8.8 -t 10 --allow-extra
```

未列於上表的參數不是支援的介面；目前腳本會略過未知參數，建議不要使用，以免設定錯誤未被察覺。

## Nagios 狀態碼

| 狀態 | Exit code |
|---|---:|
| OK | 0 |
| WARNING | 1 |
| CRITICAL | 2 |
| UNKNOWN | 3 |