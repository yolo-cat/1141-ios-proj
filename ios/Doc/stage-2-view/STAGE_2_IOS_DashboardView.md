# iOS 設計規格書 (Stage 2) - Neo-Bento Edition

## 1. 設計理念 (Design Philosophy)

本階段全面採用 **Neo-Bento (新便當盒風格)** 設計語言。

- **核心概念**：**Modularity (模組化)**、**Tactility (觸感)**、**Boldness (大膽)**。
- **視覺目標**：捨棄傳統的列表式資訊，改以「高飽和度圖塊」與「非對稱網格」構建具有強烈視覺衝擊力的儀表板，讓數據一目了然，並賦予 App 現代科技精品的質感。

---

## 2. 視覺規範 (Visual System)

### 2.1 色彩計畫 (Color Palette)

強調高對比與活力，區分「數據層」與「背景層」。

| 角色                | Light Mode                | Dark Mode                 | 用途                          |
| :------------------ | :------------------------ | :------------------------ | :---------------------------- |
| **Canvas**          | `#F2F2F7` (System Gray 6) | `#1C1C1E` (System Gray 6) | 全局背景，保持柔和            |
| **Card (Standard)** | `#FFFFFF`                 | `#2C2C2E`                 | 一般內容卡片                  |
| **Primary**         | `#5856D6` (Indigo)        | `#5E5CE6` (Indigo)        | **核心數據 (Hero)**、主要按鈕 |
| **Accent A**        | `#FFD60A` (Yellow)        | `#FFD60A` (Yellow)        | 警告、狀態標示                |
| **Accent B**        | `#32D74B` (Green)         | `#30D158` (Green)         | 正常狀態、成功訊息            |
| **Danger**          | `#FF3B30` (Red)           | `#FF453A` (Red)           | 錯誤、嚴重警報                |

### 2.2 排版系統 (Typography)

使用 System Font (San Francisco)，但嚴格限制樣式以建立強烈層級。

- **Hero Number**: `Font.system(size: 48, weight: .black, design: .monospaced)`  
  _用途：即時溫度、濕度大數值_
- **Grid Header**: `Font.system(size: 34, weight: .heavy, design: .rounded)`  
  _用途：頁面大標題 (Dashboard / Welcome)_
- **Card Title**: `Font.system(size: 18, weight: .bold, design: .default)`  
  _用途：卡片標題_
- **Label**: `Font.caption.uppercase().tracking(2)`  
  _用途：微型標籤 (CURRENT, STATUS)_

### 2.3 形狀與質感 (Geometry & Effects)

- **Corner Radius**: `24px` (Continuous) — 介於圓與方之間的飽滿圓角。
- **Gaps**: `16px` — 緊湊的卡片間距。
- **Shadows**:
  - **Floating**: `Color.black.opacity(0.1), radius: 12, y: 6` (讓卡片浮起)
  - **Press**: `scale(0.96)` + `opacity(0.9)` (點擊回饋)

---

## 3. 組件規格 (Component Specifications)

### 3.1 登入視圖 (Login View)

_取代原有的茶餅插畫風格，改為現代化的高張力排版。_

- **佈局**: `VStack` 居中，直接置於 Canvas 背景，無外框。
- **Header**:
  - 顯示超大 **"PU'ER"** 字樣 (`.rounded`, `.black`, `60pt`)。
  - 使用 Primary Gradient 填充文字或使用 Outline 描邊效果。
- **Inputs**:
  - `HStack` 結構，高度 `64px`，圓角 `24px`。
  - 背景色：Standard Card Color。
  - 圖標：左側放置粗體 SF Symbol，顏色為 Text Color (不需強調)。
- **Primary Button**:
  - 高度 `64px`，圓角 `24px` (全寬)。
  - 背景：Primary Color (Indigo)。
  - 文字：白色粗體。
  - **互動**：按下時整體縮放 (Scale Effect)。

### 3.2 儀表板 (DashboardView)

#### A. Header Area

- 放棄傳統 Navigation Bar。
- **左側**: "DASHBOARD" 大標題。
- **右側**:
  - **User Profile**: 圓形頭像 (`40x40`)。
  - **Depot Switcher**: 膠囊狀按鈕 (Capsule)，顯示當前倉庫名稱。

#### B. Bento Grid (即時資訊區)

採用 2-Column `LazyVGrid` 或 `HStack/VStack` 組合。

1.  **Hero Card (即時數據)**:
    - **尺寸**: 跨欄 (2x1) 或 大方塊 (2x2)。
    - **樣式**: **全填滿 Primary Color 背景** (Indigo)。
    - **內容**:
      - 左上: "CURRENT" 標籤 (白色, opacity 0.7)。
      - 中央: 超大溫度數值 (白色, Monospaced)。
      - 右下: 濕度圖標 + 數值 (白色)。
      - 背景: 右上角放置巨大的半透明圓形或三角形裝飾。
      - **Live Dot**: 右上角呼吸燈圓點 (綠色/黃色)，表示數據新鮮度。

2.  **Status Card (系統狀態)**:
    - **尺寸**: 1x1。
    - **樣式**: Standard Card Background。
    - **內容**:
      - 中央: 3D Render 風格圖標 (如 `checkmark.seal.fill` 或 `exclamationmark.triangle.fill`)。
      - 底部: "NORMAL" (綠色) 或 "ALERT" (紅色) 文字。

3.  **Context Card (環境/時間)**:
    - **尺寸**: 1x1。
    - **樣式**: 僅有粗邊框 (Stroke 4px)，無填充，背景透明。
    - **內容**: 顯示最後更新時間 (`HH:mm`) 或地點圖標。

#### C. Unified Climate Card (歷史趨勢)

置於 Bento Grid 下方。

- **外觀**: Standard Card Background，圓角 `24px`。
- **Header**: 設備名稱標籤 (Pill Shape)。
- **Chart (圖表)**:
  - **Style**: 線條加粗 (`lineWidth: 3`)，平滑曲線 (Catmull-Rom)。
  - **Grid**: **移除背景網格**，保持極簡。
  - **Gradient**: 曲線下方的漸層填充 (`.opacity(0.2) -> .clear`)。
- **List (列表)**:
  - 每一列採用 **Zebra Striping** (交替背景色)，增加閱讀速度。
  - 數值字體使用 Monospaced。

---

## 4. 實作指引 (Implementation Guide)

### 4.1 關鍵代碼範例

```swift
// Neo-Bento Card Modifier
struct BentoCardStyle: ViewModifier {
    var backgroundColor: Color = .white

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// Typography Helper
extension Font {
    static let neoHero = Font.system(size: 48, weight: .black, design: .monospaced)
    static let neoHeader = Font.system(size: 34, weight: .heavy, design: .rounded)
    static let neoLabel = Font.caption.weight(.bold)
}
```

### 4.2 數據綁定注意

- **LoginView**: 需綁定 `AuthViewModel` 狀態，處理 Loading 動畫與錯誤提示 (使用 Pop-up Toast 而非文字標籤)。
- **DashboardView**:
  - `Hero Card` 需訂閱 `SensorViewModel.currentReading`。
  - `Status Card` 需訂閱 `SensorViewModel.alertStatus`。

---

## 5. 變更紀錄

- **2025-12-23**: 文件重構為 Neo-Bento 風格，新增 LoginView 規格。
- **Stage 1**: (已封存)
