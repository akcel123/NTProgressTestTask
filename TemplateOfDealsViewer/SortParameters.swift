//
//  SortParameters.swift
//  TemplateOfDealsViewer
//
//  Created by Денис Павлов on 03.04.2023.
//

import Foundation

struct SortParameters {
    enum Label: String {
        case instrument = "Instrument"
        case price = "Price"
        case amount = "Amount"
        case side = "Side"
        case date = "Date"
    }
    enum Direction: String {
        case up = "↑"
        case down = "↓"
    }
    
    var label: Label
    var direction: Direction
    
    init(label: Label, direction: Direction) {
        self.label = label
        self.direction = direction
    }
    
}
