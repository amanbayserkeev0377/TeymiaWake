import SwiftUI

private struct ToggleColorModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .tint(colorScheme == .light ? .black : .secondary)
    }
}

extension View {
    func withToggleColor() -> some View {
        modifier(ToggleColorModifier())
    }
}
