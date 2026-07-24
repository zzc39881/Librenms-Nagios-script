## RDAP Domain監控

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

### 實際執行範例

以下結果於 2026-07-24 在 Ubuntu 22.04 實際執行取得：

```bash
sudo -u librenms \
  /usr/lib/nagios/plugins/check_domain_rdap \
  -d example.com \
  -w 30 \
  -c 7
```

輸出：

```text
WARNING - example.com 剩餘 20 天，到期時間：2026-08-13 12:00:00 UTC+8
```

Exit code：

```text
1
```

此例的剩餘天數為 20 天，低於或等於 Warning 門檻 30 天、但高於 Critical 門檻 7 天，因此回傳 `WARNING`。實際輸出會依執行日期及 RDAP 回傳的網域資料而變動。

LibreNMS Service Parameters：

```text
-d example.com -w 30 -c 7
```
