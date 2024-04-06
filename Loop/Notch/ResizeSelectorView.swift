//
//  ResizeSelectorView.swift
//  Loop
//
//  Created by Kai Azim on 2023-08-22.
//

import SwiftUI

struct ResizeSelectorView: View {
    @ObservedObject var notchSnapper: NotchSnapper
    let padding: CGFloat = 15

    var body: some View {
        HStack(spacing: 0) {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ResizeSelectorRectangle(self.notchSnapper, action: .init(.maximize), parentSize: geo.size)
                }
            }
            .resizeSelectorGroup(notchSnapper: self.notchSnapper)

            Spacer()
                .frame(width: padding)

            GeometryReader { geo in
                HStack(spacing: 0) {
                    ResizeSelectorRectangle(self.notchSnapper, action: .init(.leftHalf), parentSize: geo.size)
                    ResizeSelectorRectangle(self.notchSnapper, action: .init(.rightHalf), parentSize: geo.size)
                }
            }
            .resizeSelectorGroup(notchSnapper: self.notchSnapper)

            Spacer()
                .frame(width: padding)

            GeometryReader { geo in
                HStack(spacing: 0) {
                    ResizeSelectorRectangle(self.notchSnapper, action: .init(.leftTwoThirds), parentSize: geo.size)
                    ResizeSelectorRectangle(self.notchSnapper, action: .init(.rightThird), parentSize: geo.size)
                }
            }
            .resizeSelectorGroup(notchSnapper: self.notchSnapper)

            Spacer()
                .frame(width: padding)

            GeometryReader { geo in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ResizeSelectorRectangle(self.notchSnapper, action: .init(.topLeftQuarter), parentSize: geo.size)
                        ResizeSelectorRectangle(self.notchSnapper, action: .init(.topRightQuarter), parentSize: geo.size)

                    }
                    HStack(spacing: 0) {
                        ResizeSelectorRectangle(self.notchSnapper, action: .init(.bottomLeftQuarter), parentSize: geo.size)
                        ResizeSelectorRectangle(self.notchSnapper, action: .init(.bottomRightQuarter), parentSize: geo.size)
                    }
                }
            }
            .resizeSelectorGroup(notchSnapper: self.notchSnapper)
        }
        .padding(padding)
    }
}

extension View {
    func resizeSelectorGroup(notchSnapper: NotchSnapper) -> some View {
        modifier(ResizeSelectorGroup(notchSnapper: notchSnapper))
    }
}

struct ResizeSelectorGroup: ViewModifier {
    let notchSnapper: NotchSnapper
    func body(content: Content) -> some View {
        content
            .padding(-2)
            .aspectRatio(16/12, contentMode: .fit)
            .frame(width: 100)
    }
}
