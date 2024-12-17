//
//  Item.swift
//  digiBrain
//
//  Created by Areeb Abbasi on 12/17/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
