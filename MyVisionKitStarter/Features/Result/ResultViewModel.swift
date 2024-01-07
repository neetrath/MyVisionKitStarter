import Combine

class ResultViewModel: ObservableObject {
    @Published var results: [OCRResult]

    init(results: [OCRResult]) {
        self.results = results
    }
}
