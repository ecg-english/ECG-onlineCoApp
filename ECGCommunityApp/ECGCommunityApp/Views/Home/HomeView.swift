import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var mileViewModel: MileViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    @EnvironmentObject var learningViewModel: LearningViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // ウェルカムメッセージ
                HStack {
                    VStack(alignment: .leading) {
                        Text("こんにちは、")
                            .font(.title2)
                        Text(authViewModel.currentUser?.username ?? "")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                .padding()
                
                // Mile表示
                VStack(alignment: .leading, spacing: 10) {
                    Text("累計Mile")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.title)
                        Text("\(mileViewModel.balance)")
                            .font(.system(size: 48, weight: .bold))
                        Text("Mile")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(15)
                .padding(.horizontal)
                
                // 新着情報
                VStack(alignment: .leading, spacing: 10) {
                    Text("新着情報")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // 新着イベント
                    if !eventViewModel.events.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("新しいイベント")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(eventViewModel.events.prefix(3)) { event in
                                        EventCardView(event: event)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 新着学習コンテンツ
                    if !learningViewModel.articles.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("新しい学習コンテンツ")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(learningViewModel.articles.prefix(3)) { article in
                                        LearningCardView(article: article)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .padding(.top, 60) // ヘッダー分のスペース
        }
        .task {
            await mileViewModel.loadBalance()
            await eventViewModel.loadEvents()
            await learningViewModel.loadArticles()
        }
    }
}

struct EventCardView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageUrl = event.flyerImageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 200, height: 120)
                .clipped()
            }
            
            Text(event.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(event.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct LearningCardView: View {
    let article: LearningArticle
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageUrl = article.coverImageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 200, height: 120)
                .clipped()
            }
            
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
            
            HStack {
                Text(article.category)
                    .font(.caption)
                    .padding(4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(article.milesReward)")
                        .font(.caption)
                }
            }
        }
        .frame(width: 200)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(MileViewModel())
            .environmentObject(EventViewModel())
            .environmentObject(LearningViewModel())
    }
}

