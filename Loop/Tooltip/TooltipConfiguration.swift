//
//  TooltipConfiguration.swift
//  Loop
//
//  Created by Kai Azim on 2024-04-07.
//

import SwiftUI
import Defaults

enum TooltipConfiguration: Int, _DefaultsSerializable, CaseIterable, Identifiable {
    var id: Self { return self }

    case off = 0
    case notch = 1
    case onDrag = 2

    var name: String {
        switch self {
        case .off:      return "Off"
        case .notch:    return "Notch"
        case .onDrag:   return "On Drag"
        }
    }
}
