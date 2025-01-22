//
//  SOCManager.swift
//  
//
//  Created by João Gabriel Pozzobon dos Santos on 24/04/21.
//

import SwiftUI
import Combine

/// A manager class that presents a `SlideOverCard`overlay from anywhere in an app
internal class SOCManager<Content: View, Style: ShapeStyle>: ObservableObject {
    @ObservedObject var model: SOCModel
    
    var cardController: UIHostingController<SlideOverCard<Content, Style>>?
    
    var onDismiss: (() -> Void)?
    var content: () -> Content
    var window: UIWindow?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(model: SOCModel,
         onDismiss: (() -> Void)?,
         options: SOCOptions,
         style: SOCStyle<Style>,
         @ViewBuilder content: @escaping () -> Content) {
        self.onDismiss = onDismiss
        self.content = content
        
        self.model = model
        let rootCard = SlideOverCard(model: _model,
                                     options: options,
                                     style: style,
                                     content: content)
        
        cardController = UIHostingController(rootView: rootCard)
        cardController?.view.backgroundColor = .clear
        cardController?.modalPresentationStyle = .overFullScreen
        
        model.$showCard
            .removeDuplicates()
            .sink { [weak self] value in
                if !value {
                    self?.dismiss()
                }
            }
            .store(in: &cancellables)
    }
    
    /// Presents a `SlideOverCard`
    @available(iOSApplicationExtension, unavailable)
    func present() {
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

        rootVC.present(cardController, animated: true) {
            self.model.showCard = true
        }
    }
    
    /// Dismisses a `SlideOverCard`
    @available(iOSApplicationExtension, unavailable)
    func dismiss() {
        guard model.showCard else {
            return
        }
        
        cardController?.dismiss(animated: true) { [weak self] in
            self?.model.showCard = false
        }
    }
    
    func set(colorScheme: ColorScheme) {
        cardController?.overrideUserInterfaceStyle = colorScheme.uiKit
    }
    
    func set(window: UIWindow) {
        self.window = window
    }
}
