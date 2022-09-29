//
//  NotificationService.swift
//  NotificationService
//
//  Created by Gowthaman P on 05/10/21.
//

import UserNotifications

class NotificationService: MIService {
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        super.didReceive(request, withContentHandler: contentHandler)
    }
}
