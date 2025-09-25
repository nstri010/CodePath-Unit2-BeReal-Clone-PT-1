//
//  ContentView.swift
//  BeRealClonePt1
//
//  Created by Nakisha S. on 9/23/25.
//

import SwiftUI
import ParseSwift

struct ContentView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var message = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("BeReal Clone")
                .font(.largeTitle)
                .bold()

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)

            Button("Sign Up") {
                signUp()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            Button("Sign In") {
                logIn()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            Button("Sign Out") {
                logOut()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            Text(message)
                .foregroundColor(.blue)
                .padding()
        }
        .padding()
        .onAppear {
            if let currentUser = User.current {
                message = "Hello, \(currentUser.username ?? "")"
            }
        }
    }

    private func signUp() {
        var newUser = User()
        newUser.username = username
        newUser.email = email
        newUser.password = password

        newUser.signup { result in
            switch result {
            case .success(let user):
                message = "✅ Signed up: \(user.username ?? "")"
            case .failure(let error):
                message = "❌ Error: \(error.localizedDescription)"
            }
        }
    }

    private func logIn() {
        User.login(username: username, password: password) { result in
            switch result {
            case .success(let user):
                message = "✅ Logged in: \(user.username ?? "")"
            case .failure(let error):
                message = "❌ Error: \(error.localizedDescription)"
            }
        }
    }

    private func logOut() {
        User.logout { result in
            switch result {
            case .success:
                message = "You have been logged out successfully"
                username = ""
                email = ""
                password = ""
            case .failure(let error):
                message = "❌ Error: \(error.localizedDescription)"
            }
        }
    }
}
