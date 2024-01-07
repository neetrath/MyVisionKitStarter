enum PresentationStyle: String, Identifiable {
    case push
    case present
    case replace

    var id: String {
        rawValue
    }
}
