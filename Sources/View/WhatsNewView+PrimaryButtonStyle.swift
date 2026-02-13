import SwiftUI

// MARK: - WhatsNewView+PrimaryButtonStyle

extension WhatsNewView {
    
    /// The WhatsNewView PrimaryButtonStyle
    struct PrimaryButtonStyle {
        
        /// The WhatsNew PrimaryAction
        let primaryAction: WhatsNew.PrimaryAction
        
        /// The WhatsNew Layout
        let layout: WhatsNew.Layout
        
    }
    
}

// MARK: - ButtonStyle

extension WhatsNewView.PrimaryButtonStyle: ButtonStyle {
    
    /// Creates a view that represents the body of a button.
    /// - Parameter configuration: The properties of the button.
    func makeBody(
        configuration: Configuration
    ) -> some View {
        #if os(iOS)
        let buttonContent = HStack {
            Spacer()
            configuration
                .label
                .font(.headline.weight(.semibold))
                .padding(.vertical)
            Spacer()
        }
        .foregroundColor(self.primaryAction.foregroundColor)
        .background(self.primaryAction.backgroundColor)
        
        if #available(iOS 26.0, *) {
            buttonContent
                .clipShape(Capsule())
                .opacity(configuration.isPressed ? 0.5 : 1)
        } else {
            buttonContent
                .cornerRadius(self.layout.footerPrimaryActionButtonCornerRadius)
                .opacity(configuration.isPressed ? 0.5 : 1)
        }
        #else
        Group {
            configuration
                .label
                .padding(.horizontal, 60)
                .padding(.vertical, 8)
        }
        .foregroundColor(self.primaryAction.foregroundColor)
        .background(self.primaryAction.backgroundColor)
        .cornerRadius(self.layout.footerPrimaryActionButtonCornerRadius)
        .opacity(configuration.isPressed ? 0.5 : 1)
        #endif
    }
    
}
