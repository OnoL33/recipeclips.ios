//
//  Item.swift
//  RecipeClip
//
//  Created by Ono Lee on 09.05.26.
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
