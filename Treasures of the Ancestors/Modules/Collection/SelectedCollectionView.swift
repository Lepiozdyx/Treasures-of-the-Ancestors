import SwiftUI
import SwiftData

struct SelectedCollectionView: View {
    let selectedCategory: ItemCategory
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var items: [ItemModel]
    
    @State private var isCreateItemOpen = false
    @State private var editingItem: ItemModel?
    @State private var selectedItem: ItemModel?
    
    private var filteredItems: [ItemModel] {
        items
            .filter { $0.category == selectedCategory }
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
                Button {
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 26, weight: .regular))
                            .foregroundColor(.white)
                        Text("Back")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.top, 12)
            
            if filteredItems.isEmpty {
                VStack(spacing: 10) {
                    Spacer().frame(height: 50)
                    
                    Text("No items yet")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                    
                    Text("Add your first item to this collection.")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.75))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 22)
            } else {
                List {
                    ForEach(filteredItems, id: \.id) { item in
                        itemRow(item)
                            .listRowInsets(EdgeInsets(top: 8, leading: 22, bottom: 8, trailing: 22))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedItem = item
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    editingItem = item
                                } label: {
                                    Image(.editBtn)
                                        .resizable().scaledToFit().frame(width: 24, height: 24)
                                }
                                .tint(.clear)
                                
                                Button(role: .destructive) {
                                    deleteItem(item)
                                } label: {
                                    Image(.delBtn)
                                        .resizable().scaledToFit().frame(width: 24, height: 24)
                                }
                                .tint(.clear)
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            
            Spacer(minLength: 0)
            
            HStack {
                Spacer()
                Button {
                    isCreateItemOpen = true
                } label: {
                    Text("+add an item")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .frame(height: 54)
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
            .padding(.bottom, 24)
        }
        .bg()
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $isCreateItemOpen) {
            CreateItemView(selectedCategory: selectedCategory)
        }
        .fullScreenCover(item: $editingItem) { item in
            CreateItemView(selectedCategory: selectedCategory, editingItem: item)
        }
        .fullScreenCover(item: $selectedItem) { item in
            ItemDetailsView(item: item)
        }
    }
    
    private func deleteItem(_ item: ItemModel) {
        context.delete(item)
        do {
            try context.save()
        } catch {
            print("Delete failed: \(error.localizedDescription)")
        }
    }
    
    private func itemRow(_ item: ItemModel) -> some View {
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
                    .frame(width: 126, height: 58)
                    .background(Color.black.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 86)
    }
    
    @ViewBuilder
    private func previewImage(for item: ItemModel) -> some View {
        if let data = item.image, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Image(defaultAssetName(for: selectedCategory))
                .resizable()
                .scaledToFit()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
    }
    
    private func defaultAssetName(for category: ItemCategory) -> String {
        switch category {
        case .coins: return "coinsAsset"
        case .dishes: return "dishesAsset"
        case .books: return "booksAsset"
        }
    }
}
