//
//  DataModel.swift
//  Checklists
//
//  Created by MultisAudios on 10.05.2018.
//  Copyright © 2018 MultisAudios. All rights reserved.
//

import Foundation

class DataModel {
  
  var lists = [Checklist]()
  
  init() {
    loadChecklists()
    registerDefaults()
    handleFirstTime()
  }
  
  // MARK: - Documents Directory
  
  func documentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  func dataFilePath() -> URL {
    return documentsDirectory().appendingPathComponent("Checklists.plist")
  }
  
  // MARK: - Saving to Documents Directory's plist file
  
  func saveChecklists() {
    let encoder = PropertyListEncoder()
    do {
      let data = try encoder.encode(lists)
      try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
    } catch {
      print("Error encoding item array!")
    }
  }
  
  // MARK: - Loading from Documents plist file
  
  func loadChecklists() {
    let path = dataFilePath()
    if let data = try? Data(contentsOf: path) {
      let decoder = PropertyListDecoder()
      do {
        lists = try decoder.decode([Checklist].self, from: data)
        sortChecklists()
      } catch {
        print("Error decoding item array!")
      }
    }
  }
  
  // MARK: -
  
  // Registering defaults (to avoid app crush with index out of range on first launch)
  func registerDefaults() {
    let dictionary: [String: Any] = ["ChecklistIndex": -1, "FirstTime": true]
    UserDefaults.standard.register(defaults: dictionary)
  }
  
  var indexOfSelectedChecklist: Int {
    get {
      return UserDefaults.standard.integer(forKey: "ChecklistIndex")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
      UserDefaults.standard.synchronize()
    }
  }
  
  // First launch of app
  func handleFirstTime() {
    let userDefaults = UserDefaults.standard
    let firstTime = userDefaults.bool(forKey: "FirstTime")
    
    if firstTime {
      let checklist = Checklist(name: "List")
      lists.append(checklist)
      
      indexOfSelectedChecklist = 0
      userDefaults.set(false, forKey: "FirstTime")
      userDefaults.synchronize()
    }
  }
  
  func sortChecklists() {
    lists.sort(by: { (checklist1, checklist2) -> Bool in
      return checklist1.name.localizedStandardCompare(checklist2.name) == .orderedAscending })
  }
  
  class func nextChecklistItemID() -> Int {
    let userDefaults = UserDefaults.standard
    let itemID = userDefaults.integer(forKey: "ChecklistItemID")
    userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
    userDefaults.synchronize()
    return itemID
  }
}
