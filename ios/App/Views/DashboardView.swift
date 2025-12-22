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

    /// 假資料：設備清單（尚未串接 VM 時使用）
    let devices = [
      DeviceInfo(id: "ESP-01", location: "Section A", status: .online, battery: 85),
      DeviceInfo(id: "ESP-02", location: "Section B", status: .online, battery: 72),
      DeviceInfo(id: "ESP-03", location: "Ceiling", status: .offline, battery: 0),
      DeviceInfo(id: "ESP-04", location: "Floor", status: .online, battery: 45),
    ]

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
          HStack(alignment: .top) {
            VStack(alignment: .leading) {
              Text("\(Int(viewModel.currentReading?.temperature ?? 0))°")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.stone800)
              Text("AVG TEMP")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.stone400)
            }
            Spacer()
            Image(systemName: "thermometer.medium")
              .foregroundColor(.orange.opacity(0.8))
          }
          Spacer()
          HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
              Text("\(Int(viewModel.currentReading?.humidity ?? 0))%")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.stone800)
              Text("HUMIDITY")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.stone400)
            }
            Spacer()
            Image(systemName: "drop.fill")
              .foregroundColor(.blue.opacity(0.8))
          }
        }
        .padding(20)
        .frame(height: 160)
        .background(Color.white)
        .cornerRadius(32)
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 4)

        // 警示卡片
        VStack(alignment: .leading) {
          HStack {
            Text("STATUS")
              .font(.system(size: 10, weight: .bold))
              .opacity(0.6)
            Spacer()
            Circle()
              .fill(Color.red)
              .frame(width: 8, height: 8)
          }
          Spacer()
          HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text("Alert")
              .fontWeight(.bold)
          }
          .foregroundColor(.red.opacity(0.8))
          .padding(.bottom, 4)

          Text("Filter replacement required in Zone B.")
            .font(.caption)
        }
        .padding(20)
        .frame(height: 160)
        .background(Color.stone800)
        .foregroundColor(.stone100)
        .cornerRadius(32)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 4)
      }
    }

    /// 滑動卡片區：歷史圖表與設備清單
    private var swipeableCardsSection: some View {
      VStack(spacing: 12) {
        // 區塊標題與分頁指示點
        HStack {
          Text("Analytics")
            .font(.headline)
            .foregroundColor(.stone700)
          Spacer()
          HStack(spacing: 6) {
            ForEach(0..<3) { index in
              Circle()
                .fill(activeTab == index ? Color.stone800 : Color.stone300)
                .frame(width: 6, height: 6)
            }
          }
        }
        .padding(.horizontal, 24)

        // 橫向滑動卡片（TabView）
        TabView(selection: $activeTab) {
          ChartCard(
            title: "Temperature History",
            subtitle: "Last 7 Days",
            iconName: "thermometer.medium",
            color: .orange,
            data: viewModel.history.map { $0.temperature },
            unit: "°C"
          )
          .tag(0)
          .padding(.horizontal, 24)

          ChartCard(
            title: "Humidity History",
            subtitle: "Last 7 Days",
            iconName: "drop.fill",
            color: .blue,
            data: viewModel.history.map { $0.humidity },
            unit: "%"
          )
          .tag(1)
          .padding(.horizontal, 24)

          DeviceListCard(devices: devices)
            .tag(2)
            .padding(.horizontal, 24)
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

  /// 單一圖表卡片元件，顯示溫度或濕度歷史資料
  struct ChartCard: View {
    /// 卡片標題
    let title: String
    /// 副標題
    let subtitle: String
    /// SF Symbol 圖示名稱
    let iconName: String
    /// 主色
    let color: Color
    /// 資料來源（數值陣列）
    let data: [Float]
    /// 單位字串
    let unit: String

    /// 是否顯示清單模式
    @State private var showList = false

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        // Header
        HStack(alignment: .top) {
          HStack(spacing: 12) {
            Image(systemName: iconName)
              .padding(10)
              .background(color.opacity(0.1))
              .foregroundColor(color)
              .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading) {
              Text(title)
                .font(.headline)
                .foregroundColor(.stone800)
              Text(subtitle)
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
        if showList {
          List(Array(data.enumerated()), id: \.offset) { index, value in
            HStack {
              Text("Reading \(index + 1)")
                .font(.subheadline)
                .foregroundColor(.stone500)
              Spacer()
              Text("\(value, specifier: "%.1f")\(unit)")
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.stone700)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
          }
          .listStyle(.plain)
        } else {
          Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
              LineMark(
                x: .value("Index", index),
                y: .value("Value", value)
              )
              .interpolationMethod(.catmullRom)
              .foregroundStyle(color)
              .symbol {
                Circle()
                  .fill(color)
                  .frame(width: 8, height: 8)
                  .overlay(Circle().stroke(Color.white, lineWidth: 2))
              }

              AreaMark(
                x: .value("Index", index),
                y: .value("Value", value)
              )
              .interpolationMethod(.catmullRom)
              .foregroundStyle(
                LinearGradient(
                  colors: [color.opacity(0.2), color.opacity(0.0)],
                  startPoint: .top,
                  endPoint: .bottom
                )
              )
            }
          }
          .chartXAxis(.hidden)
          .chartYAxis(.hidden)
          .padding(.horizontal, 24)
          .padding(.bottom, 24)
        }
      }
      .background(Color.white)
      .cornerRadius(32)
      .shadow(color: Color.stone100, radius: 1, x: 0, y: 0)  // Border-like shadow
      .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
    }
  }

  /// 設備清單卡片，顯示所有感測裝置狀態
  struct DeviceListCard: View {
    /// 設備資料陣列
    let devices: [DeviceInfo]

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        // Header
        HStack(spacing: 12) {
          Image(systemName: "wifi")
            .padding(10)
            .background(Color.stone100)
            .foregroundColor(.stone600)
            .clipShape(RoundedRectangle(cornerRadius: 12))

          VStack(alignment: .leading) {
            Text("Connected Sensors")
              .font(.headline)
              .foregroundColor(.stone800)
            Text("ESP32 NETWORK")
              .font(.caption)
              .fontWeight(.medium)
              .textCase(.uppercase)
              .foregroundColor(.stone400)
          }
        }
        .padding(24)

        // List
        ScrollView {
          VStack(spacing: 12) {
            ForEach(devices) { device in
              HStack {
                HStack(spacing: 12) {
                  Circle()
                    .fill(device.status == .online ? Color.green : Color.stone300)
                    .frame(width: 8, height: 8)
                    .shadow(
                      color: device.status == .online ? Color.green.opacity(0.6) : .clear, radius: 4
                    )

                  VStack(alignment: .leading) {
                    Text(device.location)
                      .font(.subheadline)
                      .fontWeight(.bold)
                      .foregroundColor(.stone700)
                    Text(device.id)
                      .font(.caption2)
                      .fontWeight(.medium)
                      .textCase(.uppercase)
                      .foregroundColor(.stone400)
                  }
                }
                Spacer()
                if device.status == .online {
                  HStack(spacing: 4) {
                    Text("\(device.battery)%")
                      .font(.caption)
                      .fontDesign(.monospaced)
                    Image(systemName: "battery.75")
                  }
                  .foregroundColor(device.battery < 20 ? .red : .stone400)
                } else {
                  Image(systemName: "wifi.slash")
                    .font(.caption)
                    .foregroundColor(.stone400)
                }
              }
              .padding(12)
              .background(Color.stone50)
              .cornerRadius(16)
            }
          }
          .padding(.horizontal, 24)
          .padding(.bottom, 24)
        }
      }
      .background(Color.white)
      .cornerRadius(32)
      .shadow(color: Color.stone100, radius: 1, x: 0, y: 0)
      .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
    }
  }

  /// 感測裝置資訊結構
  struct DeviceInfo: Identifiable {
    /// 裝置唯一 ID
    let id: String
    /// 安裝位置
    let location: String
    /// 狀態（上線/離線）
    let status: Status
    /// 電池電量百分比
    let battery: Int

    /// 裝置狀態列舉
    enum Status {
      case online, offline
    }
  }

  #Preview {
    DashboardView(viewModel: .preview)
  }

  // MARK: - Preview Helpers
  /// 預覽用 ViewModel，提供假資料給 SwiftUI Preview
  extension DashboardViewModel {
    fileprivate static var preview: DashboardViewModel {
      let manager = MockSupabaseManager()
      let viewModel = DashboardViewModel(manager: manager)
      viewModel.currentReading = Reading(
        id: 1,
        createdAt: Date(),
        deviceId: "tea_room_01",
        temperature: 24.5,
        humidity: 65.2
      )
      viewModel.history = [
        Reading(id: 1, createdAt: Date(), deviceId: "d1", temperature: 22, humidity: 60),
        Reading(id: 2, createdAt: Date(), deviceId: "d1", temperature: 23, humidity: 62),
        Reading(id: 3, createdAt: Date(), deviceId: "d1", temperature: 24, humidity: 65),
        Reading(id: 4, createdAt: Date(), deviceId: "d1", temperature: 23, humidity: 64),
        Reading(id: 5, createdAt: Date(), deviceId: "d1", temperature: 25, humidity: 68),
        Reading(id: 6, createdAt: Date(), deviceId: "d1", temperature: 26, humidity: 65),
        Reading(id: 7, createdAt: Date(), deviceId: "d1", temperature: 24, humidity: 63),
      ]
      viewModel.isSubscribed = true
      return viewModel
    }
  }

  /// 假 Supabase 管理器，專供 Preview 或測試用，不實際連線
  private final class MockSupabaseManager: SupabaseManaging {
    var sessionToken: String? = nil
    func signIn(email: String, password: String) async throws {}
    func signUp(email: String, password: String) async throws {}
    func fetchHistory(limit: Int) async throws -> [Reading] { [] }
    func signOut() {}
    func signIn(
      email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void
    ) {}
    func signUp(
      email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void
    ) {}
    func fetchHistory(limit: Int, completion: @escaping (Result<[Reading], Error>) -> Void) {}
    func subscribeToReadings(onInsert: @escaping (Reading) -> Void) {}
    func unsubscribeFromReadings() {}
  }
#endif
