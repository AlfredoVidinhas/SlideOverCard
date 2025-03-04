import SwiftUI
import Combine

internal struct SOCModifier<ViewContent: View, Style: ShapeStyle>: ViewModifier {
    @Binding var isPresented: Bool
    
    private var cardController: UIHostingController<SlideOverCard<ViewContent, Style>>?
    
    init(isPresented: Binding<Bool>,
         options: SOCOptions,
         style: SOCStyle<Style>,
         @ViewBuilder content: @escaping () -> ViewContent) {
        self._isPresented = isPresented
        
        let rootCard = SlideOverCard(isPresented: isPresented, options: options, style: style, content: content)
        cardController = UIHostingController(rootView: rootCard)
        cardController?.view.backgroundColor = .clear
        cardController?.modalPresentationStyle = .overFullScreen
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { oldValue, newValue in
                newValue ? present() : dismiss()
            }
    }
    
    private func present() {
        guard let cardController else { return }
        
        if cardController.presentingViewController != nil {
            return
        }
        
        guard let keyWindow = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }),
        let rootVC = keyWindow.rootViewController?.topMostViewController() else {
            return
        }
        
        rootVC.present(cardController, animated: true)
    }
    
    private func dismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.rootViewController?.dismiss(animated: false)
            }
        }
    }
}
