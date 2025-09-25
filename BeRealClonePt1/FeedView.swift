//
//  FeedView.swift
//  BeRealClonePt1
//
//  Created by Nakisha S. on 9/23/25.
//

import SwiftUI
import ParseSwift
import CoreLocation

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var status: String = ""
    @State private var showingComposer = false

    // RootView watches this
    @AppStorage("isLoggedIn") private var isLoggedIn = true

    var body: some View {
        NavigationStack {
            Group {
                if posts.isEmpty && !status.isEmpty {
                    Text(status).foregroundColor(.secondary)
                } else {
                    List(posts) { post in
                        PostRow(post: post)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .refreshable { fetchPosts() }
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") { signOut() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingComposer = true
                    } label: {
                        Image(systemName: "plus.circle.fill").imageScale(.large)
                    }
                }
            }
            .task { fetchPosts() }
            .sheet(isPresented: $showingComposer, onDismiss: { fetchPosts() }) {
                PostComposerView()
            }
        }
    }

    // MARK: - Data
    private func fetchPosts() {
        status = "Loading…"
        let q = Post
            .query()
            .include("user")                    // fetch author relationship
            .order([.descending("createdAt")])  // newest first

        q.find { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    posts = fetched
                    status = fetched.isEmpty ? "No posts yet" : ""
                case .failure(let error):
                    status = "❌ \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Auth
    private func signOut() {
        User.logout { _ in
            DispatchQueue.main.async {
                isLoggedIn = false   // flips RootView back to AuthView
            }
        }
    }
}

// MARK: - Row
private struct PostRow: View {
    let post: Post
    private static let df: DateFormatter = {
        let d = DateFormatter()
        d.dateStyle = .medium
        d.timeStyle = .short
        return d
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(post.authorUsername ?? (post.user?.username ?? "Anonymous"))
                    .font(.headline)
                Spacer()
                if let date = post.takenAt ?? post.createdAt {
                    Text(Self.df.string(from: date))
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }

            // Image
            if let file = post.imageFile, let url = file.url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 220)
                            ProgressView()
                        }
                    case .success(let img):
                        img
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 380)
                            .clipped()
                            .cornerRadius(12)
                    case .failure:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.1))
                            .frame(height: 220)
                            .overlay(Text("Failed to load image").foregroundColor(.secondary))
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            // Caption
            if let caption = post.caption, !caption.isEmpty {
                Text(caption)
            }

            // Location
            if let name = post.locationName, !name.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(name)
                }
                .foregroundColor(.secondary)
                .font(.caption)
            }
        }
        .padding(.vertical, 6)
    }
}
