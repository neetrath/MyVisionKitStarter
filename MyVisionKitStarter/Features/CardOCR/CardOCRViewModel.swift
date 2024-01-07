import Combine
import UIKit
import Vision

class CardOCRViewModel: ObservableObject {
    enum State {
        case idle
        case loading
    }

    @Published var state: State = .idle

    let configuration: OCRConfiguration
    let onOCRSuccess = PassthroughSubject<[OCRResult], Never>()

    init(configuration: OCRConfiguration) {
        self.configuration = configuration
    }

    private func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
            request.results as? [VNRecognizedTextObservation] else {
            return
        }
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            observation.topCandidates(1).first?.string
        }

        // Process the recognized strings.
        processRecognizedStrings(values: recognizedStrings)
    }

    private func processRecognizedStrings(values: [String]) {
        var finalResults: [OCRResult] = []
        for expected in Insurance.allCases {
            if let result = values.first(where: { $0.contains(expected.searchKey) }) {
                let value = result.components(separatedBy: expected.searchKey)[safe: 1] ?? ""
                finalResults.append(OCRResult(key: expected.displayKey, value: value.trim()))
            }
        }

        if finalResults.isEmpty {
            finalResults = values.map { OCRResult(key: "", value: $0) }
        }

        onOCRSuccess.send(finalResults)
    }
}

extension CardOCRViewModel: OCRDelegate {
    func didReceive(cgImage: CGImage) {
        state = .loading

        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["th", "en"]

        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }

    func didError(_ error: OCRError) {
        // Handle the error
    }
}
