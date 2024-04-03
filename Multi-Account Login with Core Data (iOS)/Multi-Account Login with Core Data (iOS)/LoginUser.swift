//
//  LoginUser.swift
//  Multi-Account Login with Core Data (iOS)
//
//  Created by SAURABH SHARMA on 26/03/24.
//

import Foundation

protocol SignInProtocol {
    var email: String! { get set }
    var password: String! { get set }
}

struct LoginUser: SignInProtocol {
    var email: String!
    var password: String!
}
