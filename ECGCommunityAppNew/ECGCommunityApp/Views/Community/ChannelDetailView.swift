import SwiftUI

struct ChannelDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var communityViewModel: CommunityViewModel
    let channel: Channel
    
    @State private var showNewPost = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(communityViewModel.posts) { post in
                            PostCardView(post: post, channelId: channel.id)
                                .environmentObject(authViewModel)
                                .environmentObject(communityViewModel)
                        }
                    }
                    .padding()
                }
                
                // 投稿ボタン
                if channel.canPost == true {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showNewPost = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle(channel.name)
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
            .task {
                await communityViewModel.loadPosts(for: channel.id)
            }
            .sheet(isPresented: $showNewPost) {
                PostCreationView(channel: channel)
                    .environmentObject(authViewModel)
                    .environmentObject(communityViewModel)
            }
        }
    }
}

struct PostCardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var communityViewModel: CommunityViewModel
    let post: Post
    let channelId: String
    
    @State private var showComments = false
    @State private var commentText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 投稿者情報
            HStack {
                if let avatarUrl = post.author.profile?.avatarUrl {
                    AsyncImage(url: URL(string: avatarUrl)) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading) {
                    Text(post.author.username)
                        .font(.headline)
                    Text(post.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // 投稿内容
            Text(post.content)
                .font(.body)
            
            // 画像
            if !post.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(post.images, id: \.self) { imageUrl in
                            AsyncImage(url: URL(string: imageUrl)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 200, height: 200)
                            .clipped()
                            .cornerRadius(10)
                        }
                    }
                }
            }
            
            // アクションボタン
            HStack(spacing: 20) {
                Button(action: {
                    Task {
                        await communityViewModel.likePost(post.id, channelId: channelId)
                    }
                }) {
                    HStack {
                        Image(systemName: isLikedByCurrentUser ? "heart.fill" : "heart")
                            .foregroundColor(isLikedByCurrentUser ? .red : .gray)
                        Text("\(post.likes.count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {
                    showComments.toggle()
                }) {
                    HStack {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                        Text("\(post.comments.count)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // コメントセクション
            if showComments {
                VStack(alignment: .leading, spacing: 10) {
                    Divider()
                    
                    ForEach(post.comments) { comment in
                        HStack(alignment: .top) {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading) {
                                Text(comment.user.username)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(comment.content)
                                    .font(.caption)
                            }
                        }
                    }
                    
                    HStack {
                        TextField("コメントを追加...", text: $commentText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("送信") {
                            Task {
                                await communityViewModel.addComment(postId: post.id, content: commentText, channelId: channelId)
                                commentText = ""
                            }
                        }
                        .disabled(commentText.isEmpty)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    var isLikedByCurrentUser: Bool {
        guard let currentUserId = authViewModel.currentUser?.id else { return false }
        return post.likes.contains { $0.id == currentUserId }
    }
}

struct NewPostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var communityViewModel: CommunityViewModel
    let channelId: String
    
    @State private var content = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $content)
                    .frame(minHeight: 200)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding()
                
                Spacer()
            }
            .navigationTitle("新規投稿")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    dismiss()
                },
                trailing: Button("投稿") {
                    Task {
                        await communityViewModel.createPost(channelId: channelId, content: content)
                        dismiss()
                    }
                }
                .disabled(content.isEmpty)
            )
        }
    }
}

