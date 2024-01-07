enum Insurance: CaseIterable {
    case policyNo
    case member
    case policyHolder

    var searchKey: String {
        switch self {
        case .policyNo:
            "Policy No."
        case .member:
            "KHUN"
        case .policyHolder:
            "Policyholder"
        }
    }

    var displayKey: String {
        switch self {
        case .policyNo:
            "Policy No."
        case .member:
            "Member"
        case .policyHolder:
            "Policy Holder"
        }
    }
}
