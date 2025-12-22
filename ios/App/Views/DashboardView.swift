/*
 * File: DashboardView.swift
 * Purpose: Main dashboard UI displaying real-time sensor data, charts, and device status.
 * Architecture: SwiftUI View using @Bindable for DashboardViewModel. Features Bento Grid layout.
 * AI Context: UI-only. All business/alert logic should stay in DashboardViewModel.
 */

#if canImport(SwiftUI)
  import SwiftUI
  import Charts
  import Observation

  /// Tailwind Stone 色票擴充，統一 UI 色彩
  extension Color {
    static let stone50 = Color(red: 250 / 255, green: 250 / 255, blue: 249 / 255)
    static let stone100 = Color(red: 245 / 255, green: 245 / 255, blue: 244 / 255)
    static let stone200 = Color(red: 231 / 255, green: 229 / 255, blue: 228 / 255)
    static let stone300 = Color(red: 214 / 255, green: 211 / 255, blue: 209 / 255)
    static let stone400 = Color(red: 168 / 255, green: 162 / 255, blue: 158 / 255)
    static let stone500 = Color(red: 120 / 255, green: 113 / 255, blue: 108 / 255)
    static let stone600 = Color(red: 87 / 255, green: 83 / 255, blue: 78 / 255)
    static let stone700 = Color(red: 68 / 255, green: 64 / 255, blue: 60 / 255)
    static let stone800 = Color(red: 41 / 255, green: 37 / 255, blue: 36 / 255)
    static let stone900 = Color(red: 28 / 255, green: 25 / 255, blue: 23 / 255)
  }

  /// 主儀表板畫面，顯示感測數據、圖表與設備狀態
  struct DashboardView: View {
    /// 感測資料 ViewModel，負責資料綁定
    @Bindable var viewModel: DashboardViewModel
    /// 當前選取的分頁索引（圖表/設備卡片切換用）
    @State private var activeTab = 0

    /// 所有感測裝置（由 ViewModel 提供）
    private var devices: [DashboardViewModel.DeviceInfo] {
      viewModel.devices
    }

    /// 主畫面內容，包含 Header、Bento Grid、滑動卡片區、Footer
    var body: some View {
      ZStack(alignment: .bottom) {
        // 背景色
        Color.stone50.ignoresSafeArea()

        VStack(spacing: 0) {
          // 1. 頁首區塊
          headerView
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.stone50.opacity(0.8))
            .background(.ultraThinMaterial)

          ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
              // 2. Bento Grid：即時數據與警示
              bentoGrid
                .padding(.horizontal, 24)

              // 3. 滑動卡片（圖表/設備）
              swipeableCardsSection

              // 浮動 Footer 預留空間 (防止遮擋)
              Color.clear.frame(height: 180)
            }
            .padding(.vertical)
          }
        }

        // 4. 頁尾：倉庫管理按鈕
        footerView
      }
      .onAppear {
        // 畫面出現時啟動資料監聽與預設歷史查詢
        viewModel.startListening()
        viewModel.fetchDefaultHistory()
      }
    }

    // MARK: - Subviews

    /// 頁首區塊：品牌、地點切換、使用者頭像
    private var headerView: some View {
      HStack {
        // 左：品牌名稱
        Text("PU'ER SENSE")
          .font(.caption)
          .fontWeight(.bold)
          .tracking(2)
          .foregroundColor(.stone400)

        Spacer()

        // 中：地點切換按鈕
        Button(action: {}) {
          HStack(spacing: 4) {
            Text("勐海倉庫")
              .font(.subheadline)
              .fontWeight(.bold)
              .foregroundColor(.stone700)
            Image(systemName: "chevron.down")
              .font(.caption)
              .foregroundColor(.stone400)
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .background(Color.stone100)
          .clipShape(Capsule())
        }

        Spacer()

        // 右：使用者頭像
        Button(action: {}) {
          Circle()
            .fill(Color.stone200)
            .frame(width: 40, height: 40)
            .overlay(
              Image(systemName: "person.fill")
                .foregroundColor(.stone400)
            )
            .overlay(
              Circle()
                .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
      }
      .padding(.horizontal, 24)
    }

    /// Bento Grid：即時溫濕度與警示卡片
    private var bentoGrid: some View {
      HStack(spacing: 16) {
        // 溫度/濕度數據卡
        VStack(alignment: .leading) {
          // Time Row
          if let date = viewModel.currentReading?.createdAt {
            HStack(spacing: 4) {
              Image(systemName: "clock")
              Text(date, format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute())
            }
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(.stone400)
          }

          Spacer()

          // Temp Row
          HStack(spacing: 12) {
            Image(systemName: "thermometer.medium")
              .font(.title2)
              .foregroundColor(.orange.opacity(0.8))
              .frame(width: 24)

            VStack(alignment: .leading, spacing: 0) {
              Text("\(Int(viewModel.currentReading?.temperature ?? 0))°")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.stone800)
              Text("溫度")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.stone400)
            }
          }

          Spacer()

          // Humidity Row
          HStack(spacing: 12) {
            Image(systemName: "drop.fill")
              .font(.title2)
              .foregroundColor(.blue.opacity(0.8))
              .frame(width: 24)

            VStack(alignment: .leading, spacing: 0) {
              Text("\(Int(viewModel.currentReading?.humidity ?? 0))%")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.stone800)
              Text("濕度")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.stone400)
            }
          }
        }
        .padding(20)
        .frame(height: 160)
        .background(Color.white)
        .cornerRadius(32)
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 4)

        // 警示卡片 (Dynamic Alert Card - Option B: Dynamic Surface)
        VStack(alignment: .leading) {
          HStack {
            Text("狀態")
              .font(.system(size: 11, weight: .bold))  // Slightly larger label
              .opacity(0.6)
            Spacer()
            Circle()
              .fill(viewModel.alertType.isCritical ? Color.red : Color.green)
              .frame(width: 8, height: 8)
              .shadow(
                color: viewModel.alertType.isCritical
                  ? Color.red.opacity(0.5) : Color.green.opacity(0.5), radius: 4)
          }

          Spacer()

          VStack(alignment: .leading, spacing: 8) {  // Group Title and Desc for better density
            HStack(spacing: 8) {
              Image(
                systemName: viewModel.alertType.isCritical
                  ? "exclamationmark.triangle.fill" : "checkmark.circle.fill"
              )
              .font(.title2)  // Larger icon
              Text(viewModel.alertType.title)
                .font(.title2)  // Larger title (was default body)
                .fontWeight(.bold)
                .fontDesign(.rounded)
            }
            // 主標題顏色：Alert 時顯著紅色，Normal 時綠色
            .foregroundColor(viewModel.alertType.isCritical ? .red : .green.opacity(0.8))

            Text(viewModel.alertType.description)
              .font(.subheadline)  // Larger description (was caption)
              .fontWeight(.medium)
              .lineLimit(3)  // Allow more lines if needed
              .fixedSize(horizontal: false, vertical: true)
              // 描述文字顏色：Alert 時跟隨主色調，Normal 時使用標準深灰
              .foregroundColor(viewModel.alertType.isCritical ? .red.opacity(0.8) : .stone500)
          }
        }
        .padding(20)
        .frame(height: 160)
        // 背景色：Alert 時使用淡紅背景 (Dynamic Surface)，Normal 時純白
        .background(viewModel.alertType.isCritical ? Color.red.opacity(0.08) : Color.white)
        // 邊框：Alert 時增加紅色邊框強化警示與可訪問性
        .overlay(
          RoundedRectangle(cornerRadius: 32)
            .stroke(viewModel.alertType.isCritical ? Color.red : Color.clear, lineWidth: 1)
        )
        .cornerRadius(32)
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 4)
        .animation(.spring, value: viewModel.alertType.isCritical)
      }
    }

    /// 滑動卡片區：歷史圖表與設備清單
    /// 按 deviceId 分組的數據
    private var groupedHistory: [String: [Reading]] {
      Dictionary(grouping: viewModel.history, by: { $0.deviceId })
    }

    /// 排序後的裝置 ID 列表
    private var activeDeviceIds: [String] {
      Array(groupedHistory.keys).sorted()
    }

    /// 總分頁數 (僅包含裝置數量)
    private var totalTabs: Int {
      activeDeviceIds.count
    }

    private var swipeableCardsSection: some View {
      VStack(spacing: 0) {
        // 區塊標題與分頁指示點
        HStack {
          Text("歷史紀錄")
            .font(.headline)
            .foregroundColor(.stone700)
          Spacer()
          HStack(spacing: 6) {
            ForEach(0..<totalTabs, id: \.self) { index in
              Circle()
                .fill(activeTab == index ? Color.stone800 : Color.stone300)
                .frame(width: 6, height: 6)
            }
          }
        }
        .padding(.horizontal, 24)

        // 橫向滑動卡片（TabView）
        TabView(selection: $activeTab) {
          // 為每個裝置顯示一張整合卡片
          let deviceIds = activeDeviceIds
          ForEach(Array(deviceIds.enumerated()), id: \.offset) { index, deviceId in
            // 查找該裝置的狀態資訊
            let deviceInfo = devices.first(where: { $0.id == deviceId })

            UnifiedClimateCard(
              deviceId: deviceId,
              location: deviceInfo?.location ?? "未知地點",
              status: deviceInfo?.status ?? .offline,
              battery: deviceInfo?.battery ?? 0,
              readings: groupedHistory[deviceId] ?? []
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .tag(index)
            .padding(.horizontal, 24)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 520)
      }
    }

    /// 頁尾管理按鈕
    private var footerView: some View {
      Button(action: {}) {
        HStack(spacing: 12) {
          Image(systemName: "building.2.fill")
            .foregroundColor(.stone300)
          Text("管理倉庫")
            .fontWeight(.semibold)
        }
        .foregroundColor(.stone50)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.stone900.opacity(0.9))
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
      }
      .padding(.bottom, 16)
    }
  }

  // MARK: - Helper Components

  /// 統一的圖表容器，提供背景、邊框與標準化標題
  /// 對應 React: ChartContainer
  struct ChartContainer<Content: View>: View {
    let config: ChartConfig
    let content: () -> Content

    init(config: ChartConfig, @ViewBuilder content: @escaping () -> Content) {
      self.config = config
      self.content = content
    }

    var body: some View {
      VStack(alignment: .leading, spacing: 16) {
        // Header
        if let title = config.title {
          HStack(spacing: 8) {
            if let iconData = config.icon {
              Image(systemName: iconData.0)
                .foregroundColor(config.colors[iconData.1] ?? .stone800)
            }
            Text(title)
              .font(.headline)
              .fontWeight(.bold)
              .foregroundColor(.stone800)

            Spacer()

            if let trailing = config.trailingView {
              trailing
            }
          }
          .layoutPriority(1)  // Prevent header compression
        }

        if let subtitle = config.subtitle {
          Text(subtitle)
            .font(.subheadline)
            .foregroundColor(.stone400)
            .padding(.top, -12)  // Slightly closer to title
        }

        // Content
        content()
      }
      .padding(20)
      .background(Color.white)
      .cornerRadius(32)  // Rounded-xl equivalent
      .overlay(
        RoundedRectangle(cornerRadius: 32)
          .stroke(Color.stone200, lineWidth: 1)
      )
      .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 4)
    }
  }

  struct ChartConfig {
    var title: String?
    var subtitle: String?
    var icon: (String, String)?  // (SystemName, ColorKey)
    var colors: [String: Color]
    var trailingView: AnyView?
  }

  /// 整合環境數據卡片，顯示單一裝置的溫濕度歷史與狀態
  struct UnifiedClimateCard: View {
    let deviceId: String
    let location: String
    let status: DashboardViewModel.DeviceInfo.Status
    let battery: Int
    let readings: [Reading]

    @State private var showList = false
    @State private var selectedDate: Date? = nil
    @State private var selectedReading: Reading? = nil

    // Colors map (Theming)
    private let colors: [String: Color] = [
      "temp": .orange,
      "humid": .blue,
    ]

    var body: some View {
      let lastReading = readings.max(by: { $0.createdAt < $1.createdAt })

      let headerConfig = ChartConfig(
        title: deviceId,
        subtitle: location,
        icon: ("cpu", "temp"),  // Placeholder icon
        colors: colors,
        trailingView: AnyView(
          HStack {
            // Status Indicators
            HStack(spacing: 4) {
              Circle()
                .fill(status == .online ? Color.green : Color.stone300)
                .frame(width: 8, height: 8)

              if status == .online {
                Image(systemName: battery < 20 ? "battery.25" : "battery.100")
                  .foregroundColor(battery < 20 ? .red : .stone400)
                  .font(.caption2)
                Text("\(battery)%")
                  .font(.caption2)
                  .foregroundColor(.stone400)
              } else {
                Image(systemName: "wifi.slash")
                  .foregroundColor(.stone400)
                  .font(.caption2)
              }
            }
            .padding(.trailing, 8)

            Button(action: { withAnimation { showList.toggle() } }) {
              Image(systemName: showList ? "chart.xyaxis.line" : "list.bullet")
                .font(.system(size: 14))
                .padding(8)
                .foregroundColor(.stone500)
                .background(Color.stone100)
                .clipShape(Circle())
            }
          }
        )
      )

      ChartContainer(config: headerConfig) {
        VStack(alignment: .leading, spacing: 10) {

          if showList {
            // List View
            listView(readings: readings)
              .frame(height: 350)
          } else {
            // Chart View
            chartView(readings: readings)
              .frame(height: 200)  // Keep chart height reasonable

            Divider()
              .padding(.vertical, 2)

            // Big Metrics (Current / Selected)
            HStack(spacing: 24) {
              let displayReading = selectedReading ?? lastReading

              // Temperature
              VStack(alignment: .leading, spacing: 2) {
                Text("溫度")
                  .font(.caption)
                  .fontWeight(.medium)
                  .foregroundColor(.stone400)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                  Text(String(format: "%.1f", displayReading?.temperature ?? 0))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.stone800)
                  Text("°C")
                    .font(.callout)
                    .foregroundColor(.stone400)
                }
              }
              .padding(.leading, 8)
              .overlay(alignment: .leading) {
                Rectangle().fill(colors["temp"]!).frame(width: 4).cornerRadius(2).padding(
                  .leading, -8)
              }

              // Humidity
              VStack(alignment: .leading, spacing: 2) {
                Text("濕度")
                  .font(.caption)
                  .fontWeight(.medium)
                  .foregroundColor(.stone400)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                  Text(String(format: "%.0f", displayReading?.humidity ?? 0))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.stone800)
                  Text("%")
                    .font(.callout)
                    .foregroundColor(.stone400)
                }
              }
              .padding(.leading, 8)
              .overlay(alignment: .leading) {
                Rectangle().fill(colors["humid"]!).frame(width: 4).cornerRadius(2).padding(
                  .leading, -8)
              }

              Spacer()

              // Time
              if let date = displayReading?.createdAt {
                VStack(alignment: .trailing) {
                  Text(date, format: .dateTime.hour().minute())
                    // .font(.title3)
                    .font(.system(size: 20, weight: .bold))  // Prevent font jumping
                    .fontWeight(.bold)
                    .foregroundColor(.stone600)
                  Text(date, format: .dateTime.month().day())
                    .font(.caption)
                    .foregroundColor(.stone400)
                }
              }
            }
            .padding(.bottom, 8)
          }
        }
      }
    }

    @ViewBuilder
    private func listView(readings: [Reading]) -> some View {
      let sortedData = readings.sorted { $0.createdAt > $1.createdAt }
      List(Array(sortedData.enumerated()), id: \.element.id) { index, item in
        HStack {
          Text(item.createdAt, format: .dateTime.hour().minute())
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(.stone500)

          Spacer()

          HStack(spacing: 16) {
            HStack(spacing: 4) {
              Image(systemName: "thermometer.medium")
                .foregroundColor(colors["temp"])
              Text(String(format: "%.1f°", item.temperature))
                .fixedSize()
                .lineLimit(1)
            }
            .frame(width: 85, alignment: .leading)

            HStack(spacing: 4) {
              Image(systemName: "drop.fill")
                .foregroundColor(colors["humid"])
              Text(String(format: "%.0f%%", item.humidity))
                .fixedSize()
                .lineLimit(1)
            }
            .frame(width: 75, alignment: .leading)
          }
          .font(.system(.callout, design: .monospaced))
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
      }
      .listStyle(.plain)
    }

    @ViewBuilder
    private func chartView(readings: [Reading]) -> some View {
      let chartData = readings.sorted { $0.createdAt < $1.createdAt }

      Chart {
        ForEach(chartData) { item in
          // Ambient Temperature Area (Gradient)
          AreaMark(
            x: .value("Time", item.createdAt),
            y: .value("Temp", item.temperature)
          )
          .interpolationMethod(.catmullRom)
          .foregroundStyle(
            LinearGradient(
              colors: [colors["temp"]!.opacity(0.1), colors["temp"]!.opacity(0.01)],
              startPoint: .top,
              endPoint: .bottom
            )
          )

          // Temperature Line
          LineMark(
            x: .value("Time", item.createdAt),
            y: .value("Temp", item.temperature),
            series: .value("Metric", "Temperature")
          )
          .interpolationMethod(.catmullRom)
          .foregroundStyle(colors["temp"]!)
          // .symbol(Circle()) // Clean look
          // .symbolSize(0)

          // Humidity Line (Dashed)
          LineMark(
            x: .value("Time", item.createdAt),
            y: .value("Humidity", item.humidity),
            series: .value("Metric", "Humidity")
          )
          .interpolationMethod(.catmullRom)
          .foregroundStyle(colors["humid"]!)
          .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))

          // Selection Rule
          if let selectedDate,
            let currentItem = selectedReading,
            currentItem.id == item.id
          {  // Simple check, or find closest

            RuleMark(x: .value("Selected", selectedDate))
              .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
              .foregroundStyle(Color.stone400.opacity(0.5))

            PointMark(
              x: .value("Time", item.createdAt),
              y: .value("Temp", item.temperature)
            )
            .foregroundStyle(colors["temp"]!)
            .symbolSize(60)
            .annotation(position: .top) {
              // Inline annotation if needed, or rely on the big metrics update
            }

            PointMark(
              x: .value("Time", item.createdAt),
              y: .value("Humidity", item.humidity)
            )
            .foregroundStyle(colors["humid"]!)
            .symbolSize(60)
          }
        }
      }
      .chartYScale(domain: .automatic(includesZero: false))
      .chartXAxis {
        AxisMarks(values: .automatic(desiredCount: 5)) { value in
          if value.as(Date.self) != nil {
            AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)).minute())
              .foregroundStyle(Color.stone400)
          }
        }
      }
      .chartYAxis {
        AxisMarks(position: .leading)
      }
      .chartOverlay { proxy in
        GeometryReader { geometry in
          Rectangle().fill(.clear).contentShape(Rectangle())
            .gesture(
              DragGesture(minimumDistance: 0)
                .onChanged { value in
                  let x = value.location.x
                  if let date: Date = proxy.value(atX: x) {
                    selectedDate = date
                    // Find closest reading
                    if let reading = readings.min(by: {
                      abs($0.createdAt.timeIntervalSince(date))
                        < abs($1.createdAt.timeIntervalSince(date))
                    }) {
                      selectedReading = reading
                    }
                  }
                }
                .onEnded { _ in
                  selectedDate = nil
                  selectedReading = nil
                }
            )
        }
      }
    }
  }

  #Preview {
    DashboardView(viewModel: .preview)
  }

  // MARK: - Preview Helpers
  extension DashboardViewModel {
    fileprivate static var preview: DashboardViewModel {
      let manager = MockSupabaseManager()
      let viewModel = DashboardViewModel(manager: manager)

      let now = Date()
      // Generate history with simple time intervals to avoid force-unwrap issues
      let history = [
        // Device 1: ESP-01
        Reading(
          id: 1, createdAt: now.addingTimeInterval(-6 * 3600), deviceId: "ESP-01",
          temperature: 22.5, humidity: 60.1),
        Reading(
          id: 2, createdAt: now.addingTimeInterval(-4 * 3600), deviceId: "ESP-01",
          temperature: 24.8, humidity: 65.0),
        Reading(
          id: 3, createdAt: now.addingTimeInterval(-2 * 3600), deviceId: "ESP-01",
          temperature: 25.1, humidity: 68.4),
        Reading(id: 4, createdAt: now, deviceId: "ESP-01", temperature: 24.2, humidity: 63.3),

        // Device 2: ESP-02
        Reading(
          id: 10, createdAt: now.addingTimeInterval(-5 * 3600), deviceId: "ESP-02",
          temperature: 18.2, humidity: 45.5),
        Reading(
          id: 11, createdAt: now.addingTimeInterval(-3 * 3600), deviceId: "ESP-02",
          temperature: 19.5, humidity: 48.2),
        Reading(
          id: 12, createdAt: now.addingTimeInterval(-1 * 3600), deviceId: "ESP-02",
          temperature: 20.8, humidity: 44.1),
      ]

      // Inject data
      viewModel.history = history
      manager.mockHistory = history

      // Add mock devices for status testing
      viewModel.devices = [
        DashboardViewModel.DeviceInfo(
          id: "ESP-01", location: "倉庫 A", status: .online, battery: 85),
        DashboardViewModel.DeviceInfo(
          id: "ESP-02", location: "入口 B", status: .offline, battery: 0),
      ]

      // Sync currentReading with the latest history item
      if let latest = history.last {
        viewModel.currentReading = latest
        viewModel.checkAlert(for: latest)
      }

      viewModel.isSubscribed = true
      return viewModel
    }
  }

  /// 假 Supabase 管理器，專供 Preview 或測試用，不實際連線
  private final class MockSupabaseManager: SupabaseManaging {
    var sessionToken: String? = nil
    var mockHistory: [Reading] = []

    func signIn(email: String, password: String) async throws {}
    func signUp(email: String, password: String) async throws {}

    func fetchHistory(limit: Int) async throws -> [Reading] {
      // Return local mock history to simulate API response
      return mockHistory
    }

    func signOut() {}

    func signIn(
      email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void
    ) {}
    func signUp(
      email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void
    ) {}

    func fetchHistory(limit: Int, completion: @escaping (Result<[Reading], Error>) -> Void) {
      completion(.success(mockHistory))
    }

    func subscribeToReadings(onInsert: @escaping (Reading) -> Void) {}
    func unsubscribeFromReadings() {}
  }

  // Expose checkAlert for preview only to force state update
  extension DashboardViewModel {
    func forceCheckAlert() {
      if let reading = currentReading {
        checkAlert(for: reading)
      }
    }
  }
#endif
