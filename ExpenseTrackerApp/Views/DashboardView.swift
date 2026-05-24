import SwiftUI
import Charts
internal import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ExpenseViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: ExpenseViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Budget Card
                    BudgetCardView(
                        budget: viewModel.budget?.amount ?? 0,
                        totalExpenses: viewModel.getTotalExpenses(),
                        remainingBalance: viewModel.getRemainingBalance()
                    )
                    
                    // Pie Chart
                    SpendingPieChartView(categoryBreakdown: viewModel.getCategoryBreakdown())
                    
                    // Quick Stats
                    QuickStatsView(expenses: viewModel.expenses)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .refreshable {
                viewModel.fetchExpenses()
                viewModel.fetchBudget()
            }
        }
    }
}

struct BudgetCardView: View {
    let budget: Double
    let totalExpenses: Double
    let remainingBalance: Double
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Monthly Budget")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(String(format: "$%.2f", budget))
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Remaining")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(String(format: "$%.2f", remainingBalance))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(remainingBalance >= 0 ? .green : .red)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Total Expenses")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(String(format: "$%.2f", totalExpenses))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                // Progress bar
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Spent")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    ProgressView(value: budget > 0 ? totalExpenses / budget : 0)
                        .frame(width: 100)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SpendingPieChartView: View {
    let categoryBreakdown: [(category: String, amount: Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Spending by Category")
                .font(.headline)
            
            if categoryBreakdown.isEmpty {
                Text("No expenses yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart {
                    ForEach(categoryBreakdown, id: \.category) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Category", item.category))
                        .cornerRadius(5)
                    }
                }
                .frame(height: 250)
                .chartLegend(position: .bottom, alignment: .center)
                
                // Category breakdown list
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(categoryBreakdown, id: \.category) { item in
                        CategoryRow(category: item.category, amount: item.amount)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CategoryRow: View {
    let category: String
    let amount: Double
    
    var body: some View {
        HStack {
            if let expenseCategory = ExpenseCategory(rawValue: category) {
                Image(systemName: expenseCategory.icon)
                    .foregroundColor(colorForCategory(expenseCategory.color))
                    .frame(width: 30)
            }
            
            Text(category)
                .font(.subheadline)
            
            Spacer()
            
            Text(String(format: "$%.2f", amount))
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
    
    private func colorForCategory(_ colorName: String) -> Color {
        switch colorName {
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "orange": return .orange
        case "red": return .red
        case "indigo": return .indigo
        default: return .gray
        }
    }
}

struct QuickStatsView: View {
    let expenses: [Expense]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Stats")
                .font(.headline)
            
            HStack(spacing: 15) {
                StatCard(title: "This Month", value: "\(expenses.count)", icon: "calendar")
                StatCard(title: "Avg. Expense", value: String(format: "$%.0f", averageExpense()), icon: "chart.bar")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func averageExpense() -> Double {
        guard !expenses.isEmpty else { return 0 }
        let total = expenses.reduce(0) { $0 + $1.amount }
        return total / Double(expenses.count)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    DashboardView()
}

