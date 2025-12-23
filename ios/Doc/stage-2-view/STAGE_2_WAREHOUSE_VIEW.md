# iOS 設計規格書 (Stage 2) - WarehouseView 茶倉管理

> **關聯代碼**: @[WarehouseView.swift](file:///Users/joseph-m2/Dev/1141-iOS-adv/1141-ios-proj/ios/App/Views/WarehouseView.swift)

## 1. 設計理念 (Design Philosophy)

延續 Neo-Bento 設計語言，建立普洱茶倉庫管理介面。

- **核心概念**：**Inventory (庫存視覺化)**、**Expandable (可展開細節)**、**Educational (教育性內容)**。
- **視覺目標**：以卡片式清單呈現茶品庫存，點擊展開詳細介紹，兼具實用與品茶知識分享。

---

## 2. 數據模型 (Data Model)

### 2.1 PuerhTea 結構

```swift
struct PuerhTea: Identifiable {
    let id: UUID
    let name: String           // 茶品名稱 (e.g., "大益 7542")
    let recipeCode: String     // 配方編號 (e.g., "7542")
    let factory: String        // 茶廠 (e.g., "勐海茶廠")
    let year: Int              // 配方年份
    let teaGrade: String       // 茶青等級 (e.g., "4級茶青")
    let description: String    // 詳細介紹
    var quantity: TeaQuantity
}
```

### 2.2 TeaQuantity 數量結構

支援普洱茶傳統計量單位：

| 單位   | 說明        | 換算             |
| :----- | :---------- | :--------------- |
| **餅** | 單餅        | 1 餅             |
| **筒** | 竹筒裝      | 7 餅/筒          |
| **件** | 整件 (紙箱) | 12 筒/件 = 84 餅 |

```swift
struct TeaQuantity {
    var bing: Int    // 餅
    var tong: Int    // 筒
    var jian: Int    // 件
}
```

---

## 3. 預置範例茶品 (Sample Data)

資料來源：網路搜尋整理

### 3.1 大益 7542

| 屬性         | 內容                                               |
| :----------- | :------------------------------------------------- |
| **配方年份** | 1975                                               |
| **茶廠**     | 勐海茶廠 (代號 2)                                  |
| **茶青等級** | 4 級                                               |
| **特點**     | 標竿生茶，花果蜜香高揚，回甘生津強烈，陳化潛力極佳 |

### 3.2 大益 8582

| 屬性         | 內容                                                   |
| :----------- | :----------------------------------------------------- |
| **配方年份** | 1985                                                   |
| **茶廠**     | 勐海茶廠 (代號 2)                                      |
| **茶青等級** | 8 級                                                   |
| **特點**     | 粗壯茶青，陳化快速，滋味醇厚，茶氣濃郁，適合口味偏重者 |

### 3.3 下關 8653

| 屬性         | 內容                                                   |
| :----------- | :----------------------------------------------------- |
| **配方年份** | 1986                                                   |
| **茶廠**     | 下關茶廠 (代號 3)                                      |
| **茶青等級** | 5 級                                                   |
| **特點**     | 鐵餅壓制，濃郁陳香混合果香花香，茶湯富膠質感，回甘持久 |

---

## 4. 組件規格 (Component Specifications)

### 4.1 WarehouseView 主視圖

- **呈現方式**：從 DashboardView 的 "Manage Warehouse" 按鈕以 `.sheet` 彈出
- **導航結構**：`NavigationStack`
- **標題**：`茶倉管理` (Large Title)
- **關閉按鈕**：左上角 `xmark.circle.fill`

### 4.2 Summary Card (庫存總覽卡片)

| 屬性     | 規格                                    |
| :------- | :-------------------------------------- |
| **位置** | 頁面頂部                                |
| **背景** | `DesignSystem.Colors.cardStandard`      |
| **左側** | 庫存總數 (餅)，大號數字 + Primary Color |
| **右側** | 茶品款數 + 提示文字                     |

### 4.3 TeaInventoryCard (茶品庫存卡片)

#### A. Header 區域 (收合狀態)

- **茶品圖標**：圓形 Primary Gradient 背景 + "茶" 字
- **茶品資訊**：名稱 (Card Title) + 茶廠/年份 (Caption)
- **數量顯示**：餅/筒/件 複合顯示 + 展開箭頭

#### B. Detail 區域 (展開狀態)

- **茶青等級徽章**：Primary 背景膠囊
- **配方編號徽章**：Primary 淡色背景膠囊
- **介紹文字**：多行說明，包含外觀、香氣、口感、沖泡建議

```
點擊卡片 → withAnimation(.spring) 切換 expandedTeaId
```

---

## 5. 視覺規範 (Visual Style)

沿用 DashboardView 設計系統：

| 元素     | 規格                                              |
| :------- | :------------------------------------------------ |
| **圓角** | `DesignSystem.Layout.cornerRadius` (24px)         |
| **間距** | `16px` 卡片間距                                   |
| **陰影** | `shadow(color: .black.opacity(0.05), radius: 10)` |
| **動畫** | `.spring(response: 0.35, dampingFraction: 0.8)`   |

---

## 6. 導航整合

### DashboardView 連結

```swift
// DashboardView.swift
@State private var showWarehouseSheet = false

// Footer Button
Button(action: { showWarehouseSheet = true }) { ... }

// Sheet Presentation
.sheet(isPresented: $showWarehouseSheet) {
    WarehouseView()
}
```

---

## 7. 變更紀錄

- **2025-12-23**: 初版建立，包含 3 款範例茶品 (大益 7542, 大益 8582, 下關 8653)
