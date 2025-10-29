import SwiftUI

struct CategoryManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = CategoryManagementViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.categories) { category in
                            CategoryRowView(category: category) {
                                viewModel.selectedCategory = category
                                viewModel.showEditSheet = true
                            } onDelete: {
                                viewModel.showDeleteAlert = true
                                viewModel.categoryToDelete = category
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.loadCategories()
                    }
                }
            }
            .navigationTitle("カテゴリ管理")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showCreateSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreateSheet) {
                CategoryEditView(isEditing: false) { category in
                    await viewModel.createCategory(category)
                }
            }
            .sheet(isPresented: $viewModel.showEditSheet) {
                if let category = viewModel.selectedCategory {
                    CategoryEditView(isEditing: true, category: category) { updatedCategory in
                        await viewModel.updateCategory(updatedCategory)
                    }
                }
            }
            .alert("カテゴリを削除", isPresented: $viewModel.showDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    if let category = viewModel.categoryToDelete {
                        Task {
                            await viewModel.deleteCategory(category)
                        }
                    }
                }
            } message: {
                Text("このカテゴリを削除しますか？この操作は取り消せません。")
            }
            .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear {
            Task {
                await viewModel.loadCategories()
            }
        }
    }
}

struct CategoryRowView: View {
    let category: Category
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.headline)
                if !category.description.isEmpty {
                    Text(category.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text("順序: \(category.order)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Menu {
                Button("編集", action: onEdit)
                Button("削除", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
                    .padding(8)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CategoryEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    let isEditing: Bool
    let category: Category?
    let onSave: (CategoryData) async -> Void
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var order: Int = 0
    @State private var isLoading: Bool = false
    
    init(isEditing: Bool, category: Category? = nil, onSave: @escaping (CategoryData) async -> Void) {
        self.isEditing = isEditing
        self.category = category
        self.onSave = onSave
        
        if let category = category {
            self._name = State(initialValue: category.name)
            self._description = State(initialValue: category.description)
            self._order = State(initialValue: category.order)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本情報") {
                    TextField("カテゴリ名", text: $name)
                    TextField("説明（任意）", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("表示設定") {
                    Stepper("表示順序: \(order)", value: $order, in: 0...999)
                }
            }
            .navigationTitle(isEditing ? "カテゴリ編集" : "カテゴリ作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        Task {
                            isLoading = true
                            let categoryData = CategoryData(
                                name: name,
                                description: description,
                                order: order
                            )
                            await onSave(categoryData)
                            isLoading = false
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || isLoading)
                }
            }
        }
    }
}

struct CategoryData {
    let name: String
    let description: String
    let order: Int
}

@MainActor
class CategoryManagementViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showCreateSheet: Bool = false
    @Published var showEditSheet: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var selectedCategory: Category?
    @Published var categoryToDelete: Category?
    
    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.shared.getCategories()
            categories = response.categories
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func createCategory(_ categoryData: CategoryData) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.shared.createCategory(
                name: categoryData.name,
                description: categoryData.description,
                order: categoryData.order
            )
            categories.append(response.category)
            categories.sort { $0.order < $1.order }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateCategory(_ categoryData: CategoryData) async {
        guard let category = selectedCategory else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.shared.editCategory(
                categoryId: category.id,
                name: categoryData.name,
                description: categoryData.description,
                order: categoryData.order
            )
            
            if let index = categories.firstIndex(where: { $0.id == category.id }) {
                categories[index] = response.category
                categories.sort { $0.order < $1.order }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteCategory(_ category: Category) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await APIService.shared.deleteCategory(categoryId: category.id)
            categories.removeAll { $0.id == category.id }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    CategoryManagementView()
        .environmentObject(AuthViewModel())
}
