//
//  SnappingManager.swift
//  Loop
//
//  Created by Kai Azim on 2023-09-04.
//

import Cocoa

class SnappingManager {

    private var draggingWindow: Window?
    private var initialPosition: CGPoint?
    private var direction: WindowDirection = .noAction

    private let previewController = PreviewController()

    init() {
        self.addObservers()
    }

    func addObservers() {
        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged) { _ in
            // Process window (only ONCE during a window drag)
            if self.draggingWindow == nil {
                guard let mousePosition = NSEvent.mouseLocation.flipY,
                      let draggingWindow = WindowEngine.windowAtPosition(mousePosition) else { return }
                self.draggingWindow = draggingWindow
                self.initialPosition = draggingWindow.position
            }

            if let window = self.draggingWindow,
               let mousePosition = NSEvent.mouseLocation.flipY,
               let screen = NSScreen.screenWithMouse,
               let screenFrame = screen.visibleFrame.flipY,
               self.initialPosition != window.position {
                let ignoredFrame = screenFrame.insetBy(dx: 10, dy: 10)

                if !ignoredFrame.contains(mousePosition) {
                    self.direction = WindowDirection.snapDirection(
                        mouseLocation: mousePosition,
                        screenFrame: screenFrame,
                        ignoredFrame: ignoredFrame
                    )

                    self.previewController.show(screen: screen)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(
                            name: Notification.Name.directionChanged,
                            object: nil,
                            userInfo: ["direction": self.direction]
                        )
                    }
                } else {
                    self.direction = .noAction
                    self.previewController.close()
                }
            }
        }

        NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { _ in
            if let window = self.draggingWindow,
               let screen = NSScreen.screenWithMouse,
               self.initialPosition != window.position {
                WindowEngine.resize(window: window, direction: self.direction, screen: screen)
                self.previewController.close()
            }
            self.draggingWindow = nil
        }
    }
}

extension CGPoint {
    var flipY: CGPoint? {
        guard let screen = NSScreen.screenWithMouse else { return nil }
        return CGPoint(x: self.x, y: screen.frame.maxY - self.y)
    }
}

extension CGRect {
    var flipY: CGRect? {
        guard let screen = NSScreen.screenWithMouse else { return nil }
        return CGRect(
            x: self.minX,
            y: screen.frame.maxY - self.maxY,
            width: self.width,
            height: self.height)
    }
}
