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
    @State private var isWorking = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("BeReal Clone")
                    .font(.largeTitle).bold()

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal)

                TextField("Email (sign up only)", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal)

                Button {
                    logIn()
                } label: {
                    HStack {
                        if isWorking { ProgressView().padding(.trailing, 6) }
                        Text("Sign In")
                    }
                }
                .disabled(isWorking)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isWorking ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                Button {
                    signUp()
                } label: {
                    HStack {
                        if isWorking { ProgressView().padding(.trailing, 6) }
                        Text("Sign Up")
                    }
                }
                .disabled(isWorking)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isWorking ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                if User.current != nil {
                    NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func signUp() {
        message = ""
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else {
            message = "Please enter a username, email, and password."
            return
        }

        isWorking = true
        var newUser = User()
        newUser.username = username.trimmingCharacters(in: .whitespaces)
        newUser.email = email.trimmingCharacters(in: .whitespaces)
        newUser.password = password

        newUser.signup { result in
            isWorking = false
            switch result {
            case .success(let user):
                message = "✅ Signed up: \(user.username ?? "")"
                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
            case .failure(let error):
                message = userFriendly(error, action: "sign up")
            }
        }
    }

    private func logIn() {
        message = ""
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.isEmpty else {
            message = "Please enter your username and password."
            return
        }

        isWorking = true
        User.login(username: username.trimmingCharacters(in: .whitespaces),
                   password: password) { result in
            isWorking = false
            switch result {
            case .success(let user):
                message = "✅ Signed in: \(user.username ?? "")"
                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
            case .failure(let error):
                message = userFriendly(error, action: "log in")
            }
        }
    }
}

private func userFriendly(_ error: Error, action: String) -> String {
    if let pe = error as? ParseError {
        let code = pe.code
        switch code {
        case .objectNotFound:
            return "Wrong username or password. Please try again."
        case .usernameTaken:
            return "That username is already taken. Please choose another."
        case .invalidEmailAddress:
            return "Please enter a valid email address."
        case .connectionFailed:
            return "Can't reach the server. Check your internet and try again."
        default:
            if code.rawValue == 203 {      
                return "An account already exists with that email."
            }
            return pe.message ?? "Something went wrong while trying to \(action). Please try again."
        }
    }
    let ns = error as NSError
    if ns.code == 101 { return "Wrong username or password. Please try again." }
    if ns.code == 203 { return "An account already exists with that email." }
    return "Something went wrong while trying to \(action). Please try again."
}
