import Foundation
import PDFKit
import SwiftUI
import UniformTypeIdentifiers

@Observable
final class DocumentManager {
    static let shared = DocumentManager()

    var documents: [SignerDocument] = []
    var isLoading = false

    private let fileManager = FileManager.default
    private let documentsDirectory: URL

    private init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SignerDocuments", isDirectory: true)

        if !fileManager.fileExists(atPath: documentsDirectory.path) {
            try? fileManager.createDirectory(at: documentsDirectory, withIntermediateDirectories: true)
        }

        loadDocuments()
    }

    // MARK: - Load Documents
    func loadDocuments() {
        isLoading = true
        defer { isLoading = false }

        if let data = UserDefaults.standard.data(forKey: "savedDocuments"),
           let saved = try? JSONDecoder().decode([SignerDocument].self, from: data) {
            documents = saved.sorted { $0.dateModified > $1.dateModified }
        }
    }

    // MARK: - Save Documents List
    private func saveDocumentsList() {
        if let data = try? JSONEncoder().encode(documents) {
            UserDefaults.standard.set(data, forKey: "savedDocuments")
        }
    }

    // MARK: - Import Document
    func importDocument(from sourceURL: URL) -> SignerDocument? {
        let fileName = sourceURL.lastPathComponent
        let destinationURL = documentsDirectory.appendingPathComponent(UUID().uuidString + "_" + fileName)

        do {
            if sourceURL.startAccessingSecurityScopedResource() {
                defer { sourceURL.stopAccessingSecurityScopedResource() }
                try fileManager.copyItem(at: sourceURL, to: destinationURL)
            } else {
                try fileManager.copyItem(at: sourceURL, to: destinationURL)
            }

            let pageCount = getPageCount(for: destinationURL)
            let thumbnail = generateThumbnail(for: destinationURL)

            let document = SignerDocument(
                name: fileName,
                fileURL: destinationURL,
                thumbnailData: thumbnail,
                pageCount: pageCount
            )

            documents.insert(document, at: 0)
            saveDocumentsList()
            return document
        } catch {
            return nil
        }
    }

    // MARK: - Create Blank Document
    func createBlankDocument() -> SignerDocument? {
        let fileName = "Blank Document \(documents.count + 1).pdf"
        let destinationURL = documentsDirectory.appendingPathComponent(UUID().uuidString + "_" + fileName)

        let pdfDocument = PDFDocument()
        let page = PDFPage()
        pdfDocument.insert(page, at: 0)

        guard pdfDocument.write(to: destinationURL) else { return nil }

        let thumbnail = generateThumbnail(for: destinationURL)
        let document = SignerDocument(
            name: fileName,
            fileURL: destinationURL,
            thumbnailData: thumbnail,
            pageCount: 1
        )

        documents.insert(document, at: 0)
        saveDocumentsList()
        return document
    }

    // MARK: - Delete Document
    func deleteDocument(_ document: SignerDocument) {
        try? fileManager.removeItem(at: document.fileURL)
        documents.removeAll { $0.id == document.id }
        saveDocumentsList()
    }

    // MARK: - Update Document
    func updateDocument(_ document: SignerDocument) {
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            var updated = document
            updated.dateModified = Date()
            documents[index] = updated
            saveDocumentsList()
        }
    }

    // MARK: - Rename Document
    func renameDocument(_ document: SignerDocument, newName: String) {
        if let index = documents.firstIndex(where: { $0.id == document.id }) {
            documents[index].name = newName
            documents[index].dateModified = Date()
            saveDocumentsList()
        }
    }

    // MARK: - PDF Helpers
    func getPageCount(for url: URL) -> Int {
        guard let pdfDocument = PDFDocument(url: url) else { return 1 }
        return pdfDocument.pageCount
    }

    func generateThumbnail(for url: URL) -> Data? {
        guard let pdfDocument = PDFDocument(url: url),
              let page = pdfDocument.page(at: 0) else { return nil }

        let pageRect = page.bounds(for: .mediaBox)
        let scale: CGFloat = 200 / max(pageRect.width, pageRect.height)
        let scaledSize = CGSize(
            width: pageRect.width * scale,
            height: pageRect.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: scaledSize))

            context.cgContext.translateBy(x: 0, y: scaledSize.height)
            context.cgContext.scaleBy(x: scale, y: -scale)
            page.draw(with: .mediaBox, to: context.cgContext)
        }

        return image.pngData()
    }

    // MARK: - Export Signed Document
    func exportSignedDocument(_ document: SignerDocument) -> URL? {
        guard let pdfDocument = PDFDocument(url: document.fileURL) else { return nil }

        let exportName = document.name.replacingOccurrences(of: ".pdf", with: "_signed.pdf")
        let exportURL = documentsDirectory.appendingPathComponent(exportName)

        pdfDocument.write(to: exportURL)
        return exportURL
    }

    // MARK: - Search
    func searchDocuments(_ query: String) -> [SignerDocument] {
        guard !query.isEmpty else { return documents }
        return documents.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Free Tier Check
    var signedDocumentCount: Int {
        documents.filter { $0.isSigned }.count
    }

    var canSignForFree: Bool {
        signedDocumentCount < AppConstants.freeDocumentSignLimit
    }
}
