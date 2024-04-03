//
//  AccountViewModel.swift
//  Multi-Account Login with Core Data (iOS)
//
//  Created by SAURABH SHARMA on 26/03/24.
//

import Foundation

class AccountViewModel: NSObject {
    static let shared = AccountViewModel()
    private override init() {
        super.init()
    }
    public var currentUser: SignInProtocol!
}
