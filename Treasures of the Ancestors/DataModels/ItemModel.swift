import SwiftData
import Foundation

@Model
class ItemModel {
    var id = UUID()
    
    var name: String
    var condition: String
    var category: ItemCategory
    var country: String
    var year: Int
    var state: String?
    var price: Int?
    var placeOfDiscovery: String?
    var itemState: ItemState
    
    var image: Data?
    
    init(id: UUID = UUID(), name: String, condition: String, category: ItemCategory, country: String, year: Int, state: String? = nil, price: Int? = nil, placeOfDiscovery: String? = nil, itemState: ItemState, image: Data? = nil) {
        self.id = id
        self.name = name
        self.condition = condition
        self.category = category
        self.country = country
        self.year = year
        self.state = state
        self.price = price
        self.placeOfDiscovery = placeOfDiscovery
        self.itemState = itemState
        self.image = image
    }
}

enum ItemState: String, CaseIterable, Codable {
    case sold, lost, broken, inherited, inCollection
}

enum ItemCategory: String, CaseIterable, Codable {
    case coins, dishes, books
}
