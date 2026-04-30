import Foundation
import SwiftUI

struct SignerDocument: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var fileURL: URL
    var thumbnailData: Data?
    var dateCreated: Date
    var dateModified: Date
    var pageCount: Int
    var isSigned: Bool
    var annotations: [DocumentAnnotation]

    init(
        id: UUID = UUID(),
        name: String,
        fileURL: URL,
        thumbnailData: Data? = nil,
        dateCreated: Date = Date(),
        dateModified: Date = Date(),
        pageCount: Int = 1,
        isSigned: Bool = false,
        annotations: [DocumentAnnotation] = []
    ) {
        self.id = id
        self.name = name
        self.fileURL = fileURL
        self.thumbnailData = thumbnailData
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.pageCount = pageCount
        self.isSigned = isSigned
        self.annotations = annotations
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dateModified)
    }

    var fileSizeString: String {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
              let size = attributes[.size] as? Int64 else {
            return "Unknown"
        }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

// MARK: - Document Annotation
struct DocumentAnnotation: Identifiable, Codable, Hashable {
    let id: UUID
    var type: AnnotationType
    var position: CGPoint
    var size: CGSize
    var pageIndex: Int
    var content: String
    var signatureData: Data?
    var rotation: Double
    var opacity: Double
    var color: String

    init(
        id: UUID = UUID(),
        type: AnnotationType,
        position: CGPoint,
        size: CGSize = CGSize(width: 200, height: 80),
        pageIndex: Int = 0,
        content: String = "",
        signatureData: Data? = nil,
        rotation: Double = 0,
        opacity: Double = 1.0,
        color: String = "000000"
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.size = size
        self.pageIndex = pageIndex
        self.content = content
        self.signatureData = signatureData
        self.rotation = rotation
        self.opacity = opacity
        self.color = color
    }
}

// MARK: - Annotation Types
enum AnnotationType: String, Codable, CaseIterable {
    case signature = "signature"
    case initials = "initials"
    case text = "text"
    case date = "date"
    case checkbox = "checkbox"
    case stamp = "stamp"
    case image = "image"
    case drawing = "drawing"

    var icon: String {
        switch self {
        case .signature: return "signature"
        case .initials: return "textformat.abc"
        case .text: return "textformat"
        case .date: return "calendar"
        case .checkbox: return "checkmark.square"
        case .stamp: return "seal"
        case .image: return "photo"
        case .drawing: return "pencil.tip"
        }
    }

    var displayName: String {
        switch self {
        case .signature: return "Signature"
        case .initials: return "Initials"
        case .text: return "Text"
        case .date: return "Date"
        case .checkbox: return "Checkbox"
        case .stamp: return "Stamp"
        case .image: return "Image"
        case .drawing: return "Drawing"
        }
    }
}

