//
//  RootView.swift
//  BeRealClonePt1
//
//  Created by Nakisha S. on 9/24/25.
//

import SwiftUI
import ParseSwift

struct RootView: View {

    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = (User.current != nil)

    var body: some View {
        if isLoggedIn && User.current != nil {
            FeedView()
        } else {
            AuthView()
        }
    }
}
