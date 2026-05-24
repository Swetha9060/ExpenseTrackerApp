import Foundation

enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food = "Food"
    case transportation = "Transportation"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case bills = "Bills"
    case health = "Health"
    case education = "Education"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "car"
        case .entertainment: return "tv"
        case .shopping: return "bag"
        case .bills: return "doc.text"
        case .health: return "heart"
        case .education: return "book"
        case .other: return "ellipsis"
        }
    }
    
    var color: String {
        switch self {
        case .food: return "green"
        case .transportation: return "blue"
        case .entertainment: return "purple"
        case .shopping: return "pink"
        case .bills: return "orange"
        case .health: return "red"
        case .education: return "indigo"
        case .other: return "gray"
        }
    }
}


