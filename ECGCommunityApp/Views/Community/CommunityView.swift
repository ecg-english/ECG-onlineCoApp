import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var communityViewModel: CommunityViewModel
    @State private var expandedCategories: Set<String> = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(communityViewModel.categories) { category in
                        CategoryAccordionView(
                            category: category,
                            isExpanded: expandedCategories.contains(category.id),
                            channels: communityViewModel.channelsForCategory(category.id),
                            onToggle: {
                                if expandedCategories.contains(category.id) {
                                    expandedCategories.remove(category.id)
                                } else {
                                    expandedCategories.insert(category.id)
                                }
                            },
                            onSelectChannel: { channel in
                                communityViewModel.selectedChannel = channel
                            }
                        )
                    }
                }
                .padding(.top, 60) // ヘッダー分のスペース
            }
            .task {
                await communityViewModel.loadChannels()
            }
            .sheet(item: $communityViewModel.selectedChannel) { channel in
                ChannelDetailView(channel: channel)
                    .environmentObject(authViewModel)
                    .environmentObject(communityViewModel)
            }
        }
    }
}

struct CategoryAccordionView: View {
    let category: Category
    let isExpanded: Bool
    let channels: [Channel]
    let onToggle: () -> Void
    let onSelectChannel: (Channel) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(category.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
            }
            
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(channels) { channel in
                        Button(action: {
                            onSelectChannel(channel)
                        }) {
                            HStack {
                                Image(systemName: "number")
                                    .foregroundColor(.gray)
                                Text(channel.name)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                        }
                        Divider()
                    }
                }
            }
        }
    }
}

struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
            .environmentObject(AuthViewModel())
            .environmentObject(CommunityViewModel())
    }
}

