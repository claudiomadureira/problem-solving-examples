/*
 
 Goal: Find the available hour intervals for two persons to have a meeting considered both of them has already other meetings scheduled.
 
 Considering that a meeting is represented by it's start and end time.
 Ex: ("10:00", "10:30") this meeting start at 10am and ends at 10:30am.
 
 Also, is considered that a meeting requires a 30min minimum duration.
 
 Consider that each person has daily meeting bounds. The person doesn't want to have a meeting before 8am and after 5pm.
 Ex:
 Person 1 => ("9:00", "20:00")
 Person 2 => ("10:00", "18:30")
 
 Consider now two datasets. Each represents a person meetings schedule during one day. You can consider that it will be always sorted and are within the daily meeting bounds.
 Ex:
 Person 1 => [("9:00", "10:30"), ("12:00", "13:00"), ("16:00", "18:00")]
 Person 2 => [("10:00", "11:30"), ("12:30", "14:30"), ("14:30", "15:00"), ("16:00", "17:00")]
 
 This example output should be:
 [("11:30", "12:00"), ("15:00", "16:00"), ("18:00", "18:30")]
 
 Source: https://www.youtube.com/watch?v=3Q_oYDQ2whs
 
 */

/*
 
 Person 1
 ("9:00", "20:00")
 [("9:00", "10:30"), ("12:00", "13:00"), ("16:00", "18:00")]
 
 Person 2
 ("10:00", "18:30")
 [("10:00", "11:30"), ("12:30", "14:30"), ("14:30", "15:00"), ("16:00", "17:00")]
 
 AvailableTimes
 P1 [("10:30","12:00"), ("13:00", "16:00"), ("18:00", "20:00")] O(n)
 P2 [("11:30", "12:30"), ("15:00", "16:00"), ("17:00", "18:30")] O(m)
 
 O(n+m)
 [("11:30", "12:00"), ("15:00", "16:00"), ("18:00", "18:30")]
 
*/

import Foundation

typealias TimeBounds = (startsAt: String, endsAt: String)
typealias MeetingDuration = TimeBounds
typealias Calendar = [MeetingDuration]
typealias Person = (calendar: Calendar, dailyBounds: TimeBounds)


extension String {
    
    var minutes: Int {
        let hours: Int = Int(self.components(separatedBy: ":")[0]) ?? 0
        let minutes: Int = Int(self.components(separatedBy: ":")[1]) ?? 0
        return minutes + (hours * 60)
    }
    
}


func getAvailableTimesFor(person: Person) -> Calendar { // O(N)
    if person.calendar.isEmpty {
        return [person.dailyBounds]
    }
    var availableTimes: Calendar = []
    let firstMeeting: MeetingDuration = person.calendar[0]
    if person.dailyBounds.startsAt.minutes > firstMeeting.startsAt.minutes { // The first meeting starts later then the daily bounds
        availableTimes.append((person.dailyBounds.startsAt, firstMeeting.startsAt))
    }
    
    for i in 0..<person.calendar.count - 1 {
        let left = person.calendar[i]
        let right = person.calendar[i + 1]
        if left.endsAt.minutes < right.startsAt.minutes {
            availableTimes.append((left.endsAt, right.startsAt))
        }
    }
    
    if let lastMeeting = person.calendar.last, lastMeeting.endsAt.minutes < person.dailyBounds.endsAt.minutes { // The last meeting ends before the daily bounds
        availableTimes.append((lastMeeting.endsAt, person.dailyBounds.endsAt))
    }
    
    return availableTimes
}
    
func getAvailableMeetingTimes(person1: Person, person2: Person, minimumMeetingDuration: Int) -> Calendar {
    
    let person1AvailableTimes: Calendar = getAvailableTimesFor(person: person1) // O(N)
    let person2AvailableTimes: Calendar = getAvailableTimesFor(person: person2) // O(N)
    
    // O(N+M)
    var availableMeetingTimes: Calendar = []
    for timePerson1 in person1AvailableTimes {
        for timePerson2 in person2AvailableTimes {
            var startsAt: String = ""
            if timePerson1.startsAt.minutes < timePerson2.startsAt.minutes {
                startsAt = timePerson2.startsAt
            } else {
                startsAt = timePerson1.startsAt
            }
            var endsAt: String = ""
            if timePerson1.endsAt.minutes < timePerson2.endsAt.minutes {
                endsAt = timePerson1.endsAt
            } else {
                endsAt = timePerson2.endsAt
            }
            
            if startsAt.minutes < endsAt.minutes {
                let availableTime: TimeBounds = (startsAt, endsAt)
                availableMeetingTimes.append(availableTime)
            }
        }
    }
    
    // O(N)
    for (i, time) in availableMeetingTimes.enumerated().reversed() {
        if (time.endsAt.minutes - time.startsAt.minutes) < minimumMeetingDuration {
            availableMeetingTimes.remove(at: i)
        }
    }
    
    return availableMeetingTimes
}


let person1: Person = ([("9:00", "10:30"), ("12:00", "13:00"), ("16:00", "18:00")], ("9:00", "20:00"))
let person2: Person = ([("10:00", "11:30"), ("12:30", "14:30"), ("14:30", "15:00"), ("16:00", "17:00")],  ("10:00", "18:30"))

let availableTimes: Calendar = getAvailableMeetingTimes(person1: person1, person2: person2, minimumMeetingDuration: 30)
