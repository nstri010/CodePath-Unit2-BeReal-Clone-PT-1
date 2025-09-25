//
//  AuthView.swift
//  BeRealClonePt1
//
//  Created by Nakisha S. on 9/23/25.
//

import SwiftUI
import ParseSwift

struct AuthView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""

    // RootView watches this
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("BeReal Clone")
                    .font(.largeTitle).bold()

                // Username
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal)

                // Email
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal)

                // Password
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal)

                // Sign In first
                Button("Sign In") { logIn() }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                // Sign Up second
                Button("Sign Up") { signUp() }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                Text(message)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)

                Spacer()
            }
            .padding(.top, 32)
        }
    }

    // MARK: - Actions

    private func signUp() {
        var user = User()
        user.username = username
        user.email = email
        user.password = password

        user.signup { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    message = "✅ Account created. You're in!"
                    isLoggedIn = true
                case .failure(let error):
                    message = userFriendly(error, action: "sign up")
                }
            }
        }
    }

    private func logIn() {
        User.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    message = "✅ Welcome back!"
                    isLoggedIn = true
                case .failure(let error):
                    message = userFriendly(error, action: "sign in")
                }
            }
        }
    }

    // MARK: - Friendly error text
    private func userFriendly(_ error: Error, action: String) -> String {
        if let pe = error as? ParseError {
            switch pe.code {
            case .objectNotFound:          return "Wrong username or password. Please try again."
            case .usernameTaken:           return "That username is already taken."
            case .invalidEmailAddress:     return "Please enter a valid email address."
            case .connectionFailed:        return "Can't reach the server. Check your internet and try again."
            default: break
            }
        }
        return "Couldn't \(action). \(error.localizedDescription)"
    }
}
