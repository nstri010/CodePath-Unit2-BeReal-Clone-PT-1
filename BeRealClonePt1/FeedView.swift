//
//  FeedView.swift
//  BeRealClonePt1
//
//  Created by Nakisha S. on 9/23/25.
//

import SwiftUI
import ParseSwift

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var status: String = ""
    @State private var loading = false
    @State private var showComposer = false

    var body: some View {
        NavigationView {
            Group {
                if loading && posts.isEmpty {
                    ProgressView("Loading…")
                        .padding()
                } else if !status.isEmpty && posts.isEmpty {
                    Text(status)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List(posts) { post in
                        PostRow(post: post)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    }
                    .listStyle(.plain)
                    .refreshable { fetchPosts() }
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showComposer = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                    .accessibilityLabel("New post")
                }
            }
        }
        .sheet(isPresented: $showComposer, onDismiss: fetchPosts) {
            PostComposerView()
        }
        .onAppear { fetchPosts() }
    }

    private func fetchPosts() {
        status = "Loading…"
        loading = true

        let q = Post.query()
            .include("user")
            .order([.descending("createdAt")])

        q.find { result in
            DispatchQueue.main.async {
                loading = false
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
}

// MARK: - Row
private struct PostRow: View {
    let post: Post

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(post.authorUsername ?? post.user?.username ?? "Anonymous")
                    .font(.headline)
                Spacer()
                if let date = post.takenAt ?? post.createdAt {
                    Text(Self.df.string(from: date))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if let file = post.imageFile,
               let url = file.url {
                
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.12))
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity, minHeight: 240)

                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.12))
                            Image(systemName: "photo")
                                .imageScale(.large)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 240)

                    @unknown default:
                        EmptyView()
                    }
                }
            }

            if let caption = post.caption, !caption.isEmpty {
                Text(caption)
                    .font(.body)
            }

            if let name = post.locationName, !name.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(name)
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private static let df: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
}
