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

    private var screen: NSScreen?
    private var draggingWindow: Window?
    static var windowOffset: NSRect?
    @Published var mouseEvent: NSEvent?
    @Published var currentAction: WindowAction = .init(.noAction)

    init() {}

    func start() {
        self.tooltipManager = MouseTooltipManager(tooltipManager: self)
        self.dynamicNotch = DynamicNotch(content: ResizeSelectorView(tooltipManager: self))

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
        let configuration = Defaults[.tooltipConfiguration]
        guard configuration != .off else { return }

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
            guard let tooltipManager = self.tooltipManager else {
                return
            }
            tooltipManager.open()

        } else { // configuration would be .notch
            guard let dynamicNotch = self.dynamicNotch else {
                return
            }

            if dynamicNotch.checkIfMouseIsInNotch() {
                self.dynamicNotch!.show(on: screen)
                self.previewController.open(screen: screen)
            }

            if dynamicNotch.isVisible,
               let screenWithMouse = NSScreen.screenWithMouse,
               self.screen != screenWithMouse {

                dynamicNotch.hide()
                self.previewController.close()
                self.currentAction = .init(.noAction)
            }
        }
    }

    func leftMouseUp() {
        let configuration = Defaults[.tooltipConfiguration]
        guard configuration != .off else { return }

        let shouldResize: Bool = self.tooltipManager?.isVisible ?? false || self.dynamicNotch?.isVisible ?? false

        self.tooltipManager?.close()
        self.dynamicNotch?.hide()
        self.previewController.close()

        if shouldResize, let window = self.draggingWindow, let screen = self.screen {
            WindowEngine.resize(window, to: self.currentAction, on: screen)
        }

        self.screen = nil
        self.currentAction = .init(.noAction)
        self.draggingWindow = nil
        TooltipManager.windowOffset = nil
    }
}
