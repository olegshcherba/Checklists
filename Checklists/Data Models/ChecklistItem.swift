//
//  ChecklistItem.swift
//  Checklists
//
//  Created by MultisAudios on 30.04.2018.
//  Copyright © 2018 MultisAudios. All rights reserved.
//

import Foundation
import UserNotifications

class ChecklistItem: NSObject, Codable {
  var text = ""
  var checked = false
  
  var dueDate = Date()
  var shouldRemind = false
  var itemID: Int
  
  override init() {
    itemID = DataModel.nextChecklistItemID()
    super.init()
  }
  
  deinit {
    removeNotification()
  }
  
  func toggleChecked() {
    checked = !checked
  }
  
  func scheduleNotification() {
    removeNotification()
    if shouldRemind && dueDate > Date() {
      
      let content = UNMutableNotificationContent()
      content.title = "Reminder:"
      content.body = text
      content.sound = UNNotificationSound.default()
      
      let calendar = Calendar(identifier: .gregorian)
      let components = calendar.dateComponents([.month, .day, .hour, .minute], from: dueDate)
      
      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
      
      let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
      
      let center = UNUserNotificationCenter.current()
      center.add(request)
    }
  }
  
  func removeNotification() {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
  }
}

