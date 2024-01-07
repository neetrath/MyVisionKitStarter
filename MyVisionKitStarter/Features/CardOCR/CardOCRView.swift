import SwiftUI

enum CardOCRDestination {
    case home
    case result(values: [OCRResult])
}

struct CardOCRView: View {
    @StateObject var viewModel: CardOCRViewModel

    @State var isFlashOn: Bool = false
    @State var isAutoCapture: Bool = false

    private let onFinish: (CardOCRDestination) -> Void

    init(viewModel: CardOCRViewModel, onFinish: @escaping (CardOCRDestination) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack(alignment: .top) {
            // TODO: Replace with the OCR Wrapper
            Button {
                self.onFinish(.result(values: [.init(key: "Key1", value: "Value1"),
                                               .init(key: "Key2", value: "Value2")]))
            } label: {
                Text("See the result")
            }
            .buttonStyle(.borderedProminent)

            if viewModel.state == .loading {
                Rectangle()
                    .fill(Color.white)
                    .opacity(0.8)
                ProgressView()
                    .controlSize(.large)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .navigationBarItems(trailing: trailingButtons)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Card OCR")
                }
            }
        }
        .onReceive(viewModel.onOCRSuccess) { results in
            self.onFinish(.result(values: results))
        }
    }

    private var backButton: some View {
        Button(action: {
            self.onFinish(.home)
        }, label: {
            Image(systemName: "arrowshape.backward.fill")
        })
    }

    private var trailingButtons: some View {
        HStack(spacing: 8) {
            flashButton
            autoCaptureButton
        }
    }

    private var flashButton: some View {
        let icon = isFlashOn ? Image(systemName: "lightbulb.fill") : Image(systemName: "lightbulb.slash")
        return Button(action: {
            isFlashOn.toggle()
        }, label: {
            icon
        })
        .symbolEffect(.bounce, value: isFlashOn)
    }

    private var autoCaptureButton: some View {
        let icon = isAutoCapture ? Image(systemName: "video.fill") : Image(systemName: "video.slash")
        return Button(action: {
            isAutoCapture.toggle()
        }, label: {
            icon
        })
        .symbolEffect(.bounce, value: isAutoCapture)
    }
}
