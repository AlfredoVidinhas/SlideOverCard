//
//  SlideOverCard.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 30/10/20.
//

import SwiftUI

/// A view that displays a card that slides over from the bottom of the screen
internal struct SlideOverCard<Content: View, Style: ShapeStyle>: View {
    var isPresented: Binding<Bool>
    
    var options: SOCOptions
    let style: SOCStyle<Style>
    let content: Content
    
    init(isPresented: Binding<Bool>,
         options: SOCOptions = [],
         style: SOCStyle<Style> = SOCStyle(),
         content: @escaping () -> Content) {
        self.isPresented = isPresented
        self.options = options
        self.style = style
        self.content = content()
    }
    
    @State private var viewOffset: CGFloat = 0.0
    
    private var isiPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public var body: some View {
        ZStack {
            if isPresented.wrappedValue {
                style.dimmingColor
                    .opacity(style.dimmingOpacity)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .zIndex(1)
                    .onTapGesture {
                        if !options.contains(.disableTapToDismiss) {
                            dismiss()
                        }
                    }
                
                Group {
                    container
                        .ignoresSafeArea(.container, edges: .bottom)
                }
                .transition(isiPad ? .opacity.combined(with: .offset(x: 0, y: 200)) : .move(edge: .bottom))
                .zIndex(2)
                .onAppear {
                    viewOffset = 0
                }
            }
        }
        .animation(.defaultSpring, value: isPresented.wrappedValue)
    }
    
    private var container: some View {
        VStack {
            Spacer()
            
            if isiPad {
                card
                    .aspectRatio(1.0, contentMode: .fit)
                Spacer()
            } else {
                card
            }
        }
    }
    
    private var cardShape: some Shape {
        RoundedRectangle(cornerSize: style.cornerRadii, style: .continuous)
    }
    
    private var card: some View {
        VStack(alignment: .trailing, spacing: 0) {
            if !options.contains(.hideDismissButton) {
                Button(action: dismiss) {
                    SOCDismissButton()
                }
                .frame(width: 24, height: 24)
            }
            
            HStack {
                Spacer()
                content
                    .padding([.horizontal, options.contains(.hideDismissButton) ? .vertical : .bottom], 14)
                Spacer()
            }
        }
        .padding(style.innerPadding)
        .background(Rectangle().fill(style.style))
        .clipShape(cardShape)
        .offset(x: 0, y: viewOffset/pow(2, abs(viewOffset)/500+1))
        .padding(style.outerPadding)
        .gesture(
            options.contains(.disableDrag) ? nil :
                DragGesture()
                .onChanged { value in
                    viewOffset = value.translation.height
                }
                .onEnded { value in
                    if value.predictedEndTranslation.height > 175 && !options.contains(.disableDragToDismiss) {
                        dismiss()
                    } else {
                        withAnimation(.defaultSpring) {
                            viewOffset = 0
                        }
                    }
                }
        )
    }
    
    func dismiss() {
        isPresented.wrappedValue = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.rootViewController?.dismiss(animated: false)
            }
        }
    }
}
