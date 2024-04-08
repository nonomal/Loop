//
//  TooltipManager.swift
//  Loop
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI
import Defaults
import DynamicNotchKit

class TooltipManager: ObservableObject {
    private var eventMonitor: EventMonitor?
    private let previewController = PreviewController()
    private var tooltipManager: MouseTooltipManager?
    private var dynamicNotch: DynamicNotch?

    private var didForceClose: Bool = false // This is auto-reset once the user stops dragging
    private var initialMousePosition: NSPoint?
    private var draggingWindow: Window?
    static var windowOffset: NSRect?
    @Published var screen: NSScreen?
    @Published var mouseEvent: NSEvent?
    @Published var currentAction: WindowAction = .init(.noAction)

    func start() {
        self.tooltipManager = MouseTooltipManager(tooltipManager: self)
        self.dynamicNotch = DynamicNotch(content: ResizeSelectorView(tooltipManager: self))

        self.eventMonitor = NSEventMonitor(
            scope: .all,
            eventMask: [.leftMouseDragged, .leftMouseUp, .keyDown]
        ) { event in
            if event.type == .leftMouseDragged {
                self.leftMouseDragged(event: event)
            }

            if event.type == .leftMouseUp {
                self.leftMouseUp()
            }

            if event.type == .keyDown,
               event.keyCode == .kVK_Escape {
                self.close(forceClose: true)
            }
        }

        self.eventMonitor!.start()
    }

    func leftMouseDragged(event: NSEvent) {
        let configuration = Defaults[.tooltipConfiguration]
        guard configuration != .off && !self.didForceClose else { return }

        self.mouseEvent = event

        if self.screen == nil,
           let screenWithMouse = NSScreen.screenWithMouse {
            self.screen = screenWithMouse

            if TooltipManager.windowOffset == nil {
                TooltipManager.windowOffset = screenWithMouse.frame
            }
        }

        if self.draggingWindow == nil {
            self.draggingWindow = WindowEngine.frontmostWindow
        }

        guard
            self.draggingWindow != nil,
            let screen = self.screen
        else {
            return
        }

        if configuration == .onDrag {
            if self.initialMousePosition == nil {
                self.initialMousePosition = NSEvent.mouseLocation
            }

            guard let initialMousePosition = self.initialMousePosition else {
                return
            }

            // If mouse has moved > 50 pixels (2500 cause 50^2)
            if initialMousePosition.distanceSquared(to: NSEvent.mouseLocation) > 2500 {
                guard let tooltipManager = self.tooltipManager else {
                    return
                }
                tooltipManager.open()
                self.previewController.open(screen: screen)
            }

        } else { // configuration would be .notch
            guard self.dynamicNotch != nil else {
                return
            }

            if self.dynamicNotch!.checkIfMouseIsInNotch() {
                self.dynamicNotch!.show(on: screen)
                self.previewController.open(screen: screen)
            }

            if self.dynamicNotch!.isVisible,
               let screenWithMouse = NSScreen.screenWithMouse,
               self.screen != screenWithMouse {

                self.dynamicNotch?.hide()
                self.previewController.close()
                self.currentAction = .init(.noAction)
            }
        }
    }

    func leftMouseUp() {
        let configuration = Defaults[.tooltipConfiguration]
        guard configuration != .off else { return }

        let shouldResize =  self.tooltipManager?.isVisible ?? false || self.dynamicNotch?.isVisible ?? false
        self.close(forceClose: !shouldResize)
        self.didForceClose = false
    }

    private func close(forceClose: Bool = false) {
        self.tooltipManager?.close()
        self.dynamicNotch?.hide()
        self.previewController.close()

        if !forceClose, let window = self.draggingWindow, let screen = self.screen {
            WindowEngine.resize(window, to: self.currentAction, on: screen)
        }

        self.screen = nil
        self.currentAction = .init(.noAction)
        self.draggingWindow = nil
        self.initialMousePosition = nil
        TooltipManager.windowOffset = nil

        if forceClose {
            self.didForceClose = true
        }
    }
}
