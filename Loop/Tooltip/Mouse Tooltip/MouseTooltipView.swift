//
//  MouseTooltipView.swift
//  Loop
//
//  Created by Kai Azim on 2024-04-07.
//

import SwiftUI

struct MouseTooltipView: View {
    @ObservedObject var tooltipManager: TooltipManager

    var body: some View {
        ResizeSelectorView(tooltipManager: tooltipManager)
            .fixedSize()
            .background {
                VisualEffectView(material: .popover, blendingMode: .behindWindow)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(.quaternary, lineWidth: 1)
                    }
            }
            .clipShape(.rect(cornerRadius: 20))
    }
}
