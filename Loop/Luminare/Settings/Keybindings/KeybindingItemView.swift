//
//  KeybindingItemView.swift
//  Loop
//
//  Created by Kai Azim on 2024-05-03.
//

import SwiftUI
import Luminare
import Defaults

struct KeybindingItemView: View {
    @Environment(\.hoveringOverLuminareListItem) var isHovering

    @Default(.triggerKey) var triggerKey
    @Binding var keybind: WindowAction

    @State var isConfiguringCustom: Bool = false
    @State var isConfiguringCycle: Bool = false

    let cycleIndex: Int?

    init(_ keybind: Binding<WindowAction>, cycleIndex: Int? = nil) {
        self._keybind = keybind
        self.cycleIndex = cycleIndex
    }

    var body: some View {
        HStack {
            label()

            HStack {
                if keybind.direction == .custom {
                    Button(action: {
                        isConfiguringCustom = true
                    }, label: {
                        Image(systemName: "slider.horizontal.3")
                    })
                    .buttonStyle(.plain)
                    .luminareModal(isPresented: $isConfiguringCustom) {
                        CustomActionConfigurationView(action: $keybind, isPresented: $isConfiguringCustom)
                            .frame(width: 400)
                    }
                }

                if keybind.direction == .cycle {
                    Button(action: {
                        isConfiguringCycle = true
                    }, label: {
                        Image(systemName: "arrow.2.squarepath")
                    })
                    .buttonStyle(.plain)
                    .luminareModal(isPresented: $isConfiguringCycle) {
                        CycleActionConfigurationView(action: $keybind, isPresented: $isConfiguringCycle)
                            .frame(width: 400)
                    }
                }

                if isHovering {
                    WindowDirectionPicker($keybind, isCycle: cycleIndex != nil)
                        .equatable()
                }
            }
            .font(.title3)
            .foregroundStyle(isHovering ? .primary : .secondary)

            Spacer()

            if let cycleIndex = cycleIndex {
                Text("\(cycleIndex)")
                    .frame(width: 27, height: 27)
                    .modifier(LuminareBordered())
            } else {
                HStack(spacing: 6) {
                    HStack {
                        ForEach(triggerKey.sorted().compactMap { $0.systemImage }, id: \.self) { image in
                            Text("\(Image(systemName: image))")
                        }
                    }
                    .font(.callout)
                    .padding(6)
                    .frame(height: 27)
                    .modifier(LuminareBordered())

                    Image(systemName: "plus")

                    Keycorder($keybind)
                }
            }
        }
        .padding(.horizontal, 12)
    }

    func label() -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 5) {
                keybind.direction.icon
                Text(keybind.getName())
                    .lineLimit(1)
            }

            if let info = keybind.direction.infoView {
                info
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct WindowDirectionPicker: View, Equatable {
    @Environment(\.hoveringOverLuminareListItem) var isHovering
    @Binding var keybind: WindowAction
    let isCycle: Bool

    init(_ keybind: Binding<WindowAction>, isCycle: Bool = false) {
        self._keybind = keybind
        self.isCycle = isCycle
    }

    var body: some View {
        Menu {
            Menu("General") {
                ForEach(WindowDirection.general) { direction in
                    directionPickerItem(direction)
                }
            }

            Menu("Halves") {
                ForEach(WindowDirection.halves) { direction in
                    directionPickerItem(direction)
                }
            }

            Menu("Quarters") {
                ForEach(WindowDirection.quarters) { direction in
                    directionPickerItem(direction)
                }
            }

            Menu("Horizontal Thirds") {
                ForEach(WindowDirection.horizontalThirds) { direction in
                    directionPickerItem(direction)
                }
            }

            Menu("Vertical Thirds") {
                ForEach(WindowDirection.verticalThirds) { direction in
                    directionPickerItem(direction)
                }
            }

            Menu("Screen Switching") {
                ForEach(WindowDirection.screenSwitching) { direction in
                    directionPickerItem(direction)
                }
            }

            if !isCycle {
                Menu("Grow/Shrink") {
                    ForEach(WindowDirection.sizeAdjustment) { direction in
                        directionPickerItem(direction)
                    }
                    Divider()
                    ForEach(WindowDirection.shrink) { direction in
                        directionPickerItem(direction)
                    }
                    Divider()
                    ForEach(WindowDirection.grow) { direction in
                        directionPickerItem(direction)
                    }
                }
            }

            Menu("More") {
                ForEach(WindowDirection.more) { direction in
                    if isCycle {
                        if direction != .cycle {
                            directionPickerItem(direction)
                        }
                    } else {
                        directionPickerItem(direction)
                    }
                }
            }
        } label: {
            Image(systemName: "pencil")
                .padding(.vertical, 5) // Increase hitbox size
                .contentShape(.rect)
                .padding(.vertical, -5) // So that the picker dropdown doesn't get offsetted by the hitbox
        }
        .buttonStyle(PlainButtonStyle())    // Override Luminare button styling
    }

    func directionPickerItem(_ direction: WindowDirection) -> some View {
        Button(action: {
            keybind.direction = direction
        }, label: {
            HStack {
                direction.icon
                Text(direction.name)
            }
        })
    }

    static func == (lhs: WindowDirectionPicker, rhs: WindowDirectionPicker) -> Bool {
        lhs.keybind == rhs.keybind
    }
}
