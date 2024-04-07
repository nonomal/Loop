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

    @ObservedObject var notchSnapper: NotchSnapper
    let action: WindowAction
    let parentSize: CGSize

    init(_ notchSnapper: NotchSnapper, action: WindowAction, parentSize: CGSize) {
        self.notchSnapper = notchSnapper
        self.action = action
        self.parentSize = parentSize
    }

    var body: some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundStyle(
                    Color.secondary.opacity(
                        self.action.direction == self.notchSnapper.currentAction.direction ? 0.3 : 0.1
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
                .onChange(of: notchSnapper.mouseEvent) { _ in
                    guard
                        let screen = NSScreen.screenWithMouse,
                        self.notchSnapper.currentAction.direction != self.action.direction
                    else {
                        return
                    }

                    var frame = geo.frame(in: .global).flipY(maxY: screen.frame.maxY)
                    frame.origin.x += screen.frame.origin.x
                    frame.origin.y += screen.frame.origin.y

                    if frame.contains(NSEvent.mouseLocation) {
                        Notification.Name.updateUIDirection.post(userInfo: ["action": self.action])

                        if Defaults[.hapticFeedback] {
                            NSHapticFeedbackManager.defaultPerformer.perform(
                                NSHapticFeedbackManager.FeedbackPattern.alignment,
                                performanceTime: NSHapticFeedbackManager.PerformanceTime.now
                            )
                        }

                        withAnimation(.easeOut(duration: 0.1)) {
                            notchSnapper.currentAction = self.action
                        }
                    }
                }
        }
        .frame(
            width: parentSize.width * (self.action.direction.frameMultiplyValues?.width ?? .zero),
            height: parentSize.height * (self.action.direction.frameMultiplyValues?.height ?? .zero)
        )
    }
}
