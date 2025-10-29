import SwiftUI

struct LearningView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var learningViewModel: LearningViewModel
    @EnvironmentObject var mileViewModel: MileViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                // カテゴリフィルター
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(LearningCategory.allCases, id: \.self) { category in
                            Button(action: {
                                learningViewModel.selectedCategory = category
                                Task {
                                    await learningViewModel.loadArticles(category: category)
                                }
                            }) {
                                Text(category.rawValue)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(learningViewModel.selectedCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(learningViewModel.selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding()
                }
                
                // 記事一覧
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(learningViewModel.articles) { article in
                            NavigationLink(destination: LearningArticleDetailView(article: article)
                                .environmentObject(learningViewModel)
                                .environmentObject(mileViewModel)
                            ) {
                                LearningArticleRowView(article: article)
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding(.top, 60) // ヘッダー分のスペース
            .task {
                await learningViewModel.loadArticles()
            }
        }
    }
}

struct LearningArticleRowView: View {
    let article: LearningArticle
    
    var body: some View {
        HStack(spacing: 15) {
            if let imageUrl = article.coverImageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let subtitle = article.subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    Text(article.category)
                        .font(.caption)
                        .padding(4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(article.milesReward) Mile")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                
                if article.isCompleted == true {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("完了済み")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct LearningArticleDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var learningViewModel: LearningViewModel
    @EnvironmentObject var mileViewModel: MileViewModel
    let article: LearningArticle
    
    @State private var showRating = false
    @State private var rating = 5
    @State private var showSuccess = false
    @State private var earnedMiles = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageUrl = article.coverImageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(height: 200)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(article.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let subtitle = article.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(article.category)
                            .font(.caption)
                            .padding(6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(6)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(article.milesReward) Mile獲得可能")
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Divider()
                    
                    Link(destination: URL(string: article.contentUrl)!) {
                        HStack {
                            Text("記事を読む")
                            Image(systemName: "arrow.up.right.square")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    if article.isCompleted != true {
                        Button(action: {
                            showRating = true
                        }) {
                            Text("完了してMileを獲得")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("完了済み")
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showRating) {
            RatingView(rating: $rating) {
                Task {
                    if let miles = await learningViewModel.completeArticle(articleId: article.id, rating: rating) {
                        earnedMiles = miles
                        showSuccess = true
                        await mileViewModel.loadBalance()
                    }
                    showRating = false
                }
            }
        }
        .alert("おめでとうございます!", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("\(earnedMiles) Mileを獲得しました!")
        }
    }
}

struct RatingView: View {
    @Binding var rating: Int
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("理解度を評価してください")
                .font(.headline)
            
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { index in
                    Button(action: {
                        rating = index
                    }) {
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.largeTitle)
                            .foregroundColor(index <= rating ? .yellow : .gray)
                    }
                }
            }
            
            Button(action: onComplete) {
                Text("完了")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct LearningView_Previews: PreviewProvider {
    static var previews: some View {
        LearningView()
            .environmentObject(AuthViewModel())
            .environmentObject(LearningViewModel())
            .environmentObject(MileViewModel())
    }
}

