import SwiftUI

// MARK: - WhatsNewView

/// A WhatsNewView
public struct WhatsNewView {
    
    // MARK: Properties
    
    /// The WhatsNew object
    private let whatsNew: WhatsNew
    
    /// The WhatsNewVersionStore
    private let whatsNewVersionStore: WhatsNewVersionStore?
    
    /// The WhatsNew Layout
    private let layout: WhatsNew.Layout
    
    /// The View that is presented by the SecondaryAction
    @State
    private var secondaryActionPresentedView: WhatsNew.SecondaryAction.Action.PresentedView?
    
    /// The PresentationMode
    @Environment(\.presentationMode)
    private var presentationMode
    
    // MARK: Initializer
    
    /// Creates a new instance of `WhatsNewView`
    /// - Parameters:
    ///   - whatsNew: The WhatsNew object
    ///   - versionStore: The optional WhatsNewVersionStore. Default value `nil`
    ///   - layout: The WhatsNew Layout. Default value `.default`
    public init(
        whatsNew: WhatsNew,
        versionStore: WhatsNewVersionStore? = nil,
        layout: WhatsNew.Layout = .default
    ) {
        self.whatsNew = whatsNew
        self.whatsNewVersionStore = versionStore
        self.layout = layout
    }
    
}

// MARK: - View

extension WhatsNewView: View {
    
    /// The content and behavior of the view.
    public var body: some View {
        self.contentView
        .overlay(
            alignment: .topTrailing
        ) {
            self.closeButton
                .padding(.top, 16)
                .padding(.trailing, 20)
        }
        .sheet(
            item: self.$secondaryActionPresentedView,
            content: { $0.view }
        )
        .onDisappear {
            // Save presented WhatsNew Version, if available
            self.whatsNewVersionStore?.save(
                presentedVersion: self.whatsNew.version
            )
        }
    }
    
}

// MARK: - ContentView

private extension WhatsNewView {
    
    /// The close button that performs the primary dismiss action.
    var closeButton: some View {
        Button(
            action: self.performPrimaryDismissAction
        ) {
            Image(systemName: "xmark")
                .font(.headline.weight(.semibold))
                .foregroundColor(.secondary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }
    
    /// The WhatsNew content view with platform-specific footer presentation.
    @ViewBuilder
    var contentView: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            self.scrollView
                .safeAreaBar(
                    edge: .bottom,
                    alignment: .center,
                    spacing: .zero
                ) {
                    self.footerWithPadding
                }
        } else if #available(iOS 15.0, *) {
            self.scrollView
                .safeAreaInset(
                    edge: .bottom,
                    alignment: .center,
                    spacing: .zero
                ) {
                    self.footerWithLegacyBlur
                }
        }
        #else
        ZStack {
            self.scrollView
            VStack {
                Spacer()
                self.footerWithPadding
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        #endif
    }
    
    /// The content ScrollView.
    var scrollView: some View {
        ScrollView(
            .vertical,
            showsIndicators: self.layout.showsScrollViewIndicators
        ) {
            // Content Stack
            VStack(
                spacing: self.layout.contentSpacing
            ) {
                // Title
                self.title
                // Feature List
                VStack(
                    alignment: .leading,
                    spacing: self.layout.featureListSpacing
                ) {
                    // Feature
                    ForEach(
                        self.whatsNew.features,
                        id: \.self,
                        content: self.feature
                    )
                }
                .modifier(FeaturesPadding())
                .padding(self.layout.featureListPadding)
            }
            .padding(.horizontal)
            .padding(self.layout.contentPadding)
            // ScrollView bottom content inset
            Color.clear
                .padding(
                    .bottom,
                    self.layout.scrollViewBottomContentInset
                )
        }
        #if os(iOS)
        .alwaysBounceVertical(false)
        #endif
    }
    
    /// The footer with the configured padding modifier.
    var footerWithPadding: some View {
        self.footer
            .modifier(FooterPadding())
    }
    
    /// The footer with legacy visual effect background.
    var footerWithLegacyBlur: some View {
        self.footerWithPadding
            .background(
                UIVisualEffectView
                    .Representable()
                    .edgesIgnoringSafeArea(.horizontal)
                    .padding(self.layout.footerVisualEffectViewPadding)
            )
    }

    func performPrimaryDismissAction() {
        // Invoke HapticFeedback, if available
        self.whatsNew.primaryAction.hapticFeedback?()
        // Dismiss
        self.presentationMode.wrappedValue.dismiss()
        // Invoke on dismiss, if available
        self.whatsNew.primaryAction.onDismiss?()
    }
}

// MARK: - Title

private extension WhatsNewView {
    
    /// The Title View
    var title: some View {
        Text(
            whatsNewText: self.whatsNew.title.text
        )
        .font(.largeTitle.bold())
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }
    
}

// MARK: - Feature

private extension WhatsNewView {
    
    /// The Feature View
    /// - Parameter feature: A WhatsNew Feature
    func feature(
        _ feature: WhatsNew.Feature
    ) -> some View {
        HStack(
            alignment: self.layout.featureHorizontalAlignment,
            spacing: self.layout.featureHorizontalSpacing
        ) {
            feature
                .image
                .view()
                .frame(width: self.layout.featureImageWidth)
            VStack(
                alignment: .leading,
                spacing: self.layout.featureVerticalSpacing
            ) {
                Text(
                    whatsNewText: feature.title
                )
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                Text(
                    whatsNewText: feature.subtitle
                )
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            .multilineTextAlignment(.leading)
        }.accessibilityElement(children: .combine)
    }
    
}

// MARK: - Footer

private extension WhatsNewView {
    
    /// The Footer View
    var footer: some View {
        VStack(
            spacing: self.layout.footerActionSpacing
        ) {
            // Check if a secondary action is available
            if let secondaryAction = self.whatsNew.secondaryAction {
                // Secondary Action Button
                Button(
                    action: {
                        // Invoke HapticFeedback, if available
                        secondaryAction.hapticFeedback?()
                        // Switch on Action
                        switch secondaryAction.action {
                        case .present(let view):
                            // Set secondary action presented view
                            self.secondaryActionPresentedView = .init(view: view)
                        case .custom(let action):
                            // Invoke action with PresentationMode
                            action(self.presentationMode)
                        }
                    }
                ) {
                    Text(
                        whatsNewText: secondaryAction.title
                    )
                }
                #if os(macOS)
                .buttonStyle(
                    PlainButtonStyle()
                )
                #endif
                .foregroundColor(secondaryAction.foregroundColor)
            }
            // Primary Action Button
            Button(
                action: self.performPrimaryDismissAction
            ) {
                Text(
                    whatsNewText: self.whatsNew.primaryAction.title
                )
            }
            .buttonStyle(
                PrimaryButtonStyle(
                    primaryAction: self.whatsNew.primaryAction,
                    layout: self.layout
                )
            )
            #if os(macOS)
            .keyboardShortcut(.defaultAction)
            #endif
        }
    }
    
}
