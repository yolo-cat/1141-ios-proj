# Exception Alert Card Design Proposals (Stage 2)

為了突破現有的設計框架，我們參考了 2024-2025 iOS 設計趨勢 (如 Apple Weather, VisionOS, Live Activities)，提出三種截然不同的設計方向。

這些方案皆旨在解決一個核心問題：**「如何讓用戶在 0.5 秒內感知環境狀態，而不僅僅是閱讀文字？」**

## 方案比較概覽

| 特性         | 方案 A: Ambient Aura (氛圍感知) | 方案 B: Smart HUD (智慧儀表)  | 方案 C: Glass Insight (透視玻璃) |
| :----------- | :------------------------------ | :---------------------------- | :------------------------------- |
| **設計哲學** | **Emotional (情緒化)**          | **Technical (技術化)**        | **Spatial (空間感)**             |
| **核心視覺** | 動態呼吸漸層 (Mesh/Gradient)    | 高對比黑底/數據網格           | 磨砂玻璃 (Blur) + 浮雕           |
| **資訊密度** | 低 (專注於感覺)                 | 高 (專注於數據細節)           | 中 (平衡資訊與美感)              |
| **適用風格** | 類似 Apple Weather / Home       | 類似 Tesla / Activity Monitor | 類似 VisionOS / Control Center   |

---

## Proposal 1: Ambient Aura (氛圍感知)

> **"讓狀態成為背景，而非標籤。"**

此方案不使用單一的「狀態燈」或「圖標」，而是讓**整張卡片的背景**隨著環境狀態緩慢呼吸。

### 視覺細節

- **Normal**: 背景使用極淡的 `Mint` 到 `Blue` 的對角線漸層，模擬清新的空氣流動。
- **Alert**: 背景轉為 `Orange` 到 `Red` 的動態漸層，伴隨輕微的 `easeInOut` 縮放動畫 (Heartbeat)。
- **Typography**: 大量的白色空間，字體採用 `.design(.rounded)`，與柔和的背景融合。

### Code Concept (SwiftUI)

```swift
ZStack {
    LinearGradient(
        colors: isCritical ? [.red.opacity(0.8), .orange.opacity(0.8)] : [.blue.opacity(0.1), .green.opacity(0.1)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // Content floating above...
}
```

### 優點

- **極致的視覺衝擊**：一眼就能辨識好壞。
- **美學升級**：打破傳統 Bento Grid 的「白底黑字」沈悶感。

---

## Proposal 2: Smart HUD (智慧儀表)

> **"數據即是真相。"**

靈感來自 F1 賽車儀表或 Server Dashboard。此方案將「數據」與「狀態」強關聯。即使在 "系統正常" 時，也顯示關鍵指標摘要。

### 視覺細節

- **Card**: 強制使用 **深色背景 (Charcoal/Black)**，即使在 Light Mode 下亦然，創造精密的儀器感。
- **Status Bar**: 左側有一條垂直的狀態光條 (Neon Green / Neon Red)。
- **Layout**:
  - 左側：巨大的狀態文字 "NORMAL" (Monospaced)。
  - 右側：微型數據列表 (e.g., "Temp: 24°C ✓", "Hum: 60% ✓")，打勾表示該指標正常。

### 優點

- **高專業感**：適合強調「監控」的場景。
- **資訊透明**：用戶知道「為什麼」正常。

---

## Proposal 3: Glass Insight (透視玻璃)

> **"懸浮於資訊之上的清晰洞察。"**

靈感來自 VisionOS 與現代 iOS 通知。強調**層次感**與**材質**。

### 視覺細節

- **Material**: 使用 `.ultraThinMaterial` 作為背景。
- **Dynamic Content**:
  - **Normal**: 顯示一個大的、3D 渲染風格的 Shield 或 Leaf 圖標 (使用 SF Symbol 渲染模式 `.hierarchical`)。
  - **Alert**: 卡片中央出現波紋效果，並顯示具體的錯誤訊息 (e.g., "Humidity High") 而非泛泛的 "System Alert"。
- **Action**: 右下角常駐一個明顯的 "Check" 箭頭按鈕，暗示可以點擊查看詳情。

### Code Concept (SwiftUI)

```swift
ZStack {
    Color.stone50 // Underlying consistency

    VisualEffectView(material: .ultraThinMaterial)

    HStack {
        // ... Glassy Content
    }
}
.clipShape(RoundedRectangle(cornerRadius: 32))
```

### 優點

- **原生感強**：與 iOS 系統設計語言高度一致。
- **輕盈**：不會讓儀表板看起來太厚重。
