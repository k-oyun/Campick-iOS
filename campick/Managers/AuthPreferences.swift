//
//  AuthPreferences.swift
//  campick
//
//  Centralizes auth-related user preferences.
//

import Foundation

// NOTE: Auto-login preference is currently disabled pending product decision.
// Keeping skeleton for future use.
enum AuthPreferences {
    private static let keepLoggedInKey = "keepLoggedIn"

    static var keepLoggedIn: Bool {
        get {
            // return UserDefaults.standard.object(forKey: keepLoggedInKey) as? Bool ?? true
            return true // disabled
        }
        set {
            // UserDefaults.standard.set(newValue, forKey: keepLoggedInKey)
        }
    }
}
