import SwiftUI
import PDFKit

struct DocumentViewerView: View {
    @Environment(DocumentManager.self) private var documentManager
    @Environment(StoreKitManager.self) private var storeKit
    @Environment(\.dismiss) private var dismiss

    let document: SignerDocument
    @State private var currentPage = 0
    @State private var showingToolbar = true
    @State private var showingSignatureSheet = false
    @State private var showingTextInput = false
    @State private var showingStampPicker = false
    @State private var showingPaywall = false
    @State private var annotations: [DocumentAnnotation] = []
    @State private var selectedTool: AnnotationType?
    @State private var textInput = ""
    @State private var showingExportSheet = false
    @State private var pdfView: PDFView?

    var body: some View {
        NavigationStack {
            ZStack {
                // PDF Content
                PDFViewRepresentable(
                    url: document.fileURL,
                    pdfView: $pdfView
                )
                .ignoresSafeArea(edges: .bottom)

                // Annotation overlay
                annotationOverlay

                // Bottom toolbar
                if showingToolbar {
                    VStack {
                        Spacer()
                        signingToolbar
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(SignerColors.textSecondary)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(document.name)
                        .font(SignerTypography.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: { showingExportSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16))
                        }

                        Button(action: saveDocument) {
                            Text("Save")
                                .font(SignerTypography.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(SignerColors.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSignatureSheet) {
                SignatureCreationView { signatureData in
                    addSignatureAnnotation(signatureData)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingStampPicker) {
                StampPickerView { stamp in
                    addStampAnnotation(stamp)
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingPaywall) {
                SignerPaywallView(isFromOnboarding: false)
            }
            .alert("Add Text", isPresented: $showingTextInput) {
                TextField("Enter text...", text: $textInput)
                Button("Cancel", role: .cancel) {}
                Button("Add") {
                    addTextAnnotation(textInput)
                    textInput = ""
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                if let exportURL = documentManager.exportSignedDocument(document) {
                    ShareSheet(activityItems: [exportURL])
                }
            }
        }
        .onAppear {
            annotations = document.annotations
        }
    }

    // MARK: - Annotation Overlay
    private var annotationOverlay: some View {
        GeometryReader { geometry in
            ForEach(annotations) { annotation in
                AnnotationView(
                    annotation: annotation,
                    onDelete: { removeAnnotation(annotation) },
                    onMove: { newPosition in
                        moveAnnotation(annotation, to: newPosition)
                    }
                )
            }
        }
    }

    // MARK: - Signing Toolbar
    private var signingToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ToolButton(icon: "signature", label: "Sign", isSelected: selectedTool == .signature) {
                    checkPremiumAndExecute {
                        showingSignatureSheet = true
                    }
                }

                ToolButton(icon: "textformat.abc", label: "Initials", isSelected: selectedTool == .initials) {
                    checkPremiumAndExecute {
                        selectedTool = .initials
                        showingSignatureSheet = true
                    }
                }

                ToolButton(icon: "textformat", label: "Text", isSelected: selectedTool == .text) {
                    showingTextInput = true
                }

                ToolButton(icon: "calendar", label: "Date", isSelected: selectedTool == .date) {
                    addDateAnnotation()
                }

                ToolButton(icon: "seal", label: "Stamp", isSelected: selectedTool == .stamp) {
                    checkPremiumAndExecute {
                        showingStampPicker = true
                    }
                }

                ToolButton(icon: "checkmark.square", label: "Check", isSelected: selectedTool == .checkbox) {
                    addCheckboxAnnotation()
                }

                ToolButton(icon: "photo", label: "Image", isSelected: selectedTool == .image) {
                    checkPremiumAndExecute {
                        selectedTool = .image
                    }
                }

                ToolButton(icon: "pencil.tip", label: "Draw", isSelected: selectedTool == .drawing) {
                    checkPremiumAndExecute {
                        selectedTool = .drawing
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 8, y: -4)
        )
    }

    // MARK: - Actions
    private func checkPremiumAndExecute(_ action: () -> Void) {
        if storeKit.isPremium || documentManager.canSignForFree {
            action()
        } else {
            showingPaywall = true
        }
    }

    private func addSignatureAnnotation(_ data: Data) {
        let annotation = DocumentAnnotation(
            type: .signature,
            position: CGPoint(x: 150, y: 400),
            size: CGSize(width: 200, height: 80),
            pageIndex: currentPage,
            signatureData: data
        )
        annotations.append(annotation)
        HapticManager.impact(.medium)
    }

    private func addTextAnnotation(_ text: String) {
        guard !text.isEmpty else { return }
        let annotation = DocumentAnnotation(
            type: .text,
            position: CGPoint(x: 150, y: 300),
            size: CGSize(width: 200, height: 40),
            pageIndex: currentPage,
            content: text
        )
        annotations.append(annotation)
        HapticManager.impact(.light)
    }

    private func addDateAnnotation() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let annotation = DocumentAnnotation(
            type: .date,
            position: CGPoint(x: 150, y: 350),
            size: CGSize(width: 160, height: 30),
            pageIndex: currentPage,
            content: formatter.string(from: Date())
        )
        annotations.append(annotation)
        HapticManager.impact(.light)
    }

    private func addStampAnnotation(_ stamp: StampTemplate) {
        let annotation = DocumentAnnotation(
            type: .stamp,
            position: CGPoint(x: 150, y: 300),
            size: CGSize(width: 180, height: 60),
            pageIndex: currentPage,
            content: stamp.text
        )
        annotations.append(annotation)
        HapticManager.impact(.medium)
    }

    private func addCheckboxAnnotation() {
        let annotation = DocumentAnnotation(
            type: .checkbox,
            position: CGPoint(x: 100, y: 300),
            size: CGSize(width: 30, height: 30),
            pageIndex: currentPage
        )
        annotations.append(annotation)
        HapticManager.impact(.light)
    }

    private func removeAnnotation(_ annotation: DocumentAnnotation) {
        annotations.removeAll { $0.id == annotation.id }
        HapticManager.impact(.light)
    }

    private func moveAnnotation(_ annotation: DocumentAnnotation, to position: CGPoint) {
        if let index = annotations.firstIndex(where: { $0.id == annotation.id }) {
            annotations[index].position = position
        }
    }

    private func saveDocument() {
        var updatedDoc = document
        updatedDoc.annotations = annotations
        updatedDoc.isSigned = !annotations.isEmpty
        documentManager.updateDocument(updatedDoc)
        HapticManager.notification(.success)
        dismiss()
    }
}

// MARK: - PDF View Representable
struct PDFViewRepresentable: UIViewRepresentable {
    let url: URL
    @Binding var pdfView: PDFView?

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = UIColor.systemGray6
        if let document = PDFDocument(url: url) {
            view.document = document
        }
        DispatchQueue.main.async {
            pdfView = view
        }
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// MARK: - Annotation View
struct AnnotationView: View {
    let annotation: DocumentAnnotation
    let onDelete: () -> Void
    let onMove: (CGPoint) -> Void

    @State private var position: CGPoint
    @State private var isSelected = false

    init(annotation: DocumentAnnotation, onDelete: @escaping () -> Void, onMove: @escaping (CGPoint) -> Void) {
        self.annotation = annotation
        self.onDelete = onDelete
        self.onMove = onMove
        _position = State(initialValue: annotation.position)
    }

    var body: some View {
        Group {
            switch annotation.type {
            case .signature:
                if let data = annotation.signatureData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            case .text, .date:
                Text(annotation.content)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: annotation.color))
            case .stamp:
                Text(annotation.content)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.red, lineWidth: 2)
                    )
                    .rotationEffect(.degrees(-15))
            case .checkbox:
                Image(systemName: "checkmark.square.fill")
                    .font(.system(size: 24))
                    .foregroundColor(SignerColors.primary)
            case .initials:
                if let data = annotation.signatureData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            default:
                EmptyView()
            }
        }
        .frame(width: annotation.size.width, height: annotation.size.height)
        .overlay(
            isSelected ? RoundedRectangle(cornerRadius: 4)
                .stroke(SignerColors.primary, style: StrokeStyle(lineWidth: 1, dash: [4])) : nil
        )
        .overlay(alignment: .topTrailing) {
            if isSelected {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                        .background(Circle().fill(.white).frame(width: 16, height: 16))
                }
                .offset(x: 8, y: -8)
            }
        }
        .position(position)
        .gesture(
            DragGesture()
                .onChanged { value in
                    isSelected = true
                    position = value.location
                }
                .onEnded { value in
                    position = value.location
                    onMove(position)
                }
        )
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

// MARK: - Tool Button
struct ToolButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? SignerColors.primary : Color(.systemGray6))
                    )
                    .foregroundColor(isSelected ? .white : SignerColors.textPrimary)

                Text(label)
                    .font(SignerTypography.caption2)
                    .foregroundColor(SignerColors.textSecondary)
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
