import SwiftUI

struct AdminPanelView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section("ユーザー管理") {
                    NavigationLink("ユーザー一覧") {
                        AdminUserListView()
                    }
                    
                    NavigationLink("ロール管理") {
                        AdminRoleManagementView()
                    }
                }
                
                Section("コンテンツ管理") {
                    NavigationLink("カテゴリ管理") {
                        AdminCategoryManagementView()
                    }
                    
                    NavigationLink("チャンネル管理") {
                        AdminChannelManagementView()
                    }
                    
                    NavigationLink("イベント管理") {
                        AdminEventManagementView()
                    }
                    
                    NavigationLink("学習コンテンツ管理") {
                        AdminLearningManagementView()
                    }
                }
                
                Section("ショップ管理") {
                    NavigationLink("ショップアイテム管理") {
                        AdminShopManagementView()
                    }
                }
            }
            .navigationTitle("管理者画面")
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
        }
    }
}

struct AdminUserListView: View {
    @State private var users: [User] = []
    @State private var isLoading = false
    @State private var selectedUser: User?
    
    var body: some View {
        List {
            ForEach(users) { user in
                Button(action: {
                    selectedUser = user
                }) {
                    VStack(alignment: .leading) {
                        Text(user.username)
                            .font(.headline)
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("ロール: \(user.roles.map { $0.name }.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("ユーザー一覧")
        .task {
            await loadUsers()
        }
        .sheet(item: $selectedUser) { user in
            AdminUserDetailView(user: user) {
                Task {
                    await loadUsers()
                }
            }
        }
    }
    
    private func loadUsers() async {
        isLoading = true
        do {
            let response = try await APIService.shared.getAllUsers()
            users = response.users
        } catch {
            print("ユーザー一覧取得エラー: \(error)")
        }
        isLoading = false
    }
}

struct AdminUserDetailView: View {
    @Environment(\.dismiss) var dismiss
    let user: User
    let onUpdate: () -> Void
    
    @State private var availableRoles: [Role] = []
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("ユーザー情報") {
                    Text("ユーザー名: \(user.username)")
                    Text("メール: \(user.email)")
                    Text("Mile: \(user.miles)")
                    Text("登録日: \(user.registeredAt, style: .date)")
                }
                
                Section("ロール") {
                    ForEach(availableRoles) { role in
                        HStack {
                            Text(role.name)
                            Spacer()
                            if user.roles.contains(where: { $0.id == role.id }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // TODO: ロール付与/剥奪API呼び出し
                        }
                    }
                }
                
                Section {
                    Button("ユーザーを削除", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle(user.username)
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
            .task {
                await loadRoles()
            }
            .confirmationDialog("ユーザー削除", isPresented: $showDeleteConfirmation) {
                Button("削除", role: .destructive) {
                    // TODO: ユーザー削除API呼び出し
                    onUpdate()
                    dismiss()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("このユーザーを削除しますか?")
            }
        }
    }
    
    private func loadRoles() async {
        do {
            let response = try await APIService.shared.request(endpoint: "/roles") as RolesResponse
            availableRoles = response.roles
        } catch {
            print("ロール一覧取得エラー: \(error)")
        }
    }
}

struct RolesResponse: Codable {
    let roles: [Role]
}

struct AdminRoleManagementView: View {
    @State private var roles: [Role] = []
    @State private var showNewRole = false
    
    var body: some View {
        List {
            ForEach(roles) { role in
                VStack(alignment: .leading) {
                    Text(role.name)
                        .font(.headline)
                    Text(role.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("ロール管理")
        .navigationBarItems(trailing: Button(action: {
            showNewRole = true
        }) {
            Image(systemName: "plus")
        })
        .task {
            await loadRoles()
        }
        .sheet(isPresented: $showNewRole) {
            NewRoleView {
                Task {
                    await loadRoles()
                }
            }
        }
    }
    
    private func loadRoles() async {
        do {
            let response = try await APIService.shared.request(endpoint: "/roles") as RolesResponse
            roles = response.roles
        } catch {
            print("ロール一覧取得エラー: \(error)")
        }
    }
}

struct NewRoleView: View {
    @Environment(\.dismiss) var dismiss
    let onComplete: () -> Void
    
    @State private var name = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("ロール名", text: $name)
                TextField("説明", text: $description)
            }
            .navigationTitle("新しいロール")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    dismiss()
                },
                trailing: Button("作成") {
                    // TODO: ロール作成API呼び出し
                    onComplete()
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

struct AdminCategoryManagementView: View {
    var body: some View {
        Text("カテゴリ管理")
            .navigationTitle("カテゴリ管理")
    }
}

struct AdminChannelManagementView: View {
    var body: some View {
        Text("チャンネル管理")
            .navigationTitle("チャンネル管理")
    }
}

struct AdminEventManagementView: View {
    var body: some View {
        Text("イベント管理")
            .navigationTitle("イベント管理")
    }
}

struct AdminLearningManagementView: View {
    var body: some View {
        Text("学習コンテンツ管理")
            .navigationTitle("学習コンテンツ管理")
    }
}

struct AdminShopManagementView: View {
    var body: some View {
        Text("ショップアイテム管理")
            .navigationTitle("ショップアイテム管理")
    }
}

struct AdminPanelView_Previews: PreviewProvider {
    static var previews: some View {
        AdminPanelView()
            .environmentObject(AuthViewModel())
    }
}

