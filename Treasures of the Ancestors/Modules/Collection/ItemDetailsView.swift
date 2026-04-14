import SwiftUI
import SwiftData

struct ItemDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: ItemModel
    
    @State private var isEditOpen = false
    
    var body: some View {
        VStack(spacing: 0) {
            // NAV BAR (не в скролле)
            HStack {
                Button {
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(.white)
                        Text("Back")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
                
                Text(item.name)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Spacer()
                
                Color.clear.frame(width: 34, height: 34)
            }
            .padding(.horizontal, 24.fitW)
            .padding(.top, 10)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.white.opacity(0.25))
                        
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.black.opacity(0.35))
                                
                                previewImage
                            }
                            .frame(height: 290)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            
                            Menu {
                                ForEach(ItemState.allCases, id: \.self) { state in
                                    Button(itemStateTitle(state)) {
                                        item.itemState = state
                                        item.condition = itemStateTitle(state)
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(itemStateTitle(item.itemState))
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(red: 0.85, green: 0.68, blue: 0.35))
                                }
                                .padding(.horizontal, 20)
                                .frame(height: 38)
                                .overlay(
                                    Capsule().stroke(Color(red: 0.85, green: 0.68, blue: 0.35), lineWidth: 1)
                                )
                            }
                            .padding(.bottom, 4)
                        }
                        .padding(12)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 14)
                    
                    Text("All details:")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(.white)
                        .padding(.top, 12)
                    
                    VStack(spacing: 18) {
                        detailRow("Year", "\(item.year)")
                        detailRow("Country", safe(item.country))
                        detailRow("Condition", safe(item.condition))
                        detailRow("Price", item.price != nil ? "\(item.price!) United States Dollar" : "—")
                        detailRow("Place of discovery", safe(item.placeOfDiscovery))
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 12)
                    
                    HStack {
                        Spacer()
                        Button {
                            isEditOpen = true
                        } label: {
                            Text("Edit")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(width: 150, height: 46)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.95, green: 0.77, blue: 0.26),
                                            Color(red: 0.73, green: 0.44, blue: 0.12)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                }
            }
        }
        .bg()
        .fullScreenCover(isPresented: $isEditOpen) {
            CreateItemView(selectedCategory: item.category, editingItem: item)
        }
    }
    
    private var previewImage: some View {
        Group {
            if let data = item.image, let uiImage = UIImage(data: data) {
                // Важно: вертикальные/любые фото заполняют контейнер и обрезаются
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: UIScreen.main.bounds.width - 30, maxHeight: .infinity)
                    .clipped()
            } else {
                Image(defaultAssetName(for: item.category))
                    .resizable()
                    .scaledToFit()
                    .padding(16)
            }
        }
    }
    
    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private func itemStateTitle(_ value: ItemState) -> String {
        switch value {
        case .sold: return "Sold"
        case .lost: return "Lost"
        case .broken: return "Broken"
        case .inherited: return "Inherited"
        case .inCollection: return "In Collection"
        }
    }
    
    private func defaultAssetName(for category: ItemCategory) -> String {
        switch category {
        case .coins: return "coinsAsset"
        case .dishes: return "dishesAsset"
        case .books: return "booksAsset"
        }
    }
    
    private func safe(_ value: String?) -> String {
        guard let v = value, !v.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return "—" }
        return v
    }
}
