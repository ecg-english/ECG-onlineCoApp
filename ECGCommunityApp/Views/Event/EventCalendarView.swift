import SwiftUI

struct EventCalendarView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var eventViewModel: EventViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                // カレンダー
                CalendarView(
                    currentMonth: $currentMonth,
                    selectedDate: $selectedDate,
                    events: eventViewModel.eventsForMonth(currentMonth)
                )
                
                Divider()
                
                // 選択日のイベント一覧
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(selectedDate, style: .date)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        let dayEvents = eventViewModel.eventsForDate(selectedDate)
                        
                        if dayEvents.isEmpty {
                            Text("この日のイベントはありません")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(dayEvents) { event in
                                Button(action: {
                                    eventViewModel.selectedEvent = event
                                }) {
                                    EventCalendarRowView(event: event)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("イベントカレンダー")
            .navigationBarItems(trailing: Button("閉じる") {
                dismiss()
            })
            .task {
                await eventViewModel.loadEvents()
            }
            .sheet(item: $eventViewModel.selectedEvent) { event in
                EventDetailView(event: event)
                    .environmentObject(AuthViewModel())
                    .environmentObject(eventViewModel)
            }
        }
    }
}

struct CalendarView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    let events: [Event]
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["日", "月", "火", "水", "木", "金", "土"]
    
    var body: some View {
        VStack {
            // 月選択
            HStack {
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(currentMonth, format: .dateTime.year().month(.wide))
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            // 曜日ヘッダー
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // カレンダーグリッド
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(getDaysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            hasEvent: hasEvent(on: date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func getDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var date = monthFirstWeek.start
        
        while date < monthInterval.end {
            if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                days.append(date)
            } else {
                days.append(nil)
            }
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        // 6週間分（42日）に調整
        while days.count < 42 {
            days.append(nil)
        }
        
        return Array(days.prefix(42))
    }
    
    private func hasEvent(on date: Date) -> Bool {
        events.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasEvent: Bool
    let isCurrentMonth: Bool
    
    var body: some View {
        VStack {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption)
                .foregroundColor(isCurrentMonth ? .primary : .secondary)
            
            if hasEvent {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
        .cornerRadius(8)
    }
}

struct EventCalendarRowView: View {
    let event: Event
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "clock")
                    Text(event.date, style: .time)
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "mappin.circle")
                    Text(event.venue)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct EventCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        EventCalendarView()
            .environmentObject(EventViewModel())
    }
}

