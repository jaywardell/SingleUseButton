//
//  SingleUseButton.swift
//  SFSymbols In Toolbar Tests
//
//  Created by Joseph Wardell on 1/4/25.
//

import SwiftUI

/// A button that presents the user with the option to do something once.
///
/// Before the button has been tapped, it presents itself as a button.
/// When it's tapped, it animates a change between its images and its background.
/// After it's been tapped, it presents itself as a label colored in the accent color.
///
/// If it's tapped a second time, it just animates to show that it was tapped.
/// Its action is not triggered again.
@available(iOS 15.0, macOS 14.0, *)
public struct SingleUseButton<ButtonShape: Shape>: View {
    
    let actionTitle: String
    let actionImageName: String
    
    let finishedTitle: String
    let finishedImageName: String
        
    let action: () -> Void
    
    let buttonShape: ButtonShape
    
    @ScaledMetric var horizontalPadding = 3
    @ScaledMetric var verticalPadding = 3

    /// Create a SingleUseButton
    /// - Parameters:
    ///   - actionTitle: the title of the button before it's pressed
    ///   - actionImageName: the name of the system image before the button is pressed, defaults to empty string
    ///   - finishedTitle: the title of the button after it's pressed
    ///   - finishedImageName: the name of the system image after the button is pressed, defaults to empty string
    ///   - shape: the border shape of the button before it's pressed (after it's pressed there's no border)
    ///   - action: the action that runs when the button is pressed
    public init(
        actionTitle: String,
        actionImageName: String = "",
        finishedTitle: String,
        finishedImageName: String = "",
        shape: ButtonShape,
        finishedAction: @escaping () -> Void
    ) {
        self.actionTitle = actionTitle
        self.actionImageName = actionImageName
        self.finishedTitle = finishedTitle
        self.finishedImageName = finishedImageName
        self.action = finishedAction
        self.buttonShape = shape
    }
    
    @State private var trigger = false
    @State private var hasBeenTriggered = false

    @Environment(\.colorScheme) var colorScheme

    private var longestTitle: String {
        actionTitle.count > finishedTitle.count ? actionTitle : finishedTitle
    }
    
    private var buttonTextColor: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemBackground)
        #elseif canImport(AppKit)
        Color(nsColor: colorScheme == .dark ? .selectedControlTextColor : .windowBackgroundColor)
        #endif
    }
    
    public var body: some View {
        Toggle(isOn: $trigger) {
            Label {
                ZStack(alignment: .leading) {
                    Text(trigger ? finishedTitle : actionTitle)
                    // ensure that the size of this part is alwasy the same
                    // so make sure that it's big enough
                    // to contain either string safely
                    Text(longestTitle)
                        .padding(longestTitle == finishedTitle ? .none : .trailing, horizontalPadding)
                        .hidden()
                }
            } icon: {
                Image(systemName: trigger ? finishedImageName: actionImageName)
            }
        }
        .padding(.trailing, buttonShape is Capsule ? horizontalPadding * 3 : horizontalPadding)
        .padding(.leading, buttonShape is Capsule ? 0 : horizontalPadding)
        .padding(.vertical, buttonShape is Capsule ? 0 : verticalPadding)
        
        .toggleStyle(SingleUseToggleButtonStyle())
        .foregroundStyle(
            LinearGradient(
                stops: [
                    .init(color: .accentColor, location: 0),
                    .init(color: hasBeenTriggered ? .accentColor : buttonTextColor, location: hasBeenTriggered ? 1 : 0),
                    .init(color: buttonTextColor, location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .topTrailing
            )
        )
        .background {
            buttonShape.fill(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: hasBeenTriggered ? .clear : .accentColor, location: hasBeenTriggered ? 1 : 0),
                        .init(color: .accentColor, location: 1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .topTrailing
                )
            )
        }
        .contentTransition(.symbolEffect(.replace))
        .onChange(of: trigger) { _, _ in
            guard !hasBeenTriggered else {
                trigger = true
                return
            }
            action()
            withAnimation {
                hasBeenTriggered = true
            }
        }
        .accessibilityLabel(hasBeenTriggered ? finishedTitle : "\(actionTitle) button")
    }
}

@available(iOS 15.0, macOS 14.0, *)
public extension SingleUseButton where ButtonShape == ButtonBorderShape {

    /// Create a SingleUseButton
    /// - Parameters:
    ///   - actionTitle: the title of the button before it's pressed
    ///   - actionImageName: the name of the system image before the button is pressed, defaults to empty string
    ///   - finishedTitle: the title of the button after it's pressed
    ///   - finishedImageName: the name of the system image after the button is pressed, defaults to empty string
    ///   - shape: the border shape of the button before it's pressed (after it's pressed there's no border)
    ///   - action: the action that runs when the button is pressed
    init(
        actionTitle: String,
        actionImageName: String = "",
        finishedTitle: String,
        finishedImageName: String = "",
        finishedAction: @escaping () -> Void
    ) {
        self.actionTitle = actionTitle
        self.actionImageName = actionImageName
        self.finishedTitle = finishedTitle
        self.finishedImageName = finishedImageName
        self.action = finishedAction
        self.buttonShape = .buttonBorder
    }
}

@available(iOS 15.0, macOS 14.0, *)
struct SingleUseToggleButtonStyle: ToggleStyle {
    
    @ScaledMetric var horizontalPadding = 2

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
//                .padding(.leading)
                .padding(.leading, horizontalPadding)
        }
        .buttonStyle(.borderless)
    }
    
}

@available(iOS 15.0, macOS 14.0, *)
#Preview {
    VStack(spacing: 55) {
        SingleUseButton(
            actionTitle: "Bookmark",
            actionImageName: "bookmark",
            finishedTitle: "Bookmarked",
            finishedImageName: "checkmark"
        ) {
            print("bookmark button was pressed")
        }

        SingleUseButton(
            actionTitle: "Find My Location",
            actionImageName: "location.magnifyingglass",
            finishedTitle: "Location Found",
            finishedImageName: "globe",
            shape: Capsule()
        ) {
            print("bookmark button was pressed")
        }

        SingleUseButton(actionTitle: "Who's your Daddy?", actionImageName: "questionmark", finishedTitle: "I am", finishedImageName: "person") {
            print("bookmark button was pressed")
        }

        SingleUseButton(
            actionTitle: "What time is it?",
            finishedTitle: "4:30") {
            print("bookmark button was pressed")
        }
        .foregroundStyle(Color.accentColor)
        .font(.largeTitle)
        
    }
    .font(.largeTitle)

    #if os(macOS)
    .padding()
    #endif
}

