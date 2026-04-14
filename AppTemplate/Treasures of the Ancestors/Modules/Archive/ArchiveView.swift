import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Query private var items: [ItemModel]
    
    @State private var selectedFilter: ArchiveFilter = .all
    
    private var archivedItems: [ItemModel] {
        let source = items
        
        let filtered: [ItemModel]
        switch selectedFilter {
        case .all:
            filtered = source
        case .sold:
            filtered = source.filter { $0.itemState == .sold }
        case .lost:
            filtered = source.filter { $0.itemState == .lost }
        case .broken:
            filtered = source.filter { $0.itemState == .broken }
        case .inherited:
            filtered = source.filter { $0.itemState == .inherited }
        case .inCollection:
            filtered = source.filter { $0.itemState == .inCollection }
        }
        
        return filtered
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 20)
                .padding(.top, 6)
            
            HStack {
                Spacer()
                Menu {
                    ForEach(ArchiveFilter.allCases, id: \.self) { filter in
                        Button(filter.title) {
                            selectedFilter = filter
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 32, weight: .regular))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
            
            if archivedItems.isEmpty {
                VStack(spacing: 10) {
                    Spacer().frame(height: 60)
                    Text("Archive is empty")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Items with non-collection status will appear here.")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 22)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(archivedItems, id: \.id) { item in
                            row(item)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            
            Spacer(minLength: 0)
        }
        .bg()
    }
    
    private func row(_ item: ItemModel) -> some View {
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
                
                statusBadge(for: item)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 86)
    }
    
    private func statusBadge(for item: ItemModel) -> some View {
        VStack(spacing: 2) {
            Text(statusTitle(item.itemState))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(statusColor(item.itemState))
            
            if item.itemState == .sold, let price = item.price {
                Text("\(price)$")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.48, green: 1.00, blue: 0.12))
            }
        }
        .frame(width: 112, height: 56)
        .background(Color.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private func statusTitle(_ state: ItemState) -> String {
        switch state {
        case .sold: return "Sold"
        case .lost: return "Lost"
        case .broken: return "Broken"
        case .inherited: return "Inherited"
        case .inCollection: return "In Collection"
        }
    }
    
    private func statusColor(_ state: ItemState) -> Color {
        switch state {
        case .sold:
            return Color(red: 0.48, green: 1.00, blue: 0.12)
        case .broken:
            return .red
        case .lost:
            return Color(red: 1.00, green: 0.80, blue: 0.25)
        case .inherited:
            return .white
        case .inCollection:
            return .white
        }
    }
}

private enum ArchiveFilter: CaseIterable {
    case all, sold, lost, broken, inherited, inCollection
    
    var title: String {
        switch self {
        case .all: return "All"
        case .sold: return "Sold"
        case .lost: return "Lost"
        case .broken: return "Broken"
        case .inherited: return "Inherited"
        case .inCollection: return "In Collection"
        }
    }
}

#Preview {
    ArchiveView()
}
