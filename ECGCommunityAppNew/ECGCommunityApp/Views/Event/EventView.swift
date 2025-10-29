import SwiftUI

struct EventView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(eventViewModel.events) { event in
                        EventRowView(event: event)
                            .onTapGesture {
                                eventViewModel.selectedEvent = event
                            }
                    }
                }
                .padding()
                .padding(.top, 60) // ヘッダー分のスペース
            }
            .task {
                await eventViewModel.loadEvents()
            }
            .sheet(item: $eventViewModel.selectedEvent) { event in
                EventDetailView(event: event)
                    .environmentObject(authViewModel)
                    .environmentObject(eventViewModel)
            }
        }
    }
}

struct EventRowView: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let imageUrl = event.flyerImageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 200)
                .clipped()
                .cornerRadius(10)
            }
            
            Text(event.title)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: "calendar")
                Text(event.date, style: .date)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "mappin.circle")
                Text(event.venue)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "person.3")
                Text("\(event.participants.count)人参加予定")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

struct EventDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    let event: Event
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let imageUrl = event.flyerImageUrl {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(height: 300)
                        .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "calendar")
                            Text(event.date, style: .date)
                            Text(event.date, style: .time)
                        }
                        
                        HStack {
                            Image(systemName: "mappin.circle")
                            Text(event.venue)
                        }
                        
                        Divider()
                        
                        Text("料金")
                            .font(.headline)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("ビジター")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("¥\(Int(event.pricing.visitorPrice))")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("メンバー")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("¥\(Int(event.pricing.memberPrice))")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Divider()
                        
                        Text("説明")
                            .font(.headline)
                        Text(event.description)
                        
                        Divider()
                        
                        Text("参加者 (\(event.participants.count)人)")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(event.participants) { participant in
                                    VStack {
                                        if let avatarUrl = participant.user.profile?.avatarUrl {
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
                                        
                                        Text(participant.user.username)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            Task {
                                await eventViewModel.participateEvent(eventId: event.id)
                            }
                        }) {
                            Text(event.isParticipating == true ? "参加をキャンセル" : "参加登録")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(event.isParticipating == true ? Color.red : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView()
            .environmentObject(AuthViewModel())
            .environmentObject(EventViewModel())
    }
}

