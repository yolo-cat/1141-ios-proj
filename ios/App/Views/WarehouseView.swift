/*
 * File: WarehouseView.swift
 * Purpose: Tea inventory management UI displaying stored Pu'er teas with expandable detail cards.
 * Architecture: SwiftUI View with local state. Data model inline.
 * AI Context: Sample data includes researched info for 大益 7542, 大益 8582, 下關 8653.
 */

#if canImport(SwiftUI)
  import SwiftUI

  // MARK: - Data Model

  struct PuerhTea: Identifiable {
    let id = UUID()
    let name: String  // e.g., "大益 7542"
    let recipeCode: String  // e.g., "7542"
    let factory: String  // e.g., "勐海茶廠"
    let year: Int  // Recipe creation year
    let teaGrade: String  // e.g., "4級茶青"
    let description: String
    var quantity: TeaQuantity
  }

  struct TeaQuantity {
    var bing: Int  // 餅 (single cake)
    var tong: Int  // 筒 (7 cakes per tong)
    var jian: Int  // 件 (typically 12 tong per jian)

    var displayText: String {
      var parts: [String] = []
      if jian > 0 { parts.append("\(jian) 件") }
      if tong > 0 { parts.append("\(tong) 筒") }
      if bing > 0 { parts.append("\(bing) 餅") }
      return parts.isEmpty ? "無庫存" : parts.joined(separator: " · ")
    }

    var totalCakes: Int {
      bing + (tong * 7) + (jian * 12 * 7)
    }
  }

  // MARK: - Sample Data

  extension PuerhTea {
    static let samples: [PuerhTea] = [
      PuerhTea(
        name: "大益 7542",
        recipeCode: "7542",
        factory: "勐海茶廠",
        year: 1975,
        teaGrade: "4級茶青",
        description: """
          被譽為評鑑普洱生茶品質的標竿和市場風向標。配方編號「7542」代表1975年研製，採用4級茶青，由勐海茶廠（代號2）出品。

          ▸ 外觀：茶餅端正圓整，條索緊結，色澤烏潤顯芽毫
          ▸ 香氣：花果蜜香高揚持久，陳化後轉為樟木香、藥香
          ▸ 口感：茶湯明亮，入口回甘生津強烈，陳化潛力極佳
          ▸ 沖泡：100°C沸水，5克/100ml，首泡5-10秒
          """,
        quantity: TeaQuantity(bing: 3, tong: 2, jian: 1)
      ),
      PuerhTea(
        name: "大益 8582",
        recipeCode: "8582",
        factory: "勐海茶廠",
        year: 1985,
        teaGrade: "8級茶青",
        description: """
          1985年研製，原供香港南天貿易公司，與7542並稱「大益老五樣」。採用8級粗壯茶青，3-4級撒面，5-8級為裡茶。

          ▸ 外觀：茶餅圓厚，條索肥壯，色澤烏潤顯芽毫
          ▸ 香氣：純正陳香，常帶梅子韻或花果香
          ▸ 口感：滋味醇厚，回甘迅速，茶氣濃郁，陳化快速
          ▸ 適合：口味偏重的茶友，收藏陳化
          """,
        quantity: TeaQuantity(bing: 5, tong: 1, jian: 0)
      ),
      PuerhTea(
        name: "下關 8653",
        recipeCode: "8653",
        factory: "下關茶廠",
        year: 1986,
        teaGrade: "5級茶青",
        description: """
          1986年為日本客戶定制，後轉內銷成為明星產品。下關茶廠代號3，以鐵餅壓制聞名，選用臨滄古樹茶菁。

          ▸ 外觀：鐵餅壓制緊實，餅面常有布紋，呈紅褐色油潤
          ▸ 香氣：濃郁陳香，混合果香花香，陳年帶樟香
          ▸ 茶湯：深琥珀色或栗紅色，清澈透亮，富膠質感
          ▸ 口感：醇厚細膩，回甘持久悠長，耐泡度高
          """,
        quantity: TeaQuantity(bing: 0, tong: 3, jian: 0)
      ),
    ]
  }

  // MARK: - Warehouse View

  struct WarehouseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var teas: [PuerhTea] = PuerhTea.samples
    @State private var expandedTeaId: UUID?

    var body: some View {
      NavigationStack {
        ZStack {
          DesignSystem.Colors.canvas.ignoresSafeArea()

          ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
              // Summary Card
              summaryCard
                .padding(.horizontal, 24)

              // Tea List
              ForEach(teas) { tea in
                TeaInventoryCard(
                  tea: tea,
                  isExpanded: expandedTeaId == tea.id,
                  onTap: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                      if expandedTeaId == tea.id {
                        expandedTeaId = nil
                      } else {
                        expandedTeaId = tea.id
                      }
                    }
                  }
                )
                .padding(.horizontal, 24)
              }

              Color.clear.frame(height: 40)
            }
            .padding(.vertical, 16)
          }
        }
        .navigationTitle("茶倉管理")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button(action: { dismiss() }) {
              Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
            }
          }
        }
      }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
      HStack(spacing: 16) {
        VStack(alignment: .leading, spacing: 4) {
          Text("庫存總覽")
            .font(.caption.bold())
            .foregroundColor(DesignSystem.Colors.textSecondary)

          HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(totalCakes)")
              .font(.system(size: 32, weight: .bold, design: .rounded))
              .foregroundColor(DesignSystem.Colors.primary)
            Text("餅")
              .font(.body.bold())
              .foregroundColor(DesignSystem.Colors.textSecondary)
          }
        }

        Spacer()

        VStack(alignment: .trailing, spacing: 4) {
          Text("\(teas.count) 款茶品")
            .font(.subheadline.bold())
            .foregroundColor(DesignSystem.Colors.textSecondary)

          Text("點擊查看詳情")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .padding(20)
      .background(DesignSystem.Colors.cardStandard)
      .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadius))
      .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var totalCakes: Int {
      teas.reduce(0) { $0 + $1.quantity.totalCakes }
    }
  }

  // MARK: - Tea Inventory Card

  struct TeaInventoryCard: View {
    let tea: PuerhTea
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
      VStack(spacing: 0) {
        // Header Row
        Button(action: onTap) {
          HStack(alignment: .center, spacing: 12) {
            // Tea Icon
            ZStack {
              Circle()
                .fill(
                  LinearGradient(
                    colors: [
                      DesignSystem.Colors.primary, DesignSystem.Colors.primary.opacity(0.7),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
                )
                .frame(width: 48, height: 48)

              Text("茶")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            }

            // Tea Info
            VStack(alignment: .leading, spacing: 4) {
              Text(tea.name)
                .font(DesignSystem.Typography.cardTitle)
                .foregroundColor(DesignSystem.Colors.textSecondary)

              HStack(spacing: 8) {
                Text(tea.factory)
                  .font(.caption)
                  .foregroundColor(.secondary)

                Text("·")
                  .foregroundColor(.secondary)

                Text("\(tea.year)年配方")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
            }

            Spacer()

            // Quantity Badge
            VStack(alignment: .trailing, spacing: 4) {
              Text(tea.quantity.displayText)
                .font(.caption.bold())
                .foregroundColor(DesignSystem.Colors.primary)

              Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            }
          }
          .padding(16)
        }
        .buttonStyle(.plain)

        // Expandable Detail
        if isExpanded {
          Divider()
            .padding(.horizontal, 16)

          VStack(alignment: .leading, spacing: 12) {
            // Grade Badge
            HStack(spacing: 8) {
              Text(tea.teaGrade)
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(DesignSystem.Colors.primary)
                .clipShape(Capsule())

              Text(tea.recipeCode)
                .font(.caption.bold())
                .foregroundColor(DesignSystem.Colors.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(DesignSystem.Colors.primary.opacity(0.1))
                .clipShape(Capsule())
            }

            // Description
            Text(tea.description)
              .font(.callout)
              .foregroundColor(DesignSystem.Colors.textSecondary)
              .lineSpacing(4)
          }
          .padding(16)
          .transition(.opacity.combined(with: .move(edge: .top)))
        }
      }
      .background(DesignSystem.Colors.cardStandard)
      .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Layout.cornerRadius))
      .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
  }

  // MARK: - Preview

  #Preview {
    WarehouseView()
  }
#endif
