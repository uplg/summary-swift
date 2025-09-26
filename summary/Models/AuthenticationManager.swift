//
//  AuthenticationManager.swift
//  summary
//

import Foundation
import SwiftUI

@Observable
final class AuthenticationManager {
    var isAuthenticated = false 

    func setAuthenticated(_ authenticated: Bool) {
        isAuthenticated = authenticated
    }

    func logout() {
        isAuthenticated = false
    }
}
