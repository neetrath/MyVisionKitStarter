import SwiftUI

enum HomeDestination {
    case card
}

struct HomeView: View {
    private let onFinish: (HomeDestination) -> Void

    init(onFinish: @escaping (HomeDestination) -> Void) {
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, world!")
            Button(action: {
                onFinish(.card)
            }, label: {
                Text("Card OCR")
            })
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    HomeView { _ in }
}
