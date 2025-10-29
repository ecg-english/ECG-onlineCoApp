import SwiftUI

struct ChannelManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ChannelManagementViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("読み込み中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.channels) { channel in
                            ChannelRowView(channel: channel) {
                                viewModel.selectedChannel = channel
                                viewModel.showEditSheet = true
                            } onDelete: {
                                viewModel.showDeleteAlert = true
                                viewModel.channelToDelete = channel
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.loadChannels()
                    }
                }
            }
            .navigationTitle("チャンネル管理")
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
                ChannelEditView(isEditing: false, categories: viewModel.categories, roles: viewModel.roles) { channelData in
                    await viewModel.createChannel(channelData)
                }
            }
            .sheet(isPresented: $viewModel.showEditSheet) {
                if let channel = viewModel.selectedChannel {
                    ChannelEditView(isEditing: true, channel: channel, categories: viewModel.categories, roles: viewModel.roles) { updatedChannelData in
                        await viewModel.updateChannel(updatedChannelData)
                    }
                }
            }
            .alert("チャンネルを削除", isPresented: $viewModel.showDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    if let channel = viewModel.channelToDelete {
                        Task {
                            await viewModel.deleteChannel(channel)
                        }
                    }
                }
            } message: {
                Text("このチャンネルを削除しますか？この操作は取り消せません。")
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
                await viewModel.loadData()
            }
        }
    }
}

struct ChannelRowView: View {
    let channel: Channel
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(channel.name)
                    .font(.headline)
                if !channel.description.isEmpty {
                    Text(channel.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text("カテゴリ: \(channel.category.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("順序: \(channel.order)")
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

struct ChannelEditView: View {
    @Environment(\.dismiss) private var dismiss
    
    let isEditing: Bool
    let channel: Channel?
    let categories: [Category]
    let roles: [Role]
    let onSave: (ChannelData) async -> Void
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedCategoryId: String = ""
    @State private var selectedViewPermissions: Set<String> = []
    @State private var selectedPostPermissions: Set<String> = []
    @State private var order: Int = 0
    @State private var isLoading: Bool = false
    
    init(isEditing: Bool, channel: Channel? = nil, categories: [Category], roles: [Role], onSave: @escaping (ChannelData) async -> Void) {
        self.isEditing = isEditing
        self.channel = channel
        self.categories = categories
        self.roles = roles
        self.onSave = onSave
        
        if let channel = channel {
            self._name = State(initialValue: channel.name)
            self._description = State(initialValue: channel.description)
            self._selectedCategoryId = State(initialValue: channel.category.id)
            self._selectedViewPermissions = State(initialValue: Set(channel.viewPermissions.map { $0.id }))
            self._selectedPostPermissions = State(initialValue: Set(channel.postPermissions.map { $0.id }))
            self._order = State(initialValue: channel.order)
        } else if !categories.isEmpty {
            self._selectedCategoryId = State(initialValue: categories.first?.id ?? "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本情報") {
                    TextField("チャンネル名", text: $name)
                    TextField("説明（任意）", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("カテゴリ", selection: $selectedCategoryId) {
                        ForEach(categories) { category in
                            Text(category.name).tag(category.id)
                        }
                    }
                }
                
                Section("閲覧権限") {
                    ForEach(roles) { role in
                        HStack {
                            Text(role.name)
                            Spacer()
                            if selectedViewPermissions.contains(role.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedViewPermissions.contains(role.id) {
                                selectedViewPermissions.remove(role.id)
                            } else {
                                selectedViewPermissions.insert(role.id)
                            }
                        }
                    }
                }
                
                Section("投稿権限") {
                    ForEach(roles) { role in
                        HStack {
                            Text(role.name)
                            Spacer()
                            if selectedPostPermissions.contains(role.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedPostPermissions.contains(role.id) {
                                selectedPostPermissions.remove(role.id)
                            } else {
                                selectedPostPermissions.insert(role.id)
                            }
                        }
                    }
                }
                
                Section("表示設定") {
                    Stepper("表示順序: \(order)", value: $order, in: 0...999)
                }
            }
            .navigationTitle(isEditing ? "チャンネル編集" : "チャンネル作成")
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
                            let channelData = ChannelData(
                                name: name,
                                description: description,
                                categoryId: selectedCategoryId,
                                viewPermissions: Array(selectedViewPermissions),
                                postPermissions: Array(selectedPostPermissions),
                                order: order
                            )
                            await onSave(channelData)
                            isLoading = false
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || selectedCategoryId.isEmpty || isLoading)
                }
            }
        }
    }
}

struct ChannelData {
    let name: String
    let description: String
    let categoryId: String
    let viewPermissions: [String]
    let postPermissions: [String]
    let order: Int
}

@MainActor
class ChannelManagementViewModel: ObservableObject {
    @Published var channels: [Channel] = []
    @Published var categories: [Category] = []
    @Published var roles: [Role] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showCreateSheet: Bool = false
    @Published var showEditSheet: Bool = false
    @Published var showDeleteAlert: Bool = false
    @Published var selectedChannel: Channel?
    @Published var channelToDelete: Channel?
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let channelsResponse = APIService.shared.getChannels()
            async let categoriesResponse = APIService.shared.getCategories()
            async let rolesResponse = APIService.shared.getRoles()
            
            let (channelsResult, categoriesResult, rolesResult) = await (channelsResponse, categoriesResponse, rolesResponse)
            
            channels = channelsResult.channels
            categories = categoriesResult.categories
            roles = rolesResult.roles
            
            // カテゴリ順でソート
            channels.sort { channel1, channel2 in
                if channel1.category.order != channel2.category.order {
                    return channel1.category.order < channel2.category.order
                }
                return channel1.order < channel2.order
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadChannels() async {
        do {
            let response = try await APIService.shared.getChannels()
            channels = response.channels
            channels.sort { channel1, channel2 in
                if channel1.category.order != channel2.category.order {
                    return channel1.category.order < channel2.category.order
                }
                return channel1.order < channel2.order
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func createChannel(_ channelData: ChannelData) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.shared.createChannel(
                name: channelData.name,
                description: channelData.description,
                categoryId: channelData.categoryId,
                viewPermissions: channelData.viewPermissions,
                postPermissions: channelData.postPermissions,
                order: channelData.order
            )
            channels.append(response.channel)
            channels.sort { channel1, channel2 in
                if channel1.category.order != channel2.category.order {
                    return channel1.category.order < channel2.category.order
                }
                return channel1.order < channel2.order
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateChannel(_ channelData: ChannelData) async {
        guard let channel = selectedChannel else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.shared.editChannel(
                channelId: channel.id,
                name: channelData.name,
                description: channelData.description,
                categoryId: channelData.categoryId,
                viewPermissions: channelData.viewPermissions,
                postPermissions: channelData.postPermissions,
                order: channelData.order
            )
            
            if let index = channels.firstIndex(where: { $0.id == channel.id }) {
                channels[index] = response.channel
                channels.sort { channel1, channel2 in
                    if channel1.category.order != channel2.category.order {
                        return channel1.category.order < channel2.category.order
                    }
                    return channel1.order < channel2.order
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteChannel(_ channel: Channel) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await APIService.shared.deleteChannel(channelId: channel.id)
            channels.removeAll { $0.id == channel.id }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    ChannelManagementView()
        .environmentObject(AuthViewModel())
}
