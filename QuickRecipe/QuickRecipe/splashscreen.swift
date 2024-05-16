//
//  splashscreen.swift
//  MixnMatch
//
//  Created by Rishi Saimshu Reddy Bandi on 3/7/24.
//

import SwiftUI

struct ShowSplashScreen: View {
    @State private var isActive = false
    var body: some View {
        if isActive {
            WalkthroughView()
        }else {
            SplashScreen(isActive: $isActive)
        }
    }
}


struct SplashScreen: View {
    @State private var scale = 0.5
    @Binding var isActive: Bool
    var body: some View {
        VStack {
            VStack {
                VStack{
                    Image("logo")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                    Text("MixNMatch")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                }.padding(.bottom)
                VStack{
                    Text("Prudhvi Teja Puli").font(.system(size: 15))
                        .fontWeight(.bold)
                    Text("Rishi Saimshu Reddy Bandi").font(.system(size: 15))
                        .fontWeight(.bold)
                }.padding(.top)
            }.scaleEffect(scale)
            .onAppear{
                withAnimation(.easeIn(duration: 0.7)) {
                    self.scale = 1
                }
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

#Preview {
    ShowSplashScreen()
}
