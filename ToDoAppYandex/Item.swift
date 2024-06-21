//
//  Item.swift
//  ToDoAppYandex
//
//  Created by Владислав Пономаренко on 21.06.2024.
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
