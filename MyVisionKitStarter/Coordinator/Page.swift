enum Page: Hashable {
    case home
    case cardOCR
    case result(values: [OCRResult])

    var name: String {
        switch self {
        case .home:
            PageName.home.rawValue
        case .cardOCR:
            PageName.cardOCR.rawValue
        case .result:
            PageName.result.rawValue
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.name == rhs.name
    }
}

enum PageName: String {
    case home
    case cardOCR
    case result
}
