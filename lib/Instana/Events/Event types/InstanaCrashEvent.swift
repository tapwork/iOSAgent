//  Created by Nikola Lajic on 1/23/19.
//  Copyright © 2019 Nikola Lajic. All rights reserved.

import Foundation

class InstanaCrashEvent: InstanaEvent, InstanaEventResultNotifiable {
    let completion: InstanaEventResultNotifiable.CompletionBlock
    let report: String
    let breadcrumbs: [String]?
    
    init(sessionId: String, timestamp: Instana.Types.UTCTimestamp, report: String, breadcrumbs: [String]?, completion: @escaping InstanaEventResultNotifiable.CompletionBlock) {
        self.report = report
        self.breadcrumbs = breadcrumbs
        self.completion = completion
        super.init(sessionId: sessionId, timestamp: timestamp)
    }
    
    override func toJSON() -> [String : Any] {
        var json = super.toJSON()
        json["crash"] = [
            "appVersion": InstanaSystemUtils.applicationVersion,
            "appBuildNumber": InstanaSystemUtils.applicationBuildNumber,
            "type": "iOS",
            "timestamp": timestamp,
            "report": report,
            "breadcrumbs": breadcrumbs ?? []
        ]
        return json
    }
}
