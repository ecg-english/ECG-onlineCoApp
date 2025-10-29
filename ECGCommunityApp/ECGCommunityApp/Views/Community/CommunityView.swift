import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var communityViewModel: CommunityViewModel
    @State private var expandedCategories: Set<String> = []
    @State private var showingPostCreation = false
    @State private var selectedChannelForPost: Channel?
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(communityViewModel.categories) { category in
                            CategoryAccordionView(
                                category: category,
                                isExpanded: expandedCategories.contains(category.id),
                                channels: communityViewModel.channelsForCategory(category.id),
                                onToggle: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if expandedCategories.contains(category.id) {
                                            expandedCategories.remove(category.id)
                                        } else {
                                            expandedCategories.insert(category.id)
                                        }
                                    }
                                },
                                onSelectChannel: { channel in
                                    communityViewModel.selectedChannel = channel
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 100) // ヘッダー分のスペースを増やす
                    .padding(.bottom, 100) // フローティングボタン分のスペース
                }
                
                // フローティングアクションボタン
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // 「雑談」カテゴリの「日記 - Diary」チャンネルを投稿先に設定
                            if let diaryChannel = findDiaryChannel() {
                                selectedChannelForPost = diaryChannel
                                showingPostCreation = true
                            } else {
                                // チャンネルが見つからない場合のフォールバック
                                print("Error: '雑談'カテゴリの'日記 - Diary'チャンネルが見つかりませんでした。")
                                if let firstChannel = communityViewModel.channels.first {
                                    selectedChannelForPost = firstChannel
                                    showingPostCreation = true
                                }
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .task {
                await communityViewModel.loadChannels()
            }
            .sheet(item: $communityViewModel.selectedChannel) { channel in
                ChannelDetailView(channel: channel)
                    .environmentObject(authViewModel)
                    .environmentObject(communityViewModel)
            }
            .sheet(isPresented: $showingPostCreation) {
                if let channel = selectedChannelForPost {
                    PostCreationView(channel: channel)
                        .environmentObject(authViewModel)
                        .environmentObject(communityViewModel)
                }
            }
        }
    }
    
    // 日記チャンネルを見つけるヘルパー関数
    private func findDiaryChannel() -> Channel? {
        guard let talkCategory = communityViewModel.categories.first(where: { $0.name == "雑談" }) else {
            return nil
        }
        return communityViewModel.channels.first(where: { $0.category.id == talkCategory.id && $0.name == "日記 - Diary" })
    }
}

struct CategoryAccordionView: View {
    let category: Category
    let isExpanded: Bool
    let channels: [Channel]
    let onToggle: () -> Void
    let onSelectChannel: (Channel) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // カテゴリヘッダー
            Button(action: onToggle) {
                HStack {
                    Text(category.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(channels.count) チャンネル")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(12, corners: isExpanded ? [.topLeft, .topRight] : [.allCorners])
            }
            .buttonStyle(PlainButtonStyle())
            
            // チャンネルリスト
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(channels.enumerated()), id: \.element.id) { index, channel in
                        ChannelCardView(
                            channel: channel,
                            isLast: index == channels.count - 1,
                            onTap: {
                                onSelectChannel(channel)
                            }
                        )
                    }
                }
                .background(Color.white)
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            }
        }
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct ChannelCardView: View {
    let channel: Channel
    let isLast: Bool
    let onTap: () -> Void
    
    // 管理者専用チャンネルかどうかを判定
    private func isAdminOnlyChannel(_ channel: Channel) -> Bool {
        // postPermissionsにAdminロールのみが含まれている場合は管理者専用
        return channel.postPermissions.count == 1 &&
               channel.postPermissions.first?.name == "Admin"
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(channel.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // タグ
                    Text(isAdminOnlyChannel(channel) ? "講師投稿" : "一般投稿")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isAdminOnlyChannel(channel) ? Color.blue : Color.green)
                        .cornerRadius(8)
                }
                
                if !channel.description.isEmpty {
                    Text(channel.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
        
        if !isLast {
            Divider()
                .padding(.horizontal, 20)
        }
    }
}

// 角丸の拡張
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
            .environmentObject(AuthViewModel())
            .environmentObject(CommunityViewModel())
    }
}

