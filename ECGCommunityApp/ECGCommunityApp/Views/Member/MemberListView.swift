import SwiftUI

struct MemberListView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var members: [User] = []
    @State private var isLoading = false
    @State private var selectedMember: User?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(members) { member in
                    Button(action: {
                        selectedMember = member
                    }) {
                        HStack(spacing: 15) {
                            if let avatarUrl = member.profile.avatarUrl {
                                AsyncImage(url: URL(string: avatarUrl)) { image in
                                    image.resizable()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(member.username)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("登録日: \(member.registeredAt, style: .date)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("メンバーリスト")
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
            .task {
                await loadMembers()
            }
            .sheet(item: $selectedMember) { member in
                MemberDetailView(member: member)
            }
        }
    }
    
    private func loadMembers() async {
        isLoading = true
        do {
            let response = try await APIService.shared.getMembers()
            members = response.users
        } catch {
            print("メンバーリスト取得エラー: \(error)")
        }
        isLoading = false
    }
}

struct MemberDetailView: View {
    @Environment(\.dismiss) var dismiss
    let member: User
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        if let avatarUrl = member.profile.avatarUrl {
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
                }
                
                Section("基本情報") {
                    HStack {
                        Text("ユーザー名")
                        Spacer()
                        Text(member.username)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("登録日")
                        Spacer()
                        Text(member.registeredAt, style: .date)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("プロフィール") {
                    if let nativeLang = member.profile.nativeLanguage {
                        HStack {
                            Text("母語")
                            Spacer()
                            Text(nativeLang)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let learningLangs = member.profile.learningLanguages, !learningLangs.isEmpty {
                        HStack {
                            Text("学習したい言語")
                            Spacer()
                            Text(learningLangs.joined(separator: ", "))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let country = member.profile.currentCountry {
                        HStack {
                            Text("現在いる国")
                            Spacer()
                            Text(country)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let status = member.profile.statusMessage {
                        VStack(alignment: .leading) {
                            Text("一言メッセージ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(status)
                        }
                    }
                    
                    if let bioText = member.profile.bio {
                        VStack(alignment: .leading) {
                            Text("自己紹介")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(bioText)
                        }
                    }
                    
                    if let insta = member.profile.instagram {
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
            .navigationTitle(member.username)
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
        }
    }
}

struct MemberListView_Previews: PreviewProvider {
    static var previews: some View {
        MemberListView()
            .environmentObject(AuthViewModel())
    }
}

