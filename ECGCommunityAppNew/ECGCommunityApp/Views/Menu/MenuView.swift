import SwiftUI

struct MenuView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    @State private var showProfile = false
    @State private var showMemberList = false
    @State private var showAbout = false
    @State private var showEventCalendar = false
    @State private var showAdminPanel = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        showProfile = true
                    }) {
                        Label("プロフィール", systemImage: "person.fill")
                    }
                    
                    if authViewModel.currentUser?.isMember == true {
                        Button(action: {
                            showMemberList = true
                        }) {
                            Label("メンバーリスト", systemImage: "person.3.fill")
                        }
                    }
                    
                    Button(action: {
                        showAbout = true
                    }) {
                        Label("このコミュニティアプリでできること", systemImage: "info.circle.fill")
                    }
                    
                    Button(action: {
                        showEventCalendar = true
                    }) {
                        Label("イベントカレンダー", systemImage: "calendar")
                    }
                }
                
                if authViewModel.currentUser?.isAdmin == true {
                    Section {
                        Button(action: {
                            showAdminPanel = true
                        }) {
                            Label("管理者画面", systemImage: "lock.shield.fill")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle("メニュー")
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
            .sheet(isPresented: $showProfile) {
                ProfileView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showMemberList) {
                MemberListView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .sheet(isPresented: $showEventCalendar) {
                EventCalendarView()
                    .environmentObject(eventViewModel)
            }
            .sheet(isPresented: $showAdminPanel) {
                AdminPanelView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .environmentObject(AuthViewModel())
            .environmentObject(EventViewModel())
    }
}

