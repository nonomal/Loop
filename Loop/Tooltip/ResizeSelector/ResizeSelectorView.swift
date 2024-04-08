//
//  ResizeSelectorView.swift
//  Loop
//
//  Created by Kai Azim on 2023-08-22.
//

import SwiftUI

struct ResizeSelectorView: View {
    @ObservedObject var tooltipManager: TooltipManager
    let padding: CGFloat = 15
    @State var windowHeight: CGFloat = 0

    var body: some View {
        HStack(spacing: 0) {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ResizeSelectorRectangle(
                        self.tooltipManager,
                        action: .init(.maximize),
                        sectionSize: geo.size,
                        windowHeight: self.windowHeight
                    )
                }
            }
            .modifier(ResizeSelectorGroup())

            Spacer()
                .frame(width: padding)

            GeometryReader { geo in
                HStack(spacing: 0) {
                    ResizeSelectorRectangle(
                        self.tooltipManager,
                        action: .init(.leftHalf),
                        sectionSize: geo.size,
                        windowHeight: self.windowHeight
                    )
                    ResizeSelectorRectangle(
                        self.tooltipManager,
                        action: .init(.rightHalf),
                        sectionSize: geo.size,
                        windowHeight: self.windowHeight
                    )
                }
            }
            .modifier(ResizeSelectorGroup())

            Spacer()
                .frame(width: padding)

            GeometryReader { geo in
                HStack(spacing: 0) {
                    ResizeSelectorRectangle(
                        self.tooltipManager,
                        action: .init(.leftTwoThirds),
                        sectionSize: geo.size,
                        windowHeight: self.windowHeight
                    )
                    ResizeSelectorRectangle(
                        self.tooltipManager,
                        action: .init(.rightThird),
                        sectionSize: geo.size,
                        windowHeight: self.windowHeight
                    )
                }
            }
            .modifier(ResizeSelectorGroup())

            Spacer()
                .frame(width: padding)

            GeometryReader { geo in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ResizeSelectorRectangle(
                            self.tooltipManager,
                            action: .init(.topLeftQuarter),
                            sectionSize: geo.size,
                            windowHeight: self.windowHeight
                        )
                        ResizeSelectorRectangle(
                            self.tooltipManager,
                            action: .init(.topRightQuarter),
                            sectionSize: geo.size,
                            windowHeight: self.windowHeight
                        )

                    }
                    HStack(spacing: 0) {
                        ResizeSelectorRectangle(
                            self.tooltipManager,
                            action: .init(.bottomLeftQuarter),
                            sectionSize: geo.size,
                            windowHeight: self.windowHeight
                        )
                        ResizeSelectorRectangle(
                            self.tooltipManager,
                            action: .init(.bottomRightQuarter),
                            sectionSize: geo.size,
                            windowHeight: self.windowHeight
                        )
                    }
                }
            }
            .modifier(ResizeSelectorGroup())
        }
        .padding(padding)

        .background {
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        self.windowHeight = proxy.size.height
                    }
            }
        }
    }
}

struct ResizeSelectorGroup: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(-2)
            .aspectRatio(16/12, contentMode: .fit)
            .frame(width: 100)
    }
}
