import SwiftUI

struct PostCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var communityViewModel: CommunityViewModel
    
    @State private var postContent = ""
    @State private var selectedImages: [UIImage] = []
    @State private var isShowingImagePicker = false
    @State private var replyPermission = ReplyPermission.everyone
    
    let channel: Channel
    
    enum ReplyPermission: String, CaseIterable {
        case everyone = "everyone"
        case mentioned = "mentioned"
        
        var displayText: String {
            switch self {
            case .everyone:
                return "誰でも返信できます"
            case .mentioned:
                return "あなたが@ポストしたアカウントのみが返信できます"
            }
        }
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
                                
                                // 返信権限設定
                                HStack(spacing: 8) {
                                    Image(systemName: "at")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    
                                    Text("@ \(replyPermission.displayText)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // 選択された画像
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
                        // AA (テキストフォーマット)
                        Button(action: {}) {
                            Text("AA")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        // 画像
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        // ポール
                        Button(action: {}) {
                            Image(systemName: "chart.bar")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        
                        // LIVE
                        Button(action: {}) {
                            Text("LIVE")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        // GIF
                        Button(action: {}) {
                            Text("GIF")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // 文字数カウンター
                        Text("\(postContent.count)/280")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // 追加オプション
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
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
                    HStack(spacing: 12) {
                        Button("下書き") {
                            // 下書き保存
                        }
                        .foregroundColor(.blue)
                        
                        Button("ポスト") {
                            Task {
                                await createPost()
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
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
    }
    
    private func createPost() async {
        // 画像をBase64に変換
        let imageStrings = selectedImages.compactMap { image in
            image.jpegData(compressionQuality: 0.8)?.base64EncodedString()
        }
        
        await communityViewModel.createPost(
            channelId: channel.id,
            content: postContent,
            images: imageStrings
        )
        
        dismiss()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImages.append(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct PostCreationView_Previews: PreviewProvider {
    static var previews: some View {
        PostCreationView(channel: Channel(
            id: "1",
            name: "テストチャンネル",
            description: "テスト用チャンネル",
            category: Category(id: "1", name: "テスト", description: "", order: 1),
            viewPermissions: [],
            postPermissions: [],
            order: 1,
            canPost: true
        ))
        .environmentObject(AuthViewModel())
        .environmentObject(CommunityViewModel())
    }
}
