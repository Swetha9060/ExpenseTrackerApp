import SwiftUI
internal import CoreData

struct ExpenseHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ExpenseViewModel
    
    @State private var showingFilterSheet = false
    
    init() {
        _viewModel = StateObject(wrappedValue: ExpenseViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter bar
                if viewModel.selectedCategory != nil || viewModel.selectedDate != nil {
                    filterBar
                }
                
                // Expense list
                List {
                    ForEach(viewModel.getFilteredExpenses()) { expense in
                        ExpenseRowView(expense: expense)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteExpense(expense)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Expense History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilterSheet = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilterSheet) {
                FilterSheetView(viewModel: viewModel)
            }
            .refreshable {
                viewModel.fetchExpenses()
            }
        }
    }
    
    private var filterBar: some View {
        HStack {
            if let category = viewModel.selectedCategory {
                FilterChip(
                    label: category.rawValue,
                    icon: category.icon,
                    onTap: { viewModel.selectedCategory = nil }
                )
            }
            
            if let date = viewModel.selectedDate {
                FilterChip(
                    label: formatDate(date),
                    icon: "calendar",
                    onTap: { viewModel.selectedDate = nil }
                )
            }
            
            Spacer()
            
            Button("Clear All") {
                viewModel.selectedCategory = nil
                viewModel.selectedDate = nil
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 15) {
            // Category icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: categoryIcon)
                    .foregroundColor(categoryColor)
                    .font(.title2)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category ?? "Unknown")
                    .font(.headline)
                
                Text(formatDate(expense.date ?? Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let note = expense.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Amount
            Text(String(format: "$%.2f", expense.amount))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
    
    private var categoryIcon: String {
        ExpenseCategory(rawValue: expense.category ?? "other")?.icon ?? "ellipsis"
    }
    
    private var categoryColor: Color {
        let colorName = ExpenseCategory(rawValue: expense.category ?? "other")?.color ?? "gray"
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct FilterChip: View {
    let label: String
    let icon: String
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(label)
                .font(.caption)
            Image(systemName: "xmark.circle.fill")
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(20)
        .onTapGesture(perform: onTap)
    }
}

struct FilterSheetView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: ExpenseCategory?
    @State private var selectedDate: Date = Date()
    @State private var useDateFilter = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Filter by Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        Text("All Categories").tag(nil as ExpenseCategory?)
                        ForEach(ExpenseCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category as ExpenseCategory?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Filter by Date")) {
                    Toggle("Filter by specific date", isOn: $useDateFilter)
                    
                    if useDateFilter {
                        DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    }
                }
                
                Section {
                    Button(action: applyFilters) {
                        HStack {
                            Spacer()
                            Text("Apply Filters")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    
                    Button(role: .destructive, action: clearFilters) {
                        HStack {
                            Spacer()
                            Text("Clear All Filters")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Filter Expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            selectedCategory = viewModel.selectedCategory
            useDateFilter = viewModel.selectedDate != nil
            if let date = viewModel.selectedDate {
                selectedDate = date
            }
        }
    }
    
    private func applyFilters() {
        viewModel.selectedCategory = selectedCategory
        viewModel.selectedDate = useDateFilter ? selectedDate : nil
        dismiss()
    }
    
    private func clearFilters() {
        viewModel.selectedCategory = nil
        viewModel.selectedDate = nil
        dismiss()
    }
}

