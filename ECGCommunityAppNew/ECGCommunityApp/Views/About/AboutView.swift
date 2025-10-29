import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ECG Communityへようこそ!")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("このアプリでは、ECGコミュニティメンバー同士の交流や言語・文化の学習ができます。")
                            .foregroundColor(.secondary)
                    }
                    
                    FeatureCard(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: "Community",
                        description: "カテゴリ別のチャンネルで、メンバーと自由に交流できます。投稿、いいね、コメント機能があります。"
                    )
                    
                    FeatureCard(
                        icon: "calendar",
                        title: "Event",
                        description: "ECGが開催するイベント情報を確認し、参加登録ができます。イベント前にはプッシュ通知でお知らせします。"
                    )
                    
                    FeatureCard(
                        icon: "book.fill",
                        title: "Learning",
                        description: "英語学習やコミュニケーション、異文化理解に関する記事や動画で学習できます。完了するとMileを獲得できます。"
                    )
                    
                    FeatureCard(
                        icon: "star.fill",
                        title: "Mile System",
                        description: "様々なアクションでMileを獲得できます。貯めたMileは教材購入やメンバー費用の割引に使用できます。"
                    )
                    
                    FeatureCard(
                        icon: "cart.fill",
                        title: "Shop",
                        description: "Mileを使って割引チケットや教材を購入できます。Mileの購入も可能です。"
                    )
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("メンバーになるには?")
                            .font(.headline)
                        
                        Text("現在ビジターとして登録されています。メンバーになると、全ての機能にアクセスできるようになります。")
                            .foregroundColor(.secondary)
                        
                        Text("メンバー登録については、管理者にお問い合わせください。")
                            .foregroundColor(.secondary)
                        
                        Link(destination: URL(string: "mailto:ecg_english@nauticalmile.jp")!) {
                            HStack {
                                Image(systemName: "envelope")
                                Text("お問い合わせ")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("コミュニティについて")
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

