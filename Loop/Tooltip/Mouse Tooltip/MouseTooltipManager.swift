//
//  MouseTooltipManager.swift
//  Loop
//
//  Created by Kai Azim on 2024-04-07.
//

import SwiftUI

class MouseTooltipManager {
    private var tooltipManager: TooltipManager
    private var windowController: NSWindowController?

    var isVisible: Bool {
        self.windowController != nil
    }

    init(tooltipManager: TooltipManager) {
        self.tooltipManager = tooltipManager
    }

    func open() {
        if let windowController = windowController {
            windowController.window?.orderFrontRegardless()
            return
        }

        guard let screen = NSScreen.screenWithMouse else { return }
        let view = NSHostingView(rootView: MouseTooltipView(tooltipManager: self.tooltipManager))

        let panel = NSPanel(
            contentRect: view.bounds,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )

        panel.alphaValue = 0
        panel.backgroundColor = .clear
        panel.level = NSWindow.Level(NSWindow.Level.screenSaver.rawValue - 1)
        panel.contentView = view
        panel.collectionBehavior = .canJoinAllSpaces
        panel.ignoresMouseEvents = true

        panel.centerAtMouse()
        panel.fit(inside: screen.visibleFrame)

        TooltipManager.windowOffset = .init(origin: panel.frame.origin, size: screen.frame.size)

        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            panel.animator().alphaValue = 1
        }

        windowController = .init(window: panel)
    }

    func close() {
        guard let windowController = windowController else { return }
        self.windowController = nil

        windowController.window?.animator().alphaValue = 1
        NSAnimationContext.runAnimationGroup({ _ in
            windowController.window?.animator().alphaValue = 0
        }, completionHandler: {
            windowController.close()
        })
    }
}

extension NSWindow {
    func centerAtMouse() {
        let mousePosition = NSEvent.mouseLocation

        let windowRect = self.frame
        let windowOrigin = CGPoint(
            x: mousePosition.x - windowRect.width / 2,
            y: mousePosition.y - windowRect.height / 2
        )

        self.setFrameOrigin(windowOrigin)
    }

    func fit(inside frame: NSRect) {
        let windowRect = self.frame
        var windowOrigin = windowRect.origin

        if windowRect.maxX > frame.maxX {
            windowOrigin.x = frame.maxX - windowRect.width
        }

        if windowRect.minX < frame.minX {
            windowOrigin.x = frame.minX
        }

        if windowRect.maxY > frame.maxY {
            windowOrigin.y = frame.maxY - windowRect.height
        }

        if windowRect.minY < frame.minY {
            windowOrigin.y = frame.minY
        }

        self.setFrameOrigin(windowOrigin)
    }
}
