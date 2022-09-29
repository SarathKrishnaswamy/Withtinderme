//
//  SoftwareAndHardwareDetails.swift
//  Life Hope
//
//  Created by Gowthaman P on 08/11/20.
//

import UIKit

class SoftwareAndHardwareDetails: NSObject {

    static let sharedInstance = SoftwareAndHardwareDetails()
    
    ///This methos is used to find the system os version.
    func getOSVersion() -> String {
        return "\(UIDevice.current.systemVersion)"
    }
    
    
}
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var releaseVersionNumberPretty: String {
        return "\(releaseVersionNumber ?? "")"
    }
    var appVersionWithBuildNumber: String? {
        return "\(releaseVersionNumber ?? "").\(buildVersionNumber ?? "")"
    }
}
