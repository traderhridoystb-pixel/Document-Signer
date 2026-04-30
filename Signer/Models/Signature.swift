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
        // Status stamps
        StampTemplate(name: "Approved", text: "APPROVED", color: Color(hex: "22C55E")),
        StampTemplate(name: "Rejected", text: "REJECTED", color: Color(hex: "EF4444")),
        StampTemplate(name: "Pending", text: "PENDING", color: Color(hex: "F59E0B"), style: .rounded),
        StampTemplate(name: "Draft", text: "DRAFT", color: Color(hex: "F59E0B")),
        StampTemplate(name: "Final", text: "FINAL", color: Color(hex: "22C55E"), style: .filled),
        StampTemplate(name: "Completed", text: "COMPLETED", color: Color(hex: "059669"), style: .filled),

        // Document control
        StampTemplate(name: "Confidential", text: "CONFIDENTIAL", color: Color(hex: "EF4444"), style: .filled),
        StampTemplate(name: "Copy", text: "COPY", color: Color(hex: "3B82F6")),
        StampTemplate(name: "Original", text: "ORIGINAL", color: Color(hex: "059669")),
        StampTemplate(name: "Duplicate", text: "DUPLICATE", color: Color(hex: "6366F1")),
        StampTemplate(name: "Void", text: "VOID", color: Color(hex: "EF4444"), style: .filled),
        StampTemplate(name: "Cancelled", text: "CANCELLED", color: Color(hex: "DC2626"), style: .bordered),

        // Review & process
        StampTemplate(name: "Reviewed", text: "REVIEWED", color: Color(hex: "8B5CF6")),
        StampTemplate(name: "Received", text: "RECEIVED", color: Color(hex: "3B82F6")),
        StampTemplate(name: "Verified", text: "VERIFIED", color: Color(hex: "22C55E"), style: .rounded),
        StampTemplate(name: "Certified", text: "CERTIFIED", color: Color(hex: "059669"), style: .rounded),
        StampTemplate(name: "Notarized", text: "NOTARIZED", color: Color(hex: "1E40AF"), style: .filled),
        StampTemplate(name: "Witnessed", text: "WITNESSED", color: Color(hex: "7C3AED")),

        // Urgency & priority
        StampTemplate(name: "Urgent", text: "URGENT", color: Color(hex: "EF4444"), style: .filled),
        StampTemplate(name: "Priority", text: "PRIORITY", color: Color(hex: "F97316"), style: .bordered),
        StampTemplate(name: "Rush", text: "RUSH", color: Color(hex: "DC2626"), style: .rounded),
        StampTemplate(name: "ASAP", text: "ASAP", color: Color(hex: "EF4444"), style: .rounded),

        // Legal & compliance
        StampTemplate(name: "Not Valid", text: "NOT VALID", color: Color(hex: "9CA3AF"), style: .bordered),
        StampTemplate(name: "For Review", text: "FOR REVIEW", color: Color(hex: "6366F1"), style: .bordered),
        StampTemplate(name: "Sign Here", text: "SIGN HERE", color: Color(hex: "2563EB"), style: .rounded),
        StampTemplate(name: "Initial Here", text: "INITIAL HERE", color: Color(hex: "2563EB")),
        StampTemplate(name: "Date Here", text: "DATE HERE", color: Color(hex: "0891B2")),
        StampTemplate(name: "Paid", text: "PAID", color: Color(hex: "22C55E"), style: .filled),
        StampTemplate(name: "Unpaid", text: "UNPAID", color: Color(hex: "EF4444"), style: .bordered),
        StampTemplate(name: "Past Due", text: "PAST DUE", color: Color(hex: "DC2626"), style: .filled),

        // Office workflow
        StampTemplate(name: "File Copy", text: "FILE COPY", color: Color(hex: "64748B")),
        StampTemplate(name: "Entered", text: "ENTERED", color: Color(hex: "0EA5E9")),
        StampTemplate(name: "Scanned", text: "SCANNED", color: Color(hex: "8B5CF6"), style: .rounded),
        StampTemplate(name: "Faxed", text: "FAXED", color: Color(hex: "64748B"), style: .bordered),
        StampTemplate(name: "Emailed", text: "EMAILED", color: Color(hex: "3B82F6"), style: .rounded),
        StampTemplate(name: "Posted", text: "POSTED", color: Color(hex: "059669")),
    ]
}

enum StampStyle: String, Hashable {
    case bordered
    case filled
    case rounded
}
