import SwiftUI
import SwiftData

struct Treasures_of_the_AncestorsApp: View {
    var body: some View {
        TabBarView()
            .preferredColorScheme(.dark)
            .modelContainer(for: [
                ItemModel.self,
                
            ])
    }
}
