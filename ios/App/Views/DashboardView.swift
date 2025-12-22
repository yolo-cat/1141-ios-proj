/*
 * File: DashboardView.swift
 * Purpose: Main dashboard UI displaying real-time sensor data, charts, and device status.
 * Architecture: SwiftUI View using @Bindable for DashboardViewModel. Features Neo-Bento Grid layout.
 * AI Context: UI-only. All business/alert logic should stay in DashboardViewModel.
 */

#if canImport(SwiftUI)
  import SwiftUI
  import Charts
  import Observation

  // MARK: - Dashboard View

  struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel
    @State private var activeTab = 0

    // Grouped history by device ID
    private var groupedHistory: [String: [Reading]] {
      Dictionary(grouping: viewModel.history, by: { $0.deviceId })
    }

    private var activeDeviceIds: [String] {
      Array(groupedHistory.keys).sorted()
    }

    var body: some View {
      ZStack(alignment: .bottom) {
        // Global Canvas Background
        DesignSystem.Colors.canvas.ignoresSafeArea()

        VStack(spacing: 0) {
          // 1. New Header (Bold & Minimal)
          headerView
            .padding(.top, 8)
            .padding(.bottom, 16)
            .padding(.horizontal, 24)

          ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
              // 2. Neo-Bento Grid: Hero & Status
              bentoGridSection
                .padding(.horizontal, 24)

              // 3. Unified Climate Cards (Newest First List)
              cardsSection

              // Footer Space
              Color.clear.frame(height: 100)
            }
            .padding(.vertical)
          }
        }

        // 4. Floating Footer
        footerView
      }
      .onAppear {
        viewModel.startListening()
        viewModel.fetchDefaultHistory()
      }
    }

    // MARK: - Main Sections

    private var headerView: some View {
      HStack(alignment: .center) {
        Text("DASHBOARD")
          .font(DesignSystem.Typography.header)
          .foregroundColor(DesignSystem.Colors.textSecondary)
          .opacity(0.8)

        Spacer()

        // Depot Switcher (Capsule)
        Button(action: {}) {
          HStack(spacing: 6) {
            Text("Menghai Depot")
              .font(.subheadline.bold())
            Image(systemName: "chevron.down")
              .font(.caption.bold())
          }
          .foregroundColor(DesignSystem.Colors.textSecondary)
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
          .background(DesignSystem.Colors.cardStandard)
          .clipShape(Capsule())
          .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }

        // User Avatar
        Circle()
          .fill(DesignSystem.Colors.cardStandard)
          .frame(width: 44, height: 44)
          .overlay(
            Image(systemName: "person.crop.circle.fill")
              .font(.title2)
              .foregroundColor(DesignSystem.Colors.textSecondary)
          )
          .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
      }
    }

    // MARK: - Bento Grid

    private var bentoGridSection: some View {
      VStack(spacing: DesignSystem.Layout.gridSpacing) {
        // Row 1: Hero Card (Spans Full Width)
        HeroDataCard(reading: viewModel.currentReading)
          .frame(height: 220)

        // Row 2: Status & Context (Split)
        HStack(spacing: DesignSystem.Layout.gridSpacing) {
          StatusCard(alertType: viewModel.alertType)
          ContextCard(reading: viewModel.currentReading)
        }
        .frame(height: 160)
      }
    }

    private var cardsSection: some View {
      VStack(spacing: 24) {
        // Section Title
        HStack {
          Text("HISTORY")
            .font(DesignSystem.Typography.label())
            .foregroundColor(DesignSystem.Colors.textSecondary)
          Spacer()
        }
        .padding(.horizontal, 24)

        // Content
        if activeDeviceIds.isEmpty {
          ContentUnavailableView("No Data", systemImage: "chart.bar.xaxis")
        } else {
          ForEach(Array(activeDeviceIds.enumerated()), id: \.element) { index, deviceId in
            let deviceInfo = viewModel.devices.first(where: { $0.id == deviceId })
            UnifiedClimateCard(
              deviceId: deviceId,
              location: deviceInfo?.location ?? "Unknown",
              status: deviceInfo?.status ?? .offline,
              battery: deviceInfo?.battery ?? 0,
              readings: groupedHistory[deviceId] ?? []
            )
            .padding(.horizontal, 24)
          }
        }
      }
    }

    private var footerView: some View {
      Button(action: {}) {
        HStack {
          Image(systemName: "building.2.fill")
          Text("Manage Warehouse")
            .fontWeight(.bold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(DesignSystem.Colors.primary)
        .clipShape(Capsule())
        .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
      }
      .padding(.bottom, 24)
    }
  }

  // MARK: - Sub Components

  /// 1. Hero Data Card (High Saturation)
  struct HeroDataCard: View {
    let reading: Reading?

    var body: some View {
      ZStack(alignment: .leading) {
        // High Saturation Background
        DesignSystem.Colors.primary

        // Decorators (Abstract Shapes)
        GeometryReader { geo in
          Circle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 200, height: 200)
            .offset(x: geo.size.width - 100, y: -50)

          Circle()  // Live Dot
            .fill(Color.green)
            .frame(width: 8, height: 8)
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .topTrailing)
            .shadow(color: .green.opacity(0.5), radius: 5)
        }

        VStack(alignment: .leading) {
          // Label
          HStack {
            Text("CURRENT")
              .font(DesignSystem.Typography.label())
              .foregroundColor(.white.opacity(0.8))
          }

          Spacer()

          // Big Number
          HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(Int(reading?.temperature ?? 0))°")
              .font(DesignSystem.Typography.heroNumber)
              .foregroundColor(.white)
            Text("C")
              .font(.title2.bold())
              .foregroundColor(.white.opacity(0.6))
          }

          Spacer()

          // Humidity Row
          HStack(spacing: 8) {
            Image(systemName: "drop.fill")
              .symbolRenderingMode(.multicolor)
              .font(.title3)
            Text("\(Int(reading?.humidity ?? 0))%")
              .font(.title2.bold())
              .foregroundColor(.white)
            Text("Humidity")
              .font(.caption.bold())
              .foregroundColor(.white.opacity(0.6))
          }
        }
        .padding(DesignSystem.Layout.padding)
      }
      .neoBentoCard(color: .clear)  // Base modifier
    }
  }

  /// 2. Status Card (3D Icon)
  struct StatusCard: View {
    let alertType: DashboardViewModel.AlertType

    var body: some View {
      VStack {
        Spacer()

        // Icon
        Image(
          systemName: alertType.isCritical ? "exclamationmark.triangle.fill" : "checkmark.seal.fill"
        )
        .font(.system(size: 48))
        .foregroundStyle(
          alertType.isCritical
            ? LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
            : LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
        )
        .shadow(color: alertType.isCritical ? .red.opacity(0.3) : .green.opacity(0.2), radius: 10)

        Spacer()

        // Text
        Text(alertType.isCritical ? "ALERT" : "NORMAL")
          .font(DesignSystem.Typography.label())
          .foregroundColor(
            alertType.isCritical ? DesignSystem.Colors.danger : DesignSystem.Colors.accentB
          )
          .padding(.bottom, 8)
      }
      .frame(maxWidth: .infinity)
      .neoBentoCard()
    }
  }

  /// 3. Context Card (Outline Style)
  struct ContextCard: View {
    let reading: Reading?

    var body: some View {
      VStack(alignment: .leading) {
        HStack {
          Text("UPDATED")
            .font(DesignSystem.Typography.label())
            .foregroundColor(DesignSystem.Colors.textSecondary)
          Spacer()
          Image(systemName: "clock")
            .font(.caption)
            .foregroundColor(DesignSystem.Colors.textSecondary)
        }

        Spacer()

        if let date = reading?.createdAt {
          VStack(alignment: .leading) {
            Text(date, format: .dateTime.hour().minute())
              .font(.system(size: 28, weight: .bold, design: .rounded))
              .foregroundColor(DesignSystem.Colors.primary)
            Text(date, format: .dateTime.month().day())
              .font(.caption.bold())
              .foregroundColor(DesignSystem.Colors.textSecondary)
          }
        } else {
          Text("--:--")
            .font(.title.bold())
            .foregroundColor(.secondary)
        }

        Spacer()
      }
      .padding(DesignSystem.Layout.padding)
      .frame(maxWidth: .infinity)
      .background(Color.clear)
      .overlay(
        RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadius)
          .stroke(DesignSystem.Colors.textSecondary.opacity(0.2), lineWidth: 4)
      )
    }
  }

  /// 4. Unified Climate Card (Clean Chart + Zebra List)
  struct UnifiedClimateCard: View {
    let deviceId: String
    let location: String
    let status: DashboardViewModel.DeviceInfo.Status
    let battery: Int
    let readings: [Reading]

    @State private var showList = false

    var body: some View {
      VStack(spacing: 0) {
        // Header
        HStack {
          VStack(alignment: .leading, spacing: 2) {
            Text(location)
              .font(DesignSystem.Typography.cardTitle)
              .foregroundColor(DesignSystem.Colors.textSecondary)
            Text(deviceId)
              .font(.caption.bold())
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(Color.gray.opacity(0.1))
              .clipShape(Capsule())
              .foregroundColor(.secondary)
          }

          Spacer()

          Button(action: { withAnimation { showList.toggle() } }) {
            Image(systemName: showList ? "chart.xyaxis.line" : "list.bullet")
              .font(.title3)
              .foregroundColor(DesignSystem.Colors.primary)
              .padding(10)
              .background(DesignSystem.Colors.primary.opacity(0.1))
              .clipShape(Circle())
          }
        }
        .padding(20)

        Divider()

        // Content
        if showList {
          // Zebra List
          VStack(spacing: 0) {
            let sorted = readings.sorted { $0.createdAt > $1.createdAt }.prefix(5)
            ForEach(Array(sorted.enumerated()), id: \.element.id) { index, item in
              HStack {
                Text(item.createdAt, format: .dateTime.hour().minute())
                  .font(.system(.callout, design: .monospaced))
                  .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 12) {
                  Text("\(String(format: "%.1f", item.temperature))°")
                    .fontWeight(.bold)
                    .foregroundColor(DesignSystem.Colors.primary)
                  Text("\(String(format: "%.0f", item.humidity))%")
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                }
                .font(.system(.body, design: .monospaced))
              }
              .padding(.horizontal, 20)
              .padding(.vertical, 12)
              .background(index % 2 == 0 ? Color.clear : Color.gray.opacity(0.05))
            }
          }
          .padding(.bottom, 16)
        } else {
          // Clean Chart
          Chart(readings.sorted(by: { $0.createdAt < $1.createdAt })) { item in
            LineMark(
              x: .value("Time", item.createdAt),
              y: .value("Temp", item.temperature)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(DesignSystem.Colors.primary)
            .lineStyle(StrokeStyle(lineWidth: 3))

            AreaMark(
              x: .value("Time", item.createdAt),
              y: .value("Temp", item.temperature)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
              LinearGradient(
                colors: [DesignSystem.Colors.primary.opacity(0.2), .clear],
                startPoint: .top,
                endPoint: .bottom
              )
            )
          }
          .chartXAxis(.hidden)
          .chartYAxis(.hidden)
          .frame(height: 150)
          .padding(20)
        }
      }
      .neoBentoCard()
    }
  }

  // MARK: - Previews

  #Preview {
    let mockVM = DashboardViewModel(manager: MockSupabaseManager())
    mockVM.currentReading = Reading(
      id: 1, createdAt: Date(), deviceId: "ESP-01", temperature: 24.5, humidity: 60)
    mockVM.devices = [
      DashboardViewModel.DeviceInfo(
        id: "ESP-01", location: "Warehouse A", status: .online, battery: 80)
    ]
    mockVM.history = [
      Reading(id: 1, createdAt: Date(), deviceId: "ESP-01", temperature: 24.5, humidity: 60),
      Reading(
        id: 2, createdAt: Date().addingTimeInterval(-3600), deviceId: "ESP-01", temperature: 23.0,
        humidity: 55),
      Reading(
        id: 3, createdAt: Date().addingTimeInterval(-7200), deviceId: "ESP-01", temperature: 22.0,
        humidity: 50),
    ]
    return DashboardView(viewModel: mockVM)
  }

  // Minimal Mock Manager for Preview
  class MockSupabaseManager: SupabaseManaging {
    var sessionToken: String? = "mock_token"
    var mockHistory: [Reading] = []
    func signIn(email: String, password: String) async throws {}
    func signUp(email: String, password: String) async throws {}
    func fetchHistory(limit: Int) async throws -> [Reading] { return mockHistory }
    func signOut() {}
    func signIn(
      email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void
    ) {}
    func signUp(
      email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void
    ) {}
    func fetchHistory(limit: Int, completion: @escaping (Result<[Reading], Error>) -> Void) {
      completion(.success([]))
    }
    func subscribeToReadings(onInsert: @escaping (Reading) -> Void) {}
    func unsubscribeFromReadings() {}
  }
#endif
