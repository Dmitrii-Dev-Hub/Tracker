import Foundation

extension R {
    enum Text {
        enum NavTitle: String {
            case newTracker = "newTrackerTitle"
            case habit
            case event
            
            var value: Swift.String {
                NSLocalizedString(self.rawValue, comment: "")
            }
        }
        
        enum Day {
            func localizedDaysString(count: Int) -> String {
                return String.localizedStringWithFormat(
                    NSLocalizedString("days", comment: "Days count string"),
                    count
                )
            }
        }
        
        enum ButtonTitle: String {
            case create
            case cancel
            case save
            case done
            case addCategory
            
            var value: Swift.String {
                NSLocalizedString(self.rawValue, comment: "")
            }
        }
        
        enum Onboarding: String  {
            case button = "onboardingButton"
            case first = "onboardingFirst"
            case second = "onboardingSecond"
            
            var value: Swift.String {
                NSLocalizedString(self.rawValue, comment: "")
            }
        }
        
        enum MainScreen: String {
            case trackers
            case statistic
            case search
            
            var value: Swift.String {
                NSLocalizedString(self.rawValue, comment: "")
            }
        }
        
        enum Filters: String {
            case filters = "filters"
            
            var value: Swift.String {
                NSLocalizedString(self.rawValue, comment: "")
            }
        }
        
        enum ContextMenu: String {
            case pin
            case unpin
            case delete
            case edit
            case pinned
            
            var value: Swift.String {
                NSLocalizedString(self.rawValue, comment: "")
            }
        }
        
        static let placeholderNewTracker = "Введите название трекера"
        
        static let textNoContent = "Что будем отслеживать?"
        static let textNoCategory = "Привычки и события можно\nобъединить по смыслу"
        static let textNothingFound = "Ничего не найдено"
        
        static let category = "Категория"
        static let newCategory = "Новая категория"
        static let schedule = "Расписание"
        
        static let color = "Цвет"
    }
}
