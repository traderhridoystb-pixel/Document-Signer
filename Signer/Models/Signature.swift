import Foundation
import SwiftUI

struct SavedSignature: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var imageData: Data
    var dateCreated: Date
    var isDefault: Bool
    var type: SignatureType

    init(
        id: UUID = UUID(),
        name: String = "My Signature",
        imageData: Data,
        dateCreated: Date = Date(),
        isDefault: Bool = false,
        type: SignatureType = .signature
    ) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.dateCreated = dateCreated
        self.isDefault = isDefault
        self.type = type
    }
}

enum SignatureType: String, Codable, CaseIterable {
    case signature = "signature"
    case initials = "initials"

    var displayName: String {
        switch self {
        case .signature: return "Signature"
        case .initials: return "Initials"
        }
    }
}

// MARK: - Drawing Path for Signature
struct DrawingPath: Identifiable, Hashable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat

    static func == (lhs: DrawingPath, rhs: DrawingPath) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Stamp Templates
struct StampTemplate: Identifiable, Hashable {
    let id: UUID
    let name: String
    let text: String
    let color: Color
    let style: StampStyle

    init(
        id: UUID = UUID(),
        name: String,
        text: String,
        color: Color,
        style: StampStyle = .bordered
    ) {
        self.id = id
        self.name = name
        self.text = text
        self.color = color
        self.style = style
    }

    static let presets: [StampTemplate] = [
        StampTemplate(name: "Approved", text: "APPROVED", color: Color(hex: "22C55E")),
        StampTemplate(name: "Rejected", text: "REJECTED", color: Color(hex: "EF4444")),
        StampTemplate(name: "Draft", text: "DRAFT", color: Color(hex: "F59E0B")),
        StampTemplate(name: "Confidential", text: "CONFIDENTIAL", color: Color(hex: "EF4444"), style: .filled),
        StampTemplate(name: "Copy", text: "COPY", color: Color(hex: "3B82F6")),
        StampTemplate(name: "Final", text: "FINAL", color: Color(hex: "22C55E"), style: .filled),
        StampTemplate(name: "Reviewed", text: "REVIEWED", color: Color(hex: "8B5CF6")),
        StampTemplate(name: "Void", text: "VOID", color: Color(hex: "EF4444"), style: .filled),
        StampTemplate(name: "Received", text: "RECEIVED", color: Color(hex: "3B82F6")),
        StampTemplate(name: "Original", text: "ORIGINAL", color: Color(hex: "059669")),
    ]
}

enum StampStyle: String, Hashable {
    case bordered
    case filled
    case rounded
}
