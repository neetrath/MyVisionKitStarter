import SwiftUI

enum ResultDestination {
    case home
}

struct ResultView: View {
    @StateObject var viewModel: ResultViewModel

    private let onFinish: (ResultDestination) -> Void

    init(
        viewModel: ResultViewModel,
        onFinish: @escaping (ResultDestination) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onFinish = onFinish
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.results) { result in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(result.key)
                            .font(Font.system(size: 16, weight: .bold))
                        Text(result.value)
                            .font(Font.system(size: 16, weight: .regular))
                    }
                }
                Spacer()
            }
            Button(action: {
                onFinish(.home)
            }, label: {
                Text("Back to Home")
            })
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Results")
                }
            }
        }
    }
}

#Preview {
    ResultView(viewModel: ResultViewModel(results: [.init(key: "Key", value: "Value")])) { _ in }
}
