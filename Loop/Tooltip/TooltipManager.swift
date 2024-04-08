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
    private var initialWindowFrame: CGRect?
    private var draggingWindow: Window?
    static var windowOffset: NSRect?
    @Published var screen: NSScreen?
    @Published var mouseEvent: NSEvent?
    @Published var currentAction: WindowAction = .init(.noAction)

    func start() {
        self.tooltipManager = MouseTooltipManager(tooltipManager: self)
        self.dynamicNotch = DynamicNotch(content: ResizeSelectorView(tooltipManager: self))

        self.eventMonitor = NSEventMonitor(
            scope: .global,
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
            let window = self.draggingWindow,
            let screen = self.screen
        else {
            return
        }

        if configuration == .onDrag {
            if self.initialWindowFrame == nil {
                self.initialWindowFrame = window.frame
            }

            if let initialFrame = self.initialWindowFrame,
               hasWindowMoved(window.frame, initialFrame) {

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

    private func hasWindowMoved(_ windowFrame: CGRect, _ initialFrame: CGRect) -> Bool {
        !initialFrame.topLeftPoint.approximatelyEqual(to: windowFrame.topLeftPoint, tolerance: 50) &&
        !initialFrame.topRightPoint.approximatelyEqual(to: windowFrame.topRightPoint, tolerance: 50) &&
        !initialFrame.bottomLeftPoint.approximatelyEqual(to: windowFrame.bottomLeftPoint, tolerance: 50) &&
        !initialFrame.bottomRightPoint.approximatelyEqual(to: windowFrame.bottomRightPoint, tolerance: 50)
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
        self.initialWindowFrame = nil
        TooltipManager.windowOffset = nil

        if forceClose {
            self.didForceClose = true
        }
    }
}
