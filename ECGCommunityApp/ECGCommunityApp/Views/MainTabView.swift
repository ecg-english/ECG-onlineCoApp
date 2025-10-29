import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var communityViewModel = CommunityViewModel()
    @StateObject private var eventViewModel = EventViewModel()
    @StateObject private var learningViewModel = LearningViewModel()
    @StateObject private var mileViewModel = MileViewModel()
    @StateObject private var shopViewModel = ShopViewModel()
    
    @State private var selectedTab = 0
    @State private var showMenu = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .environmentObject(authViewModel)
                    .environmentObject(mileViewModel)
                    .environmentObject(eventViewModel)
                    .environmentObject(learningViewModel)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                CommunityView()
                    .environmentObject(authViewModel)
                    .environmentObject(communityViewModel)
                    .tabItem {
                        Label("Community", systemImage: "bubble.left.and.bubble.right.fill")
                    }
                    .tag(1)
                
                EventView()
                    .environmentObject(authViewModel)
                    .environmentObject(eventViewModel)
                    .tabItem {
                        Label("Event", systemImage: "calendar")
                    }
                    .tag(2)
                
                LearningView()
                    .environmentObject(authViewModel)
                    .environmentObject(learningViewModel)
                    .environmentObject(mileViewModel)
                    .tabItem {
                        Label("Learning", systemImage: "book.fill")
                    }
                    .tag(3)
                
                ShopView()
                    .environmentObject(authViewModel)
                    .environmentObject(shopViewModel)
                    .environmentObject(mileViewModel)
                    .tabItem {
                        Label("Shop", systemImage: "cart.fill")
                    }
                    .tag(4)
                
                SettingView()
                    .environmentObject(authViewModel)
                    .tabItem {
                        Label("Setting", systemImage: "gearshape.fill")
                    }
                    .tag(5)
            }
            
            // ヘッダー
            VStack {
                HStack {
                    Text("ECG Community")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        showMenu.toggle()
                    }) {
                        if let profile = authViewModel.currentUser?.profile, let avatarUrl = profile.avatarUrl {
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
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                Spacer()
            }
        }
        .sheet(isPresented: $showMenu) {
            MenuView()
                .environmentObject(authViewModel)
                .environmentObject(eventViewModel)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
}

