import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogoutConfirmation = false
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            List {
                Section("通知設定") {
                    NavigationLink("プッシュ通知設定") {
                        NotificationSettingsView()
                            .environmentObject(authViewModel)
                    }
                }
                
                Section("サポート") {
                    Link(destination: URL(string: "mailto:ecg_english@nauticalmile.jp")!) {
                        Label("お問い合わせ", systemImage: "envelope")
                    }
                    
                    NavigationLink("よくある質問") {
                        FAQView()
                    }
                    
                    NavigationLink("利用規約") {
                        TermsView()
                    }
                    
                    NavigationLink("プライバシーポリシー") {
                        PrivacyPolicyView()
                    }
                }
                
                Section("アカウント") {
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        Text("ログアウト")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("アカウント削除")
                            .foregroundColor(.red)
                    }
                }
                
                Section("アプリ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, 60) // ヘッダー分のスペース
            .confirmationDialog("ログアウト", isPresented: $showLogoutConfirmation) {
                Button("ログアウト", role: .destructive) {
                    authViewModel.logout()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("ログアウトしますか?")
            }
            .confirmationDialog("アカウント削除", isPresented: $showDeleteConfirmation) {
                Button("削除", role: .destructive) {
                    // TODO: アカウント削除API呼び出し
                    authViewModel.logout()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("アカウントを削除すると、全てのデータが失われます。本当に削除しますか?")
            }
        }
    }
}

struct NotificationSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var eventReminders = true
    @State private var newPosts = true
    @State private var newLearningContent = true
    
    var body: some View {
        Form {
            Section {
                Toggle("イベントリマインダー", isOn: $eventReminders)
                Toggle("新しい投稿", isOn: $newPosts)
                Toggle("新しい学習コンテンツ", isOn: $newLearningContent)
            } header: {
                Text("プッシュ通知")
            } footer: {
                Text("イベントの前日20時と当日9時に通知が届きます")
            }
        }
        .navigationTitle("通知設定")
        .onAppear {
            if let settings = authViewModel.currentUser?.pushNotificationSettings {
                eventReminders = settings.eventReminders
                newPosts = settings.newPosts
                newLearningContent = settings.newLearningContent
            }
        }
    }
}

struct FAQView: View {
    let faqs = [
        ("ECG Communityとは?", "ECGコミュニティメンバー向けの交流・学習プラットフォームです。"),
        ("Mileとは?", "アプリ内で使用できるポイントシステムです。学習コンテンツの完了などで獲得できます。"),
        ("メンバーになるには?", "管理者にお問い合わせください。")
    ]
    
    var body: some View {
        List {
            ForEach(faqs, id: \.0) { faq in
                VStack(alignment: .leading, spacing: 10) {
                    Text(faq.0)
                        .font(.headline)
                    Text(faq.1)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("よくある質問")
    }
}

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("利用規約")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("""
                第1条（適用）
                本規約は、本アプリの利用に関する条件を定めるものです。
                
                第2条（利用登録）
                利用者は、本規約に同意の上、利用登録を行うものとします。
                
                第3条（禁止事項）
                利用者は、以下の行為をしてはなりません。
                - 法令または公序良俗に違反する行為
                - 犯罪行為に関連する行為
                - 他の利用者または第三者の権利を侵害する行為
                
                第4条（免責事項）
                当社は、本サービスに関して利用者が被った損害について、一切の責任を負いません。
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("利用規約")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("プライバシーポリシー")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("""
                1. 収集する情報
                当社は、以下の情報を収集します。
                - ユーザー登録情報（メールアドレス、ユーザー名など）
                - プロフィール情報
                - 利用履歴
                
                2. 情報の利用目的
                収集した情報は、以下の目的で利用します。
                - サービスの提供・運営
                - ユーザーサポート
                - サービスの改善
                
                3. 情報の第三者提供
                当社は、法令に基づく場合を除き、ユーザーの同意なく第三者に個人情報を提供しません。
                
                4. お問い合わせ
                プライバシーポリシーに関するお問い合わせは、ecg_english@nauticalmile.jpまでご連絡ください。
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("プライバシーポリシー")
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(AuthViewModel())
    }
}

