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

              // 浮動 Footer 預留空間
              Color.clear.frame(height: 100)
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
            Text("Menghai Depot")
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
              Text("AVG TEMP")
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
              Text("HUMIDITY")
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
            Text("STATUS")
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
      VStack(spacing: 12) {
        // 區塊標題與分頁指示點
        HStack {
          Text("Analytics")
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
              location: deviceInfo?.location ?? "Unknown Location",
              status: deviceInfo?.status ?? .offline,
              battery: deviceInfo?.battery ?? 0,
              readings: groupedHistory[deviceId] ?? []
            )
            .tag(index)
            .padding(.horizontal, 24)
          }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 320)
      }
    }

    /// 頁尾管理按鈕
    private var footerView: some View {
      Button(action: {}) {
        HStack(spacing: 12) {
          Image(systemName: "building.2.fill")
            .foregroundColor(.stone300)
          Text("Manage Warehouse")
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
      .padding(.bottom, 32)
    }
  }

  // MARK: - Helper Components

  /// 整合環境數據卡片，顯示單一裝置的溫濕度歷史與狀態
  struct UnifiedClimateCard: View {
    /// 裝置 ID (作為標題)
    let deviceId: String
    /// 安裝位置 (作為副標題)
    let location: String
    /// 該裝置的狀態資訊 (從外部傳入)
    let status: DashboardViewModel.DeviceInfo.Status
    /// 該裝置的電量 (從外部傳入)
    let battery: Int
    /// 該裝置的資料來源
    let readings: [Reading]

    /// 是否顯示清單模式
    @State private var showList = false

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        // Header
        HStack(alignment: .top) {
          HStack(spacing: 12) {
            ZStack {
              Image(systemName: "drop.fill")
                .offset(x: 4, y: 4)
                .foregroundColor(.blue.opacity(0.8))
              Image(systemName: "thermometer.medium")
                .offset(x: -4, y: -4)
                .foregroundColor(.orange.opacity(0.8))
            }
            .font(.system(size: 14))
            .padding(10)
            .background(Color.stone100)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
              HStack(spacing: 6) {
                Text(deviceId)
                  .font(.headline)
                  .foregroundColor(.stone800)

                // Status Dot
                Circle()
                  .fill(status == .online ? Color.green : Color.stone300)
                  .frame(width: 6, height: 6)
                  .shadow(color: status == .online ? Color.green.opacity(0.4) : .clear, radius: 2)

                // Battery or WiFi Status
                if status == .online {
                  HStack(spacing: 2) {
                    Text("\(battery)%")
                      .font(.system(size: 10, design: .monospaced))
                      .foregroundColor(.stone400)
                    Image(systemName: "battery.75")
                      .font(.system(size: 10))
                      .foregroundColor(battery < 20 ? .red : .stone400)
                  }
                } else {
                  Image(systemName: "wifi.slash")
                    .font(.system(size: 10))
                    .foregroundColor(.stone400)
                }
              }

              Text(location)
                .font(.caption)
                .fontWeight(.medium)
                .textCase(.uppercase)
                .foregroundColor(.stone400)
            }
          }
          Spacer()

          Button(action: { withAnimation { showList.toggle() } }) {
            Image(systemName: showList ? "chart.xyaxis.line" : "list.bullet")
              .padding(8)
              .foregroundColor(.stone400)
              .background(Color.stone100)
              .clipShape(Circle())
          }
        }
        .padding(24)

        // Content
        deviceContentView(readings: readings)
      }
      .background(Color.white)
      .cornerRadius(32)
      .shadow(color: Color.stone100, radius: 1, x: 0, y: 0)
      .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
    }

    /// 單一裝置的數據內容視圖
    @ViewBuilder
    private func deviceContentView(readings: [Reading]) -> some View {
      if showList {
        // List Mode
        let sortedData = readings.sorted { $0.createdAt > $1.createdAt }
        List(Array(sortedData.enumerated()), id: \.offset) { _, item in
          HStack(spacing: 0) {
            Text(item.createdAt, format: .dateTime.hour(.twoDigits(amPM: .omitted)).minute())
              .font(.caption)
              .foregroundColor(.stone400)
              .padding(.horizontal, 6)
              .padding(.vertical, 2)
              .background(Color.stone100)
              .cornerRadius(4)

            Spacer()

            Text("\(item.temperature, specifier: "%.1f")°")
              .font(.system(.body, design: .monospaced))
              .fontWeight(.bold)
              .foregroundColor(.stone700)
              .frame(width: 60, alignment: .trailing)

            Text("/")
              .font(.caption)
              .foregroundColor(.stone300)
              .padding(.horizontal, 6)

            Text("\(item.humidity, specifier: "%.1f")%")
              .font(.system(.body, design: .monospaced))
              .fontWeight(.bold)
              .foregroundColor(.stone700)
              .frame(width: 60, alignment: .trailing)
          }
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
        }
        .listStyle(.plain)
      } else {
        // Chart Mode
        let chartData = readings.sorted { $0.createdAt < $1.createdAt }
        Chart {
          ForEach(Array(chartData.enumerated()), id: \.offset) { index, item in
            LineMark(
              x: .value("Index", index),
              y: .value("Temperature", item.temperature),
              series: .value("Metric", "Temp")
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(.orange)

            AreaMark(
              x: .value("Index", index),
              y: .value("Temperature", item.temperature)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
              LinearGradient(
                colors: [.orange.opacity(0.1), .orange.opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
              )
            )

            LineMark(
              x: .value("Index", index),
              y: .value("Humidity", item.humidity),
              series: .value("Metric", "Humid")
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(.blue)
            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 3]))
          }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
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
          id: "ESP-01", location: "Warehouse A", status: .online, battery: 85),
        DashboardViewModel.DeviceInfo(
          id: "ESP-02", location: "Entrance B", status: .offline, battery: 0),
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
