# iOS DashboardView 設計規格 (Stage 2)

## 規格說明

### Header (頂部導航)

- **左側**：顯示 App 名稱「Pu'er Sense」，使用 `font(.headline).tracking(2)`。
- **中間**：倉庫切換器 (Menu 樣式)，顯示當前位置 (如「Menghai Depot」)，點擊可切換。
- **右側**：用戶頭像按鈕，採用 `Circle()` 裁剪，背景帶有 `UltraThinMaterial` 效果。

### Main Area (主要內容)

- **Bento Grid (便當佈局)**：
  - **即時數據卡片**：顯示當前溫度與濕度。數據來源為 `DashboardViewModel.currentReading`：
    - 採用最近一筆數據，並顯示其更新時間 (`createdAt`)。
  - **異常警報卡片**：顯示當前警報狀態。若 `lastAlertAt` 在近期且警報活躍，顯示紅色高亮；否則顯示「系統正常」。數據來源為 `DashboardViewModel.isSubscribed` 與警報邏輯。
- **Swipe Cards (滑動分頁)**：
  - 使用 SwiftUI `TabView` 配合 `.tabViewStyle(.page(indexDisplayMode: .always))` 實現。
  - **卡片 1 (溫度)**：顯示溫度趨勢圖 (Swift Charts) 與歷史列表。
  - **卡片 2 (濕度)**：顯示濕度趨勢圖 (Swift Charts) 與歷史列表。
  - **卡片 3 (裝置)**：顯示裝置狀態列表 (Online/Offline)。

### Footer (底部功能)

- 膠囊狀按鈕 (Capsule)，固定於底部，引導至「Warehouse Management」。

### 視覺風格

- **Digital Wabi-Sabi**：背景色 `Color("Stone50")`，圓角 `.cornerRadius(32)`，細微陰影 `.shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)`。

---

## SwiftUI 實作範例

本範例展示如何與 `DashboardViewModel` 互動，並實作上述 UI 組件。

### DashboardView.swift

```swift
import SwiftUI
import Charts

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel.makeDefault()
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            Color("Stone50").ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                headerView

                ScrollView {
                    VStack(spacing: 24) {
                        // Bento Grid
                        bentoGridView

                        // Analytics Swipe Cards
                        analyticsSwipeView
                    }
                    .padding(.horizontal)
                }
            }

            // Floating Footer Button
            VStack {
                Spacer()
                manageButton
            }
            .padding(.bottom, 32)
        }
        .onAppear {
            viewModel.startListening()
            viewModel.fetchDefaultHistory()
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }

    private var headerView: some View {
        HStack {
            Text("Pu'er Sense")
                .font(.system(.caption, design: .serif))
                .fontWeight(.bold)
                .tracking(2)
                .foregroundColor(.secondary)

            Spacer()

            Menu {
                Button("Menghai Depot") { }
                Button("Kunming Store") { }
            } label: {
                HStack {
                    Text("Menghai Depot")
                    Image(systemName: "chevron.down")
                }
                .font(.subheadline.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.8))
                .clipShape(Capsule())
            }

            Spacer()

            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .background(Circle().fill(.ultraThinMaterial))
        }
        .padding(.horizontal)
    }

    private var bentoGridView: some View {
        HStack(spacing: 16) {
            // Live Metrics
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .lastTextBaseline) {
                    Text("\(String(format: "%.1f", viewModel.currentReading?.temperature ?? 0))°")
                        .font(.system(size: 32, weight: .bold))
                    Spacer()
                    if let date = viewModel.currentReading?.createdAt {
                        Text(date.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Text("Temp").font(.caption).foregroundColor(.secondary)

                Divider()

                VStack(alignment: .leading) {
                    Text("\(Int(viewModel.currentReading?.humidity ?? 0))%")
                        .font(.system(size: 32, weight: .bold))
                    Text("Humidity").font(.caption).foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 180)
            .background(Color.white)
            .cornerRadius(32)
            .shadow(color: .black.opacity(0.05), radius: 10)

            // Alert Status
            VStack(alignment: .leading) {
                HStack {
                    Text("Status").font(.caption.bold()).opacity(0.6)
                    Spacer()
                    Circle()
                        .fill(viewModel.lastAlertAt != nil ? Color.red : Color.green)
                        .frame(width: 8, height: 8)
                }

                Spacer()

                if viewModel.lastAlertAt != nil {
                    Label("Alert", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.headline)
                    Text("Condition threshold exceeded.")
                        .font(.caption)
                        .lineLimit(2)
                } else {
                    Label("Normal", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.headline)
                    Text("System is monitoring.")
                        .font(.caption)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 180)
            .background(Color("Stone800")) // 配合深色卡片風格
            .foregroundColor(.white)
            .cornerRadius(32)
        }
    }

    private var analyticsSwipeView: some View {
        VStack(alignment: .leading) {
            Text("Analytics")
                .font(.headline)
                .padding(.leading, 4)

            TabView(selection: $selectedTab) {
                HistoryChartCard(title: "Temperature History", data: viewModel.history, type: .temperature)
                    .tag(0)
                HistoryChartCard(title: "Humidity History", data: viewModel.history, type: .humidity)
                    .tag(1)
                DeviceStatusCard()
                    .tag(2)
            }
            .frame(height: 320)
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }

    private var manageButton: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "shippingbox.fill")
                Text("Manage Warehouse")
                    .fontWeight(.semibold)
            }
            .padding()
            .frame(maxWidth: 320)
            .background(Color.black)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .shadow(radius: 10)
        }
    }
}

// 子組件例：趨勢圖卡片
struct HistoryChartCard: View {
    let title: String
    let data: [Reading]
    let type: MeasurementType

    enum MeasurementType { case temperature, humidity }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.subheadline.bold())

            Chart(data) { reading in
                LineMark(
                    x: .value("Time", reading.createdAt),
                    y: .value("Value", type == .temperature ? reading.temperature : reading.humidity)
                )
                .foregroundStyle(type == .temperature ? Color.orange : Color.blue)
            }
            .frame(height: 200)
            .padding(.vertical)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(32)
        .padding(.horizontal, 4)
    }
}

struct DeviceStatusCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Devices").font(.subheadline.bold())
            List {
                HStack {
                    Image(systemName: "cpu")
                    Text("ESP32-Upper-01")
                    Spacer()
                    Text("Online").foregroundColor(.green).font(.caption)
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(32)
        .padding(.horizontal, 4)
    }
}
```

## 注意事項

1. **ViewModel 生命週期**：請確保在 `onAppear` 呼叫 `startListening()`，並在 `onDisappear` 呼叫 `stopListening()` 以節省資源。
2. **數據流**：所有即時更新均應透過 `@Observable` 的 `history` 與 `currentReading` 自動驅動視圖更新。
3. **門檻值**：警報邏輯已封裝於 `DashboardViewModel` 內，UI 僅需根據 `lastAlertAt` 顯示對應狀態。
