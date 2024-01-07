import Combine
import SwiftUI

class MainCoordinator: ObservableObject {
    @Published var presentationStyle: PresentationStyle?
    @Published var path: [Page] = [] {
        didSet {
            pathReference = path.map { $0.name }
        }
    }

    private var pathReference: [String] = []

    private(set) var page: Page?

    init() {
    }

    @ViewBuilder
    func getView(page: Page?) -> some View {
        if let page {
            switch page {
            case .home:
                HomeView(onFinish: { [weak self] destination in
                    switch destination {
                    case .card:
                        self?.openPage(.cardOCR, presentationStyle: .push)
                    }
                })
            case .cardOCR:
                CardOCRView(viewModel: makeCardOCRViewModel(), onFinish: { [weak self] destination in
                    switch destination {
                    case .home:
                        self?.dismissLast()
                    case let .result(values):
                        self?.openPage(.result(values: values), presentationStyle: .push)
                    }
                })
            case let .result(values):
                ResultView(viewModel: makeResultViewModel(results: values), onFinish: { [weak self] destination in
                    switch destination {
                    case .home:
                        self?.dismissTo(.home)
                    }
                })
            }
        } else {
            EmptyView()
        }
    }

    func makeCardOCRViewModel() -> CardOCRViewModel {
        let configuration = OCRConfiguration()
        let viewModel = CardOCRViewModel(configuration: configuration)
        return viewModel
    }

    func makeResultViewModel(results: [OCRResult]) -> ResultViewModel {
        let viewModel = ResultViewModel(results: results)
        return viewModel
    }
}

// MARK: Navigation controller

extension MainCoordinator {
    private func openPage(_ page: Page, presentationStyle: PresentationStyle) {
        self.page = page
        switch presentationStyle {
        case .push:
            self.presentationStyle = nil
            path.append(page)
        case .present:
            self.presentationStyle = presentationStyle
        case .replace:
            path = [page]
        }
    }

    private func dismissLast() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    private func dismiss(numberOfScreen: Int = 1) {
        path.removeLast(numberOfScreen)
    }

    private func dismissTo(_ pageName: PageName) {
        for context in pathReference.reversed() {
            if context == pageName.rawValue {
                break
            }
            path.removeLast()
        }
    }
}
