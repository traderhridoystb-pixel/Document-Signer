import SwiftUI

struct SignatureManagerView: View {
    @State private var savedSignatures: [SavedSignature] = []
    @State private var showingCreation = false
    @State private var showingDeleteAlert = false
    @State private var signatureToDelete: SavedSignature?

    var body: some View {
        NavigationStack {
            Group {
                if savedSignatures.isEmpty {
                    emptyState
                } else {
                    signatureList
                }
            }
            .navigationTitle("My Signatures")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreation = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(SignerColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingCreation) {
                SignatureCreationView { data in
                    let signature = SavedSignature(
                        name: "Signature \(savedSignatures.count + 1)",
                        imageData: data
                    )
                    savedSignatures.append(signature)
                    saveSignatures()
                }
                .presentationDetents([.medium, .large])
            }
            .alert("Delete Signature?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let sig = signatureToDelete {
                        savedSignatures.removeAll { $0.id == sig.id }
                        saveSignatures()
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .onAppear {
                loadSignatures()
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(SignerColors.primaryUltraLight)
                    .frame(width: 120, height: 120)

                Image(systemName: "signature")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(SignerColors.primary)
            }

            VStack(spacing: 8) {
                Text("No Saved Signatures")
                    .font(SignerTypography.title2)
                    .foregroundColor(SignerColors.textPrimary)

                Text("Create your first signature to use across all your documents.")
                    .font(SignerTypography.subheadline)
                    .foregroundColor(SignerColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)
            }

            Button(action: { showingCreation = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Create Signature")
                }
                .primaryButtonStyle()
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Signature List
    private var signatureList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(savedSignatures) { signature in
                    SignatureCard(signature: signature)
                        .contextMenu {
                            Button(action: {
                                if let index = savedSignatures.firstIndex(where: { $0.id == signature.id }) {
                                    for i in savedSignatures.indices {
                                        savedSignatures[i].isDefault = false
                                    }
                                    savedSignatures[index].isDefault = true
                                    saveSignatures()
                                }
                            }) {
                                Label("Set as Default", systemImage: "star")
                            }

                            Button(role: .destructive) {
                                signatureToDelete = signature
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Persistence
    private func loadSignatures() {
        if let data = UserDefaults.standard.data(forKey: "savedSignatures"),
           let signatures = try? JSONDecoder().decode([SavedSignature].self, from: data) {
            savedSignatures = signatures
        }
    }

    private func saveSignatures() {
        if let data = try? JSONEncoder().encode(savedSignatures) {
            UserDefaults.standard.set(data, forKey: "savedSignatures")
        }
    }
}

// MARK: - Signature Card
struct SignatureCard: View {
    let signature: SavedSignature
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            // Signature preview
            if let uiImage = UIImage(data: signature.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 50)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 0.5)
                            )
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(signature.name)
                        .font(SignerTypography.bodyMedium)
                        .foregroundColor(SignerColors.textPrimary)

                    if signature.isDefault {
                        Text("Default")
                            .font(SignerTypography.caption2)
                            .foregroundColor(SignerColors.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(SignerColors.primaryUltraLight)
                            )
                    }
                }

                Text(signature.dateCreated.formatted(date: .abbreviated, time: .shortened))
                    .font(SignerTypography.caption1)
                    .foregroundColor(SignerColors.textSecondary)
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: SignerRadius.md)
                .fill(colorScheme == .dark ? Color(hex: "1C1C1E") : .white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06),
                        radius: 4, x: 0, y: 2)
        )
    }
}
