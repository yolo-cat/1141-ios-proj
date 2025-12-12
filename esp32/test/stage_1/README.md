# ESP32 Stage 1 測試（TDD Scaffold）

此資料夾提供 Stage 1 的邏輯層測試腳本（Unity），可在 PlatformIO 執行：

```bash
pio test -e native
```

> 需具備 PlatformIO 及 Unity 測試框架（PlatformIO 預設提供）。測試聚焦純邏輯，未連結 Wi-Fi、DHT 或 HTTP。

## 檔案
- `test_stage1.cpp`：檢查 Payload 結構、NaN 濾除、標準/ Demo 週期等純邏輯行為。

## 關聯文件
- `../../TEST_ESP32_STAGE1.md`
- `../../PRD_ESP32_STAGE_1.md`
- `../../DESIGN_ESP32_STAGE_1.md`
