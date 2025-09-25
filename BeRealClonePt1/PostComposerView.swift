//
//  PostComposerView.swift
//  BeRealClonePt1
//
//  Created by Nakisha S. on 9/24/25.
//

import SwiftUI
import PhotosUI
import CoreLocation
import ParseSwift

final class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var lastLocation: CLLocation?
    @Published var placemark: CLPlacemark?

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
    }

    func request() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        DispatchQueue.main.async { self.lastLocation = loc }
        geocoder.reverseGeocodeLocation(loc) { [weak self] placemarks, _ in
            DispatchQueue.main.async { self?.placemark = placemarks?.first }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        print("Location error:", error.localizedDescription)
    }
}

struct PostComposerView: View {
    @Environment(\.dismiss) private var dismiss
    var onPosted: (() -> Void)? = nil

    @State private var caption = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var isSaving = false
    @State private var errorMessage = ""

    @StateObject private var loc = LocationHelper()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    Group {
                        if let data = imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.secondary, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .frame(height: 220)
                                Text("Pick a photo")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .onChange(of: pickerItem) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                await MainActor.run { self.imageData = data }
                            }
                        }
                    }

                    TextField("Add a caption…", text: $caption, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)

                    if let name = locationPreview {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.and.ellipse")
                            Text(name)
                            Spacer()
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Posting…" : "Post") { savePost() }
                        .disabled(isSaving || imageData == nil)
                }
            }
            .onAppear { loc.request() }
        }
    }

    private var locationPreview: String? {
        if let p = loc.placemark {

            let parts = [p.locality, p.administrativeArea].compactMap { $0 }
            return parts.isEmpty ? nil : parts.joined(separator: ", ")
        }
        return nil
    }

    private func savePost() {
        guard let data = imageData else {
            errorMessage = "Please choose a photo."
            return
        }
        guard let current = User.current else {
            errorMessage = "Not signed in."
            return
        }

        isSaving = true
        errorMessage = ""

        var post = Post()
        post.caption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        post.user = current
        post.authorUsername = current.username
        post.takenAt = Date()

        if let l = loc.lastLocation {
            post.latitude = l.coordinate.latitude
            post.longitude = l.coordinate.longitude
        }
        if let name = locationPreview {
            post.locationName = name
        }

        let file = ParseFile(name: "photo.jpg", data: data)
        post.imageFile = file

        post.save { result in
            DispatchQueue.main.async {
                self.isSaving = false
                switch result {
                case .success:
                    self.onPosted?()
                    self.dismiss()
                case .failure(let error):
                    self.errorMessage = "Upload failed: \(error.localizedDescription)"
                }
            }
        }
    }
}

