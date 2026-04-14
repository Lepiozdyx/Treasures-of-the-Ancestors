import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CollectionView()
                .tabItem {
                    Label("Collection", systemImage: "diamond")
                }
                .tag(0)

            ArchiveView()
                .tabItem {
                    Label("Archive", systemImage: "book")
                }
                .tag(1)

            StatView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
        }
        .preferredColorScheme(.dark)
        .tint(.yellow) // цвет активного таба
    }
}

struct Mock: View {
    let title: String

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text(title)
                .foregroundColor(.white)
                .font(.title2.bold())
        }
    }
}
