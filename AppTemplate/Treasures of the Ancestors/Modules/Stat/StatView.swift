import SwiftUI
import SwiftData
import Charts

struct StatView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var items: [ItemModel]
    
    @State private var mode: StatMode = .quantity
    
    private var top5ByQuantity: [ItemModel] {
        items
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .prefix(5)
            .map { $0 }
    }
    
    private var top5ByPrice: [ItemModel] {
        items
            .sorted { ($0.price ?? 0) > ($1.price ?? 0) }
            .prefix(5)
            .map { $0 }
    }
    
    private var topItems: [ItemModel] {
        mode == .quantity ? top5ByQuantity : top5ByPrice
    }
    
    private var categoryStats: [CategoryStat] {
        let total = max(items.count, 1)
        let coins = items.filter { $0.category == .coins }.count
        let dishes = items.filter { $0.category == .dishes }.count
        let books = items.filter { $0.category == .books }.count
        
        return [
            CategoryStat(category: .coins, count: coins, percent: Int((Double(coins) / Double(total) * 100).rounded())),
            CategoryStat(category: .dishes, count: dishes, percent: Int((Double(dishes) / Double(total) * 100).rounded())),
            CategoryStat(category: .books, count: books, percent: Int((Double(books) / Double(total) * 100).rounded()))
        ]
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 20)
                    .padding(.top, 6)
                
                HStack(spacing: 12) {
                    statModeButton(.quantity, title: "Quantity")
                    statModeButton(.price, title: "Price")
                }
                .padding(.horizontal, 22)
                .padding(.top, 14)
                
                Text("Top 5")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top, 14)
                
                VStack(spacing: 12) {
                    ForEach(topItems, id: \.id) { item in
                        topRow(item)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 10)
                
                chartCard
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
            }
        }
        .bg()
        .navigationBarBackButtonHidden(true)
    }
    
    private func statModeButton(_ target: StatMode, title: String) -> some View {
        let selected = mode == target
        
        return Button {
            mode = target
        } label: {
            Text(title)
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(selected ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    Group {
                        if selected {
                            LinearGradient(
                                colors: [
                                    Color(red: 0.95, green: 0.77, blue: 0.26),
                                    Color(red: 0.73, green: 0.44, blue: 0.12)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        } else {
                            Color.clear
                        }
                    }
                )
                .overlay(
                    Capsule().stroke(Color(red: 0.74, green: 0.42, blue: 0.06), lineWidth: 1)
                )
                .clipShape(Capsule())
        }
    }
    
    private func topRow(_ item: ItemModel) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.96, green: 0.73, blue: 0.17),
                                    Color(red: 0.74, green: 0.42, blue: 0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            
            HStack(spacing: 14) {
                Text(item.name)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                previewImage(for: item)
                    .frame(width: 108, height: 56)
                    .background(Color.black.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 84)
    }
    
    @ViewBuilder
    private func previewImage(for item: ItemModel) -> some View {
        if let data = item.image, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .clipped()
        } else {
            Image(defaultAssetName(for: item.category))
                .resizable()
                .scaledToFit()
                .padding(8)
        }
    }
    
    private var chartCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.22))
            
            VStack(alignment: .leading, spacing: 12) {
                Text(mode == .quantity ? "Quantity" : "Price")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                Text(monthYearString())
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.white.opacity(0.65))
                
                Chart(categoryStats) { stat in
                    SectorMark(
                        angle: .value("Count", stat.count),
                        innerRadius: .ratio(0.62),
                        angularInset: 2
                    )
                    .foregroundStyle(stat.color)
                }
                .frame(height: 230)
                .padding(.top, 10)
                
                HStack {
                    ForEach(categoryStats) { stat in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(stat.color)
                                    .frame(width: 8, height: 8)
                                Text(stat.title)
                                    .font(.system(size: 22, weight: .regular))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Text("\(stat.percent)%")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        
                        Spacer()
                    }
                }
                .padding(.top, 2)
            }
            .padding(16)
        }
        .frame(height: 520)
    }
    
    private func monthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private func defaultAssetName(for category: ItemCategory) -> String {
        switch category {
        case .coins: return "coinsAsset"
        case .dishes: return "dishesAsset"
        case .books: return "booksAsset"
        }
    }
}

private enum StatMode {
    case quantity, price
}

private struct CategoryStat: Identifiable {
    var id: ItemCategory { category }
    let category: ItemCategory
    let count: Int
    let percent: Int
    
    var title: String {
        switch category {
        case .coins: return "Coins"
        case .dishes: return "Dishes"
        case .books: return "Books"
        }
    }
    
    var color: Color {
        switch category {
        case .coins: return Color(red: 0.84, green: 0.58, blue: 0.00)
        case .dishes: return Color(red: 1.00, green: 0.64, blue: 0.20)
        case .books: return Color(red: 0.86, green: 0.82, blue: 0.42)
        }
    }
}

#Preview {
    StatView()
}
