import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    @Environment(DocumentManager.self) private var documentManager
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(LocalizationManager.self) private var localization

    @Binding var showingPaywall: Bool
    @State private var searchText = ""
    @State private var showingImporter = false
    @State private var showingActionSheet = false
    @State private var selectedDocument: SignerDocument?
    @State private var showingDocumentViewer = false
    @State private var showingRenameAlert = false
    @State private var renameText = ""
    @State private var documentToRename: SignerDocument?

    var filteredDocuments: [SignerDocument] {
        documentManager.searchDocuments(searchText)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if documentManager.documents.isEmpty {
                    emptyStateView
                } else {
                    documentListView
                }
            }
            .navigationTitle(localization.localized(.myDocuments))
            .searchable(text: $searchText, prompt: localization.localized(.search))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingImporter = true }) {
                            Label(localization.localized(.importDocument), systemImage: "doc.badge.plus")
                        }
                        Button(action: createBlankDocument) {
                            Label(localization.localized(.createBlank), systemImage: "doc")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(SignerColors.primary)
                    }
                }

                if !storeKit.isPremium {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { showingPaywall = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 12))
                                Text("PRO")
                                    .font(SignerTypography.caption1)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(SignerColors.premiumGradient)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.pdf, .png, .jpeg, .heic],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result)
            }
            .fullScreenCover(item: $selectedDocument) { document in
                DocumentViewerView(document: document)
            }
            .alert("Rename Document", isPresented: $showingRenameAlert) {
                TextField("Document name", text: $renameText)
                Button("Cancel", role: .cancel) {}
                Button("Rename") {
                    if let doc = documentToRename {
                        documentManager.renameDocument(doc, newName: renameText)
                    }
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(SignerColors.primaryUltraLight)
                    .frame(width: 120, height: 120)

                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(SignerColors.primary)
            }

            VStack(spacing: 8) {
                Text(localization.localized(.noDocuments))
                    .font(SignerTypography.title2)
                    .foregroundColor(SignerColors.textPrimary)

                Text(localization.localized(.noDocumentsSubtitle))
                    .font(SignerTypography.subheadline)
                    .foregroundColor(SignerColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)
            }

            VStack(spacing: 12) {
                Button(action: { showingImporter = true }) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text(localization.localized(.importDocument))
                    }
                    .primaryButtonStyle()
                }

                Button(action: createBlankDocument) {
                    HStack {
                        Image(systemName: "doc")
                        Text(localization.localized(.createBlank))
                    }
                    .secondaryButtonStyle()
                }
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Document List
    private var documentListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Free tier banner
                if !storeKit.isPremium {
                    freeTierBanner
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }

                ForEach(filteredDocuments) { document in
                    DocumentCard(document: document)
                        .onTapGesture {
                            HapticManager.impact(.light)
                            selectedDocument = document
                        }
                        .contextMenu {
                            Button(action: {
                                documentToRename = document
                                renameText = document.name
                                showingRenameAlert = true
                            }) {
                                Label("Rename", systemImage: "pencil")
                            }

                            Button(action: {
                                shareDocument(document)
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }

                            Button(role: .destructive, action: {
                                documentManager.deleteDocument(document)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Free Tier Banner
    private var freeTierBanner: some View {
        Button(action: { showingPaywall = true }) {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "F59E0B"))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Upgrade to Premium")
                        .font(SignerTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(SignerColors.textPrimary)

                    Text("\(documentManager.signedDocumentCount)/\(AppConstants.freeDocumentSignLimit) free documents used")
                        .font(SignerTypography.caption1)
                        .foregroundColor(SignerColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(SignerColors.textTertiary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: SignerRadius.md)
                    .fill(Color(hex: "FFFBEB"))
                    .overlay(
                        RoundedRectangle(cornerRadius: SignerRadius.md)
                            .stroke(Color(hex: "FDE68A"), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions
    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                if let doc = documentManager.importDocument(from: url) {
                    HapticManager.notification(.success)
                    selectedDocument = doc
                }
            }
        case .failure:
            HapticManager.notification(.error)
        }
    }

    private func createBlankDocument() {
        if let doc = documentManager.createBlankDocument() {
            HapticManager.notification(.success)
            selectedDocument = doc
        }
    }

    private func shareDocument(_ document: SignerDocument) {
        let activityVC = UIActivityViewController(activityItems: [document.fileURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Document Card
struct DocumentCard: View {
    let document: SignerDocument
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            Group {
                if let thumbnailData = document.thumbnailData,
                   let uiImage = UIImage(data: thumbnailData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        Color(.systemGray6)
                        Image(systemName: "doc.text")
                            .font(.system(size: 24))
                            .foregroundColor(SignerColors.textTertiary)
                    }
                }
            }
            .frame(width: 56, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(SignerTypography.bodyMedium)
                    .foregroundColor(SignerColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label("\(document.pageCount) pages", systemImage: "doc")
                        .font(SignerTypography.caption1)
                        .foregroundColor(SignerColors.textSecondary)

                    if document.isSigned {
                        Label("Signed", systemImage: "checkmark.seal.fill")
                            .font(SignerTypography.caption1)
                            .foregroundColor(SignerColors.accent)
                    }
                }

                Text(document.formattedDate)
                    .font(SignerTypography.caption2)
                    .foregroundColor(SignerColors.textTertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(SignerColors.textTertiary)
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
