//
//  RootView.swift
//  BeRealClonePt1
//
//  Created by Nakisha S. on 9/24/25.
//

import SwiftUI
import ParseSwift

struct RootView: View {
    @State private var isLoggedIn = (User.current != nil)

    var body: some View {
        Group {
            if isLoggedIn {
                FeedView()
            } else {
                AuthView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("login"))) { _ in
            isLoggedIn = true
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("logout"))) { _ in
            isLoggedIn = false
        }
        .onAppear {
            isLoggedIn = (User.current != nil)
        }
    }
}
