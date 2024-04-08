//
//  ResizeSelectorRectangle.swift
//  Loop
//
//  Created by Kai Azim on 2023-08-22.
//

import SwiftUI
import Defaults

struct ResizeSelectorRectangle: View {
    let cornerRadius: CGFloat = 5

    let activeColor: NSColor = NSColor.controlBackgroundColor
    let inactiveColor: NSColor = NSColor.controlBackgroundColor

    @ObservedObject var tooltipManager: TooltipManager
    let action: WindowAction
    let sectionSize: CGSize
    let windowHeight: CGFloat

    init(_ tooltipManager: TooltipManager, action: WindowAction, sectionSize: CGSize, windowHeight: CGFloat) {
        self.tooltipManager = tooltipManager
        self.action = action
        self.sectionSize = sectionSize
        self.windowHeight = windowHeight
    }

    var body: some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundStyle(
                    Color.secondary.opacity(
                        self.action.direction == self.tooltipManager.currentAction.direction ? 0.3 : 0.1
                    )
                )
                .overlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(lineWidth: 1.5)
                            .foregroundStyle(Color.primary.opacity(0.5))
                    }
                }
                .padding(3)
                .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
                .onChange(of: tooltipManager.mouseEvent) { _ in
                    guard
                        let offset = TooltipManager.windowOffset,
                        self.tooltipManager.currentAction.direction != self.action.direction
                    else {
                        return
                    }

                    var frame = geo.frame(in: .global).flipY(maxY: windowHeight)
                    frame.origin.x += offset.minX
                    frame.origin.y += offset.minY

                    if frame.contains(NSEvent.mouseLocation) {
                        Notification.Name.updateUIDirection.post(userInfo: ["action": self.action])

                        if Defaults[.hapticFeedback] {
                            NSHapticFeedbackManager.defaultPerformer.perform(
                                NSHapticFeedbackManager.FeedbackPattern.alignment,
                                performanceTime: NSHapticFeedbackManager.PerformanceTime.now
                            )
                        }

                        withAnimation(.easeOut(duration: 0.1)) {
                            tooltipManager.currentAction = self.action
                        }
                    }
                }
        }
        .frame(
            width: sectionSize.width * (self.action.direction.frameMultiplyValues?.width ?? .zero),
            height: sectionSize.height * (self.action.direction.frameMultiplyValues?.height ?? .zero)
        )
    }
}
