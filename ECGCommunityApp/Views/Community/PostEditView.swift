import SwiftUI
import PhotosUI

struct PostEditView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var communityViewModel: CommunityViewModel
    
    @State private var postContent: String
    @State private var selectedImages: [UIImage] = []
    @State private var isShowingImagePicker = false
    
    let post: Post
    let channelId: String
    
    init(post: Post, channelId: String) {
        self.post = post
        self.channelId = channelId
        self._postContent = State(initialValue: post.content)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // メインコンテンツ
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // ユーザー情報とテキスト入力
                        HStack(alignment: .top, spacing: 12) {
                            // ユーザーアバター
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(authViewModel.currentUser?.username.prefix(1).uppercased() ?? "U")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                )
                            
                            // テキスト入力エリア
                            VStack(alignment: .leading, spacing: 12) {
                                TextField("いまどうしてる？", text: $postContent, axis: .vertical)
                                    .font(.body)
                                    .lineLimit(1...10)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // 既存の画像
                        if !post.images.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("既存の画像")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(post.images, id: \.self) { imageUrl in
                                            AsyncImage(url: URL(string: imageUrl)) { image in
                                                image.resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.3))
                                            }
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        
                        // 選択された新しい画像
                        if !selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(8)
                                            .overlay(
                                                Button(action: {
                                                    selectedImages.remove(at: index)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                        .background(Color.black.opacity(0.6))
                                                        .clipShape(Circle())
                                                }
                                                .padding(4),
                                                alignment: .topTrailing
                                            )
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        Spacer(minLength: 200) // キーボード分のスペース
                    }
                }
                
                // ツールバー
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(spacing: 20) {
                        // 画像
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // 文字数カウンター
                        Text("\(postContent.count)/280")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        Task {
                            await editPost()
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .disabled(postContent.isEmpty)
                }
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
    }
    
    private func editPost() async {
        // 新しい画像をBase64に変換
        let imageStrings = selectedImages.compactMap { image in
            image.jpegData(compressionQuality: 0.8)?.base64EncodedString()
        }
        
        await communityViewModel.editPost(
            postId: post.id,
            content: postContent,
            images: imageStrings,
            channelId: channelId
        )
        
        dismiss()
    }
}

struct PostEditView_Previews: PreviewProvider {
    static var previews: some View {
        PostEditView(
            post: Post(
                id: "1",
                channel: "1",
                author: User(
                    id: "1",
                    email: "test@example.com",
                    username: "TestUser",
                    roles: [],
                    miles: 0,
                    registeredAt: "",
                    createdAt: "",
                    updatedAt: ""
                ),
                content: "テスト投稿",
                images: [],
                likes: [],
                comments: [],
                createdAt: "",
                updatedAt: ""
            ),
            channelId: "1"
        )
        .environmentObject(AuthViewModel())
        .environmentObject(CommunityViewModel())
    }
}
