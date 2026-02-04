//
//  LaunchScreenView.swift
//  WildLog
//
//  Created by Avanish Davuluri on 2/2/26.
//

// Basic animation idea: https://holyswift.app/animated-launch-screen-in-swiftui/

import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    @State private var firstAnimation = false
    @State private var startFadeOutAnimation = false
    
    @ViewBuilder
    private var image: some View {
        Image("TestImage")
            .resizable()
            .scaledToFit()
            .frame(width: 275, height: 275)
            // Having only small rotation like in Taco Bell app
            .rotationEffect(firstAnimation ? Angle(degrees: 9) : Angle(degrees: 20))
    }
    
    @ViewBuilder
    private var backgroundColor: some View {
        // Ignore safe area makes the top part near the pill green too
        // I think using green is fine for both light and dark mode
        // The background remover tool I used isn't perfect, so using green hides this too
        Color(.systemGreen).ignoresSafeArea()
    }
    
    private let animationTimer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            backgroundColor
            image
        }.onReceive(animationTimer) { timerValue in
            updateAnimation()
        }.opacity(startFadeOutAnimation ? 0 : 1)
    }
    
    private func updateAnimation() {
        switch launchScreenState.state {
        case .firstStep:
            withAnimation(.easeInOut(duration: 0.9)) {
                firstAnimation.toggle()
            }
            
        case .finished:
            break
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView().environmentObject(LaunchScreenStateManager())
    }
}
