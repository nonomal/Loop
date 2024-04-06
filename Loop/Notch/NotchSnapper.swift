//
//  NotchSnapper.swift
//  Loop
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI
import DynamicNotchKit

class NotchSnapper: ObservableObject {
    private var dynamicNotch: DynamicNotch?
    private var screen: NSScreen?
    private var eventMonitor: EventMonitor?
    private let previewController = PreviewController()

    @Published var mouseEvent: NSEvent?
    @Published var currentAction: WindowAction = .init(.noAction)

    init() {}

    func start() {
        self.dynamicNotch = DynamicNotch(content: ResizeSelectorView(notchSnapper: self))

        self.eventMonitor = NSEventMonitor(
            scope: .all,
            eventMask: [.leftMouseDragged, .leftMouseUp]
        ) { event in
            if event.type == .leftMouseDragged {
                self.leftMouseDragged(event: event)
            }

            if event.type == .leftMouseUp {
                self.leftMouseUp()
            }
        }

        self.eventMonitor!.start()
    }

    func leftMouseDragged(event: NSEvent) {
        self.mouseEvent = event

        if self.dynamicNotch != nil,
           self.dynamicNotch!.checkIfMouseIsInNotch(),
           let screenWithMouse = NSScreen.screenWithMouse {
            self.screen = screenWithMouse
            self.dynamicNotch!.show(on: screenWithMouse)
            self.previewController.open(screen: screenWithMouse)
        }

        if self.dynamicNotch != nil,
           self.dynamicNotch!.isVisible,
           let screenWithMouse = NSScreen.screenWithMouse,
           self.screen != screenWithMouse {

            self.dynamicNotch!.hide()
            self.previewController.close()
            self.currentAction = .init(.noAction)
        }
    }

    func leftMouseUp() {
        if self.dynamicNotch!.isVisible {
            self.dynamicNotch!.hide()
            self.previewController.close()

            if let window = WindowEngine.frontmostWindow,
               let screen = NSScreen.screenWithMouse {
                WindowEngine.resize(window, to: self.currentAction, on: screen)
            }

            self.currentAction = .init(.noAction)
        }
    }
}
