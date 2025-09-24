//
//  FeedView.swift
//  BeRealClonePt1
//
//  Created by Nakisha S. on 9/23/25.
//

import SwiftUI
import ParseSwift

struct FeedView: View {
    @State private var status = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Your Feed")
                    .font(.largeTitle).bold()

                Text(status)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") { logOut() }
                }
            }
        }
    }

    private func logOut() {
        User.logout { result in
            switch result {
            case .success:
                status = "👋 Logged out"
                // Tell the app to switch back to AuthView
                NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
            case .failure(let error):
                status = "❌ \(error.localizedDescription)"
            }
        }
    }
}
