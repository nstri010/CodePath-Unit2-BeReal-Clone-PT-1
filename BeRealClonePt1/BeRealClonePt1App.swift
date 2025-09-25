//
//  BeRealClonePt1App.swift
//  BeRealClonePt1
//
//  Created by Nakisha S. on 9/23/25.
//

import SwiftUI
import ParseSwift

@main
struct BeRealClonePt1App: App {
    @State private var showSplash = true

    private let splashMinDuration: UInt64 = 2_500_000_000

    init() {
        ParseSwift.initialize(
            applicationId: "pyTXM7vg2hyR4Q9bAlwrerpGFpBbduYBCsbcQa1g",
            clientKey: "ocuRuatFbR75HbuDjqXoB7zRzFmh2Gcuro7ibmDn",
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else {
                    RootView()
                        .transition(.opacity)
                }
            }
            .task {
                try? await Task.sleep(nanoseconds: splashMinDuration)
                withAnimation(.easeInOut(duration: 0.35)) {
                    showSplash = false
                }
            }
        }
    }
}


struct SplashView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 12) {
                Image("LaunchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(radius: 6, y: 2)

                Text("BeReal Clone")
                    .font(.system(size: 28, weight: .bold))

                ProgressView()
                    .padding(.top, 6)
            }
        }
    }
}
