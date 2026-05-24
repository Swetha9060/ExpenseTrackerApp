import SwiftUI
internal import CoreData

struct AddExpenseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ExpenseViewModel
    
    @State private var amount: String = ""
    @State private var selectedCategory: ExpenseCategory = .food
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init() {
        _viewModel = StateObject(wrappedValue: ExpenseViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    // Amount
                    HStack {
                        Text("Rs")
                            .font(.title)
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title)
                    }
                    
                    // Category
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    
                    // Date
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    // Note
                    TextField("Note (optional)", text: $note)
                }
                
                Section {
                    Button(action: addExpense) {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Add Expense")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(amount.isEmpty)
                }
            }
            .navigationTitle("Add Expense")
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func addExpense() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            alertMessage = "Please enter a valid amount"
            showAlert = true
            return
        }
        
        viewModel.addExpense(
            amount: amountValue,
            category: selectedCategory.rawValue,
            date: date,
            note: note.isEmpty ? nil : note
        )
        
        // Reset form
        amount = ""
        note = ""
        date = Date()
        
        alertMessage = "Expense added successfully!"
        showAlert = true
    }
}

#Preview {
   AddExpenseView()
}
