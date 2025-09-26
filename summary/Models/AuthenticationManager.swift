//
//  AuthenticationManager.swift
//  summary
//
//  Created by Assistant on 23/09/2025.
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
