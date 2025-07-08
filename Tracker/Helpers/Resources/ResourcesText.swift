import Foundation

extension Resources {
    enum Text {
        enum NavTitle {
            static let newTracker = "Создание трекера"
            static let habitTitle = "Новая привычка"
            static let eventTitle = "Новое нерегулярное событие"
        }
        
        enum ButtonTitle {
            static let create = "Создать"
            static let cancel = "Отменить"
            static let done = "Готово"
            static let createCategory = "Добавить категорию"
        }
        
        static let tracker = "Трекеры"
        static let placeholderNewTracker = "Введите название трекера"
        static let statistic = "Статистика"
        
        static let textNoContent = "Что будем отслеживать?"
        static let textNoCategory = "Привычки и события можно\nобъединить по смыслу"
        static let textNothingFound = "Ничего не найдено"
        
        static let category = "Категория"
        static let newCategory = "Новая категория"
        static let schedule = "Расписание"
        
        static let color = "Цвет"
    }
}
