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
    init() {
        ParseSwift.initialize(
            applicationId: "pyTXM7vg2hyR4Q9bAlwrerpGFpBbduYBCsbcQa1g",
            clientKey: "ocuRuatFbR75HbuDjqXoB7zRzFmh2Gcuro7ibmDn",
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// MARK: - Router
struct RootView: View {
    @State private var isLoggedIn: Bool = (User.current != nil)

    var body: some View {
        Group {
            if isLoggedIn {
                FeedView()
            } else {
                AuthView()
            }
        }
        // listen for auth state changes
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("login"))) { _ in
            isLoggedIn = true
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("signout"))) { _ in
            isLoggedIn = false
        }
        .onAppear {
            // persisted session check on cold launch
            isLoggedIn = (User.current != nil)
        }
    }
}
