import Foundation
import SwiftUI

@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedEvent: Event?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func loadEvents(startDate: Date? = nil, endDate: Date? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getEvents(startDate: startDate, endDate: endDate)
            events = response.events
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadEvent(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getEvent(id: id)
            selectedEvent = response.event
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func participateEvent(eventId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.participateEvent(eventId: eventId)
            selectedEvent = response.event
            await loadEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func eventsForDate(_ date: Date) -> [Event] {
        let calendar = Calendar.current
        return events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func eventsForMonth(_ date: Date) -> [Event] {
        let calendar = Calendar.current
        return events.filter {
            calendar.isDate($0.date, equalTo: date, toGranularity: .month)
        }
    }
}

