import SwiftUI
internal import CoreData

struct BudgetView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ExpenseViewModel
    
    @State private var budgetAmount: String = ""
    @State private var isEditing = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init() {
        _viewModel = StateObject(wrappedValue: ExpenseViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Current Budget Card
                    VStack(spacing: 20) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 5) {
                            Text("Monthly Budget")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if let budget = viewModel.budget {
                                Text(String(format: "$%.2f", budget.amount))
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                            } else {
                                Text("Not Set")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Budget Status
                        if let budget = viewModel.budget {
                            BudgetStatusCard(
                                budget: budget.amount,
                                spent: viewModel.getTotalExpenses(),
                                remaining: viewModel.getRemainingBalance()
                            )
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Set/Edit Budget
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Set Monthly Budget")
                            .font(.headline)
                        
                        HStack {
                            Text("$")
                                .font(.title)
                                .foregroundColor(.secondary)
                            TextField("Enter amount", text: $budgetAmount)
                                .keyboardType(.decimalPad)
                                .font(.title)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        Button(action: setBudget) {
                            HStack {
                                Spacer()
                                Image(systemName: isEditing ? "checkmark.circle.fill" : "plus.circle.fill")
                                    .font(.title2)
                                Text(isEditing ? "Update Budget" : "Set Budget")
                                    .font(.headline)
                                Spacer()
                            }
                        }
                        .disabled(budgetAmount.isEmpty)
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Budget Tips
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Budget Tips")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            TipRow(icon: "chart.line.uptrend.xyaxis", title: "Track Spending", description: "Monitor your daily expenses to stay on track")
                            TipRow(icon: "target", title: "Set Realistic Goals", description: "Choose a budget that fits your income")
                            TipRow(icon: "calendar", title: "Review Monthly", description: "Check your spending patterns each month")
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("Budget")
            .onAppear {
                if let budget = viewModel.budget {
                    budgetAmount = String(format: "%.2f", budget.amount)
                    isEditing = true
                }
            }
            .alert("Budget", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func setBudget() {
        guard let amount = Double(budgetAmount), amount > 0 else {
            alertMessage = "Please enter a valid amount"
            showAlert = true
            return
        }
        
        viewModel.setBudget(amount: amount)
        isEditing = true
        alertMessage = isEditing ? "Budget updated successfully!" : "Budget set successfully!"
        showAlert = true
    }
}

struct BudgetStatusCard: View {
    let budget: Double
    let spent: Double
    let remaining: Double
    
    private var percentageUsed: Double {
        guard budget > 0 else { return 0 }
        return min(spent / budget, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Budget Used")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.0f%%", percentageUsed * 100))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(percentageUsed > 0.9 ? .red : .blue)
                }
                
                ProgressView(value: percentageUsed)
                    .tint(percentageUsed > 0.9 ? .red : .blue)
            }
            
            Divider()
            
            // Stats
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "$%.2f", spent))
                        .font(.headline)
                        .foregroundColor(spent > budget ? .red : .primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "$%.2f", remaining))
                        .font(.headline)
                        .foregroundColor(remaining >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

