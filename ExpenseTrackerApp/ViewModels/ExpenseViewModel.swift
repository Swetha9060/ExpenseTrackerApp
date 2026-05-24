import Foundation
internal import CoreData
import SwiftUI
import Combine

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var budget: Budget?
    @Published var selectedCategory: ExpenseCategory?
    @Published var selectedDate: Date?
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchExpenses()
        fetchBudget()
    }
    
    func fetchExpenses() {
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            expenses = try viewContext.fetch(request)
        } catch {
            print("Error fetching expenses: \(error)")
        }
    }
    
    func fetchBudget() {
        let request: NSFetchRequest<Budget> = Budget.fetchRequest()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        request.predicate = NSPredicate(format: "month == %d AND year == %d", currentMonth, currentYear)
        
        do {
            let budgets = try viewContext.fetch(request)
            budget = budgets.first
        } catch {
            print("Error fetching budget: \(error)")
        }
    }
    
    func addExpense(amount: Double, category: String, date: Date, note: String?) {
        let expense = Expense(context: viewContext)
        expense.id = UUID()
        expense.amount = amount
        expense.category = category
        expense.date = date
        expense.note = note
        expense.createdAt = Date()
        
        save()
        fetchExpenses()
    }
    
    func deleteExpense(_ expense: Expense) {
        viewContext.delete(expense)
        save()
        fetchExpenses()
    }
    
    func setBudget(amount: Double) {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        if let existingBudget = budget {
            existingBudget.amount = amount
        } else {
            let newBudget = Budget(context: viewContext)
            newBudget.id = UUID()
            newBudget.amount = amount
            newBudget.month = Int16(currentMonth)
            newBudget.year = Int16(currentYear)
            newBudget.createdAt = Date()
            budget = newBudget
        }
        
        save()
        fetchBudget()
    }
    
    func getFilteredExpenses() -> [Expense] {
        var filtered = expenses
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category.rawValue }
        }
        
        if let date = selectedDate {
            let calendar = Calendar.current
            filtered = filtered.filter { expense in
                calendar.isDate(expense.date ?? Date(), inSameDayAs: date)
            }
        }
        
        return filtered
    }
    
    func getTotalExpenses() -> Double {
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    func getRemainingBalance() -> Double {
        guard let budgetAmount = budget?.amount else { return 0 }
        return budgetAmount - getTotalExpenses()
    }
    
    func getCategoryBreakdown() -> [(category: String, amount: Double)] {
        let breakdown = Dictionary(grouping: expenses, by: { $0.category ?? "Uncategorized" })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
        
        return breakdown.map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
    
    private func save() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}


