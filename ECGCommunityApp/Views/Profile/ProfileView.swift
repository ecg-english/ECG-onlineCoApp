import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditing = false
    @State private var username: String = ""
    @State private var nativeLanguage: String = ""
    @State private var learningLanguages: String = ""
    @State private var currentCountry: String = ""
    @State private var statusMessage: String = ""
    @State private var bio: String = ""
    @State private var instagram: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        if let avatarUrl = authViewModel.currentUser?.profile.avatarUrl {
                            AsyncImage(url: URL(string: avatarUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    
                    if isEditing {
                        Button("アイコン画像を変更") {
                            // TODO: 画像選択実装
                        }
                    }
                }
                
                Section("基本情報") {
                    if isEditing {
                        TextField("ユーザー名", text: $username)
                    } else {
                        HStack {
                            Text("ユーザー名")
                            Spacer()
                            Text(authViewModel.currentUser?.username ?? "")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("メールアドレス")
                        Spacer()
                        Text(authViewModel.currentUser?.email ?? "")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("ロール")
                        Spacer()
                        Text(authViewModel.currentUser?.roles.map { $0.name }.joined(separator: ", ") ?? "")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("プロフィール") {
                    if isEditing {
                        TextField("母語", text: $nativeLanguage)
                        TextField("学習したい言語（カンマ区切り）", text: $learningLanguages)
                        TextField("現在いる国", text: $currentCountry)
                        TextField("一言メッセージ", text: $statusMessage)
                        TextEditor(text: $bio)
                            .frame(minHeight: 100)
                        TextField("Instagram", text: $instagram)
                    } else {
                        if let nativeLang = authViewModel.currentUser?.profile.nativeLanguage {
                            HStack {
                                Text("母語")
                                Spacer()
                                Text(nativeLang)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let learningLangs = authViewModel.currentUser?.profile.learningLanguages, !learningLangs.isEmpty {
                            HStack {
                                Text("学習したい言語")
                                Spacer()
                                Text(learningLangs.joined(separator: ", "))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let country = authViewModel.currentUser?.profile.currentCountry {
                            HStack {
                                Text("現在いる国")
                                Spacer()
                                Text(country)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let status = authViewModel.currentUser?.profile.statusMessage {
                            VStack(alignment: .leading) {
                                Text("一言メッセージ")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(status)
                            }
                        }
                        
                        if let bioText = authViewModel.currentUser?.profile.bio {
                            VStack(alignment: .leading) {
                                Text("自己紹介")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(bioText)
                            }
                        }
                        
                        if let insta = authViewModel.currentUser?.profile.instagram {
                            Link(destination: URL(string: "https://instagram.com/\(insta)")!) {
                                HStack {
                                    Image(systemName: "camera")
                                    Text("Instagram")
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("プロフィール")
            .navigationBarItems(
                leading: Button("閉じる") {
                    dismiss()
                },
                trailing: Button(isEditing ? "保存" : "編集") {
                    if isEditing {
                        saveProfile()
                    } else {
                        loadProfileForEditing()
                        isEditing = true
                    }
                }
            )
        }
    }
    
    private func loadProfileForEditing() {
        username = authViewModel.currentUser?.username ?? ""
        nativeLanguage = authViewModel.currentUser?.profile.nativeLanguage ?? ""
        learningLanguages = authViewModel.currentUser?.profile.learningLanguages?.joined(separator: ", ") ?? ""
        currentCountry = authViewModel.currentUser?.profile.currentCountry ?? ""
        statusMessage = authViewModel.currentUser?.profile.statusMessage ?? ""
        bio = authViewModel.currentUser?.profile.bio ?? ""
        instagram = authViewModel.currentUser?.profile.instagram ?? ""
    }
    
    private func saveProfile() {
        let profile = UserProfile(
            avatarUrl: authViewModel.currentUser?.profile.avatarUrl,
            nativeLanguage: nativeLanguage.isEmpty ? nil : nativeLanguage,
            learningLanguages: learningLanguages.isEmpty ? nil : learningLanguages.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            currentCountry: currentCountry.isEmpty ? nil : currentCountry,
            statusMessage: statusMessage.isEmpty ? nil : statusMessage,
            bio: bio.isEmpty ? nil : bio,
            instagram: instagram.isEmpty ? nil : instagram
        )
        
        Task {
            await authViewModel.updateProfile(username: username.isEmpty ? nil : username, profile: profile)
            isEditing = false
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}

