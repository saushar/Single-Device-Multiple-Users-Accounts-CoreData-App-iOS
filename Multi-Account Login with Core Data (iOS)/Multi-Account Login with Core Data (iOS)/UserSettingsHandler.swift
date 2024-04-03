//
//  UserSettingsHandler.swift
//  Multi-Account Login with Core Data (iOS)
//
//  Created by SAURABH SHARMA on 26/03/24.
//

import Foundation

class UserSettingsHandler {
    var email: String
    var icloudBackupEnabled: Bool = false
    
    init(with email: String) {
        self.email = email.lowercased()
    }
    
    func save(userSetting: [String: Any]) {
        do {
            let standardDefaults = UserDefaults.standard
            let archive = try NSKeyedArchiver.archivedData(withRootObject: userSetting, requiringSecureCoding: false)
            standardDefaults.setValue(archive, forKey: email)
            standardDefaults.synchronize()
        } catch {
            print(error)
        }
    }
    
    func retrieve() -> [String: Any]? {
        if let decodedData = UserDefaults.standard.value(forKey: email) as? Data {
            let userSetting = try! NSKeyedUnarchiver.unarchivedObject(ofClass: NSDictionary.self, from: decodedData) as! [String: Any]
            return userSetting
        }
        return nil
    }
}
