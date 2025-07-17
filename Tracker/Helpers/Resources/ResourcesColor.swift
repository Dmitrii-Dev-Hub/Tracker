import UIKit

extension R {
    enum ColorYP {
        static let whiteDynamic = UIColor(resource: .whiteYP)
        static let blackDynamic = UIColor(resource: .blackYP)
        static let backgroundDynamic = UIColor(resource: .backgroundYP)
        static let gray = UIColor(resource: .grayYP)
        static let red = UIColor(resource: .redYP)
        static let blue = UIColor(resource: .blueYP)
        
        
        enum Tracker {
            static let selection1 = UIColor(resource: .selection1)
            static let selection2 = UIColor(resource: .selection2)
            static let selection3 = UIColor(resource: .selection3)
            static let selection4 = UIColor(resource: .selection4)
            static let selection5 = UIColor(resource: .selection5)
            static let selection6 = UIColor(resource: .selection6)
            static let selection7 = UIColor(resource: .selection7)
            static let selection8 = UIColor(resource: .selection8)
            static let selection9 = UIColor(resource: .selection9)
            static let selection10 = UIColor(resource: .selection10)
            static let selection11 = UIColor(resource: .selection11)
            static let selection12 = UIColor(resource: .selection12)
            static let selection13 = UIColor(resource: .selection13)
            static let selection14 = UIColor(resource: .selection14)
            static let selection15 = UIColor(resource: .selection15)
            static let selection16 = UIColor(resource: .selection16)
            static let selection17 = UIColor(resource: .selection17)
            static let selection18 = UIColor(resource: .selection18)
            
            static let trackers = [
                R.ColorYP.Tracker.selection1,
                R.ColorYP.Tracker.selection2,
                R.ColorYP.Tracker.selection3,
                R.ColorYP.Tracker.selection4,
                R.ColorYP.Tracker.selection5,
                R.ColorYP.Tracker.selection6,
                R.ColorYP.Tracker.selection7,
                R.ColorYP.Tracker.selection8,
                R.ColorYP.Tracker.selection9,
                R.ColorYP.Tracker.selection10,
                R.ColorYP.Tracker.selection11,
                R.ColorYP.Tracker.selection12,
                R.ColorYP.Tracker.selection13,
                R.ColorYP.Tracker.selection14,
                R.ColorYP.Tracker.selection15,
                R.ColorYP.Tracker.selection16,
                R.ColorYP.Tracker.selection17,
                R.ColorYP.Tracker.selection18,
            ]
            
            
            static var trackersBorder: [UIColor] = [
                R.ColorYP.Tracker.selection1.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection2.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection3.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection4.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection5.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection6.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection7.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection8.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection9.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection10.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection11.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection12.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection13.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection14.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection15.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection16.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection17.withAlphaComponent(0.3),
                R.ColorYP.Tracker.selection18.withAlphaComponent(0.3),
            ]
        }
    }
}
