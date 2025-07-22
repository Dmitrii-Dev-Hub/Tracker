import Foundation

extension R {
    enum Mocks {
        static let weekdays: [Day] = [
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday,
            .saturday,
            .sunday
        ]
        
        static let weekdaysStrings: [String] = [
            "Понедельник",
            "Вторник",
            "Среда",
            "Четверг",
            "Пятница",
            "Суббота",
            "Воскресенье"
        ]
        
        static let shortDays: [String] = [
            "Пн",
            "Вт"
            ,"Ср"
            ,"Чт"
            ,"Пт"
            ,"Сб"
            ,"Вс"
        ]
        
        static let filters: [String] = [
            "Все трекеры",
            "Трекеры на сегодня",
            "Завершенные",
            "Незавершенные"
        ]
        
        static let trackers = [
            TrackerCategory(title: "Важное", trackers: [
                Tracker(
                    id: UUID(),
                    name: "Поливать растения",
                    color: R.ColorYP.blue,
                    emoji: "❤️",
                    timetable: [.monday, .wednesday],
                    creationDate: Date()
                ),
                Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне", color:  R.ColorYP.blue, emoji: "👻", timetable: [.tuesday], creationDate: Date()),
                Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсапе", color: R.ColorYP.blue, emoji: "☺️", timetable: [.wednesday], creationDate: Date())]),
            TrackerCategory(title: "Радостные мелочи", trackers: [
                Tracker(id: UUID(), name: "Свидания в апреле", color: R.ColorYP.blue, emoji: "😂", timetable: [.thursday, .tuesday], creationDate: Date())])
        ]
        
        static let emojies: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                                           "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                                           "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    }
}
