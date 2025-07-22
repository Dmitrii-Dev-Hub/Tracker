import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard
            let configuration = AppMetricaConfiguration(
                apiKey: "eb1dbafa-cf2c-4f51-be81-0949aed386b6"
            ) else { return  }
       
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
        
    }
}

