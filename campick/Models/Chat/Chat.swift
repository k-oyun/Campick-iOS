//
//  Message.swift
//  campick
//
//  Created by oyun on 2025-09-16.
//

import SwiftUI

import Foundation



struct Chat: Decodable, Identifiable {
    let message: String
    let senderId: Int
    let sendAt: String
    let isRead: Bool

    var id: String { "\(senderId)_\(sendAt)" } 
}
