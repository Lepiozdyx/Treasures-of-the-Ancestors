import SwiftUI
import SwiftData
import PhotosUI

struct CreateItemView: View {
    let selectedCategory: ItemCategory
    var editingItem: ItemModel? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var name = ""
    @State private var conditionText = ""
    @State private var category: ItemCategory
    @State private var country = ""
    @State private var yearText = ""
    @State private var stateText = ""
    @State private var priceText = ""
    @State private var placeOfDiscovery = ""
    @State private var itemState: ItemState = .inCollection
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var imageData: Data?
    
    @State private var showValidation = false
    @State private var validationMessage = ""
    
    init(selectedCategory: ItemCategory, editingItem: ItemModel? = nil) {
        self.selectedCategory = selectedCategory
        self.editingItem = editingItem
        _category = State(initialValue: editingItem?.category ?? selectedCategory)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
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
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    photoSection
                    
                    Group {
                        labeledField("Name", text: $name)
                        labeledField("Condition", text: $conditionText)
                        labeledField("Country", text: $country)
                        labeledField("Year", text: $yearText, keyboard: .numberPad)
                        labeledField("State", text: $stateText)
                        labeledField("Price", text: $priceText, keyboard: .numberPad)
                        labeledField("Place of discovery", text: $placeOfDiscovery)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 18)
            }
            
            Button {
                saveItem()
            } label: {
                Text(editingItem == nil ? "Save" : "Update")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
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
                    .padding(.horizontal, 14)
                    .padding(.bottom, 16)
            }
        }
        .bg()
        .hideKeyboardOnTap()
        .navigationBarBackButtonHidden(true)
        .onAppear { fillIfEditing() }
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
        .alert("Validation", isPresented: $showValidation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
    }
    
    private var photoSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.25))
            
            VStack(spacing: 0) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.black.opacity(0.35))
                        
                        if let data = imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: UIScreen.main.bounds.width - 30, maxHeight: .infinity)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        } else {
                            Text("upload a photo")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(.plain)
                
                Menu {
                    ForEach(ItemState.allCases, id: \.self) { state in
                        Button(itemStateTitle(state)) { itemState = state }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(itemStateTitle(itemState))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(red: 0.85, green: 0.68, blue: 0.35))
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 34)
                    .overlay(Capsule().stroke(Color(red: 0.85, green: 0.68, blue: 0.35), lineWidth: 1))
                }
                .padding(.top, 8)
                .padding(.bottom, 4)
            }
            .padding(12)
        }
        .frame(height: 340)
    }
    
    private func labeledField(_ title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            
            HStack {
                TextField("Phone", text: text)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black.opacity(0.75))
                    .keyboardType(keyboard)
                
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.85, green: 0.68, blue: 0.35).opacity(0.5))
            }
            .padding(.horizontal, 12)
            .frame(height: 52)
            .background(Color.white.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(red: 0.85, green: 0.68, blue: 0.35), lineWidth: 1)
            )
        }
    }
    
    private func fillIfEditing() {
        guard let item = editingItem else { return }
        name = item.name
        conditionText = item.condition
        category = item.category
        country = item.country
        yearText = String(item.year)
        stateText = item.state ?? ""
        priceText = item.price.map(String.init) ?? ""
        placeOfDiscovery = item.placeOfDiscovery ?? ""
        itemState = item.itemState
        imageData = item.image
    }
    
    private func saveItem() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            validationMessage = "Name is required."
            showValidation = true
            return
        }
        
        guard let year = Int(yearText), year > 0 else {
            validationMessage = "Year must be a valid number."
            showValidation = true
            return
        }
        
        let price = Int(priceText.trimmingCharacters(in: .whitespacesAndNewlines))
        let trimmedCondition = conditionText.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalCondition = trimmedCondition.isEmpty ? itemStateTitle(itemState) : trimmedCondition
        
        if let item = editingItem {
            item.name = trimmedName
            item.condition = finalCondition
            item.category = category
            item.country = country.trimmingCharacters(in: .whitespacesAndNewlines)
            item.year = year
            item.state = stateText.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            item.price = price
            item.placeOfDiscovery = placeOfDiscovery.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            item.itemState = itemState
            item.image = imageData
        } else {
            let newItem = ItemModel(
                name: trimmedName,
                condition: finalCondition,
                category: category,
                country: country.trimmingCharacters(in: .whitespacesAndNewlines),
                year: year,
                state: stateText.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                price: price,
                placeOfDiscovery: placeOfDiscovery.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                itemState: itemState,
                image: imageData
            )
            context.insert(newItem)
        }
        
        do {
            try context.save()
            dismiss()
        } catch {
            validationMessage = "Failed to save item."
            showValidation = true
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
}

private extension String {
    var nilIfEmpty: String? {
        let t = trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}
