import SwiftUI
import SwiftData

struct CollectionView: View {
    @Query private var items: [ItemModel]
    
    @State private var selectedCategory: ItemCategory?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                VStack(spacing: 16) {
                    categoryRow(
                        title: "Coins",
                        count: count(for: .coins),
                        imageName: "coinsAsset"
                    )
                    .onTapGesture {
                        selectedCategory = .coins
                    }
                    
                    categoryRow(
                        title: "Dishes",
                        count: count(for: .dishes),
                        imageName: "dishesAsset"
                    )
                    .onTapGesture {
                        selectedCategory = .dishes
                    }
                    
                    categoryRow(
                        title: "Books",
                        count: count(for: .books),
                        imageName: "booksAsset"
                    )
                    .onTapGesture {
                        selectedCategory = .books
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
            }
        }
        .bg()
        .fullScreenCover(item: $selectedCategory) { category in
            SelectedCollectionView(selectedCategory: category)
        }
    }
    
    private func count(for category: ItemCategory) -> Int {
        items.filter { $0.category == category }.count
    }
    
    private func categoryRow(title: String, count: Int, imageName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.35))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
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
                Text(title)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(count)")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white.opacity(0.92))
                
                Spacer()
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 106, height: 106)
                    .background(Color.black.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 18)
        }
        .frame(height: 160)
    }
}

// Нужно для fullScreenCover(item:)
extension ItemCategory: Identifiable {
    var id: String { rawValue }
}
