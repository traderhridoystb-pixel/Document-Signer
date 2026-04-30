import SwiftUI
import PDFKit
import PhotosUI

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
    @State private var showingDrawingCanvas = false
    @State private var showingImagePicker = false
    @State private var showingSavedSignatures = false
    @State private var selectedPhotoItem: PhotosPickerItem?

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

                // Drawing canvas overlay
                if showingDrawingCanvas {
                    DrawingCanvasOverlay(
                        onComplete: { data in
                            addDrawingAnnotation(data)
                            showingDrawingCanvas = false
                            selectedTool = nil
                        },
                        onCancel: {
                            showingDrawingCanvas = false
                            selectedTool = nil
                        }
                    )
                }

                // Bottom toolbar
                if showingToolbar && !showingDrawingCanvas {
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
            .sheet(isPresented: $showingSavedSignatures) {
                SavedSignaturePickerView { signatureData in
                    addSignatureAnnotation(signatureData)
                }
                .presentationDetents([.medium, .large])
            }
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newValue in
                if let item = newValue {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            addImageAnnotation(data)
                        }
                        selectedPhotoItem = nil
                    }
                }
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
                    },
                    onResize: { newSize in
                        resizeAnnotation(annotation, to: newSize)
                    }
                )
            }
        }
    }

    // MARK: - Signing Toolbar
    private var signingToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                Menu {
                    Button(action: { showingSignatureSheet = true }) {
                        Label("Create New", systemImage: "plus")
                    }
                    Button(action: { showingSavedSignatures = true }) {
                        Label("Saved Signatures", systemImage: "folder")
                    }
                } label: {
                    ToolButtonLabel(icon: "signature", label: "Sign", isSelected: selectedTool == .signature)
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
                        showingImagePicker = true
                    }
                }

                ToolButton(icon: "pencil.tip", label: "Draw", isSelected: selectedTool == .drawing) {
                    checkPremiumAndExecute {
                        selectedTool = .drawing
                        showingDrawingCanvas = true
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

    private func addDrawingAnnotation(_ data: Data) {
        let annotation = DocumentAnnotation(
            type: .drawing,
            position: CGPoint(x: 150, y: 350),
            size: CGSize(width: 250, height: 150),
            pageIndex: currentPage,
            signatureData: data
        )
        annotations.append(annotation)
        HapticManager.impact(.medium)
    }

    private func addImageAnnotation(_ data: Data) {
        let annotation = DocumentAnnotation(
            type: .image,
            position: CGPoint(x: 150, y: 350),
            size: CGSize(width: 200, height: 200),
            pageIndex: currentPage,
            signatureData: data
        )
        annotations.append(annotation)
        selectedTool = nil
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

    private func resizeAnnotation(_ annotation: DocumentAnnotation, to newSize: CGSize) {
        if let index = annotations.firstIndex(where: { $0.id == annotation.id }) {
            annotations[index].size = newSize
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
    let onResize: (CGSize) -> Void

    @State private var position: CGPoint
    @State private var size: CGSize
    @State private var isSelected = false
    @State private var currentScale: CGFloat = 1.0

    init(annotation: DocumentAnnotation, onDelete: @escaping () -> Void, onMove: @escaping (CGPoint) -> Void, onResize: @escaping (CGSize) -> Void) {
        self.annotation = annotation
        self.onDelete = onDelete
        self.onMove = onMove
        self.onResize = onResize
        _position = State(initialValue: annotation.position)
        _size = State(initialValue: annotation.size)
    }

    var body: some View {
        Group {
            switch annotation.type {
            case .signature, .initials:
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
            case .image, .drawing:
                if let data = annotation.signatureData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
        .frame(width: size.width, height: size.height)
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
        .overlay(alignment: .bottomTrailing) {
            if isSelected {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(SignerColors.primary))
                    .offset(x: 6, y: 6)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newWidth = max(50, size.width + value.translation.width)
                                let newHeight = max(30, size.height + value.translation.height)
                                size = CGSize(width: newWidth, height: newHeight)
                            }
                            .onEnded { _ in
                                onResize(size)
                            }
                    )
            }
        }
        .scaleEffect(currentScale)
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
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { scale in
                    isSelected = true
                    currentScale = scale
                }
                .onEnded { scale in
                    let newWidth = max(50, size.width * scale)
                    let newHeight = max(30, size.height * scale)
                    size = CGSize(width: newWidth, height: newHeight)
                    currentScale = 1.0
                    onResize(size)
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

// MARK: - Tool Button Label (for Menu)
struct ToolButtonLabel: View {
    let icon: String
    let label: String
    let isSelected: Bool

    var body: some View {
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

// MARK: - Drawing Canvas Overlay
struct DrawingCanvasOverlay: View {
    let onComplete: (Data) -> Void
    let onCancel: () -> Void

    @State private var paths: [DrawingPath] = []
    @State private var currentPath: [CGPoint] = []
    @State private var strokeColor: Color = .black
    @State private var strokeWidth: CGFloat = 3.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") { onCancel() }
                        .foregroundColor(.white)
                    Spacer()
                    Text("Draw")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button("Done") { saveDrawing() }
                        .fontWeight(.semibold)
                        .foregroundColor(SignerColors.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                HStack(spacing: 12) {
                    ForEach([Color.black, Color.blue, Color.red, Color(hex: "1E40AF")], id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(strokeColor == color ? .white : .clear, lineWidth: 2)
                                    .padding(-3)
                            )
                            .onTapGesture { strokeColor = color }
                    }

                    Spacer()

                    Button(action: { paths = []; currentPath = [] }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)

                    Canvas { context, canvasSize in
                        for path in paths {
                            var drawPath = Path()
                            guard let firstPoint = path.points.first else { continue }
                            drawPath.move(to: firstPoint)
                            for point in path.points.dropFirst() {
                                drawPath.addLine(to: point)
                            }
                            context.stroke(drawPath, with: .color(path.color), lineWidth: path.lineWidth)
                        }

                        if !currentPath.isEmpty {
                            var drawPath = Path()
                            drawPath.move(to: currentPath[0])
                            for point in currentPath.dropFirst() {
                                drawPath.addLine(to: point)
                            }
                            context.stroke(drawPath, with: .color(strokeColor), lineWidth: strokeWidth)
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in currentPath.append(value.location) }
                            .onEnded { _ in
                                paths.append(DrawingPath(points: currentPath, color: strokeColor, lineWidth: strokeWidth))
                                currentPath = []
                            }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "1C1C1E"))
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 60)
        }
    }

    private func saveDrawing() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 500, height: 300))
        let image = renderer.image { ctx in
            UIColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: CGSize(width: 500, height: 300)))

            let canvasWidth = UIScreen.main.bounds.width - 56
            let canvasHeight = UIScreen.main.bounds.height * 0.4
            let scaleX = 500.0 / canvasWidth
            let scaleY = 300.0 / canvasHeight

            for path in paths {
                let bezierPath = UIBezierPath()
                guard let first = path.points.first else { continue }
                bezierPath.move(to: CGPoint(x: first.x * scaleX, y: first.y * scaleY))
                for point in path.points.dropFirst() {
                    bezierPath.addLine(to: CGPoint(x: point.x * scaleX, y: point.y * scaleY))
                }
                bezierPath.lineWidth = path.lineWidth
                UIColor(path.color).setStroke()
                bezierPath.stroke()
            }
        }

        if let data = image.pngData() {
            onComplete(data)
        }
    }
}

// MARK: - Saved Signature Picker
struct SavedSignaturePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (Data) -> Void

    @State private var savedSignatures: [SavedSignature] = []

    var body: some View {
        NavigationStack {
            Group {
                if savedSignatures.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "signature")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(SignerColors.textSecondary)
                        Text("No Saved Signatures")
                            .font(SignerTypography.title3)
                            .foregroundColor(SignerColors.textPrimary)
                        Text("Create signatures from the Signatures tab first.")
                            .font(SignerTypography.subheadline)
                            .foregroundColor(SignerColors.textSecondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(savedSignatures) { sig in
                                Button(action: {
                                    onSelect(sig.imageData)
                                    dismiss()
                                }) {
                                    HStack(spacing: 14) {
                                        if let uiImage = UIImage(data: sig.imageData) {
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
                                                Text(sig.name)
                                                    .font(SignerTypography.bodyMedium)
                                                    .foregroundColor(SignerColors.textPrimary)
                                                if sig.isDefault {
                                                    Text("Default")
                                                        .font(SignerTypography.caption2)
                                                        .foregroundColor(SignerColors.primary)
                                                        .padding(.horizontal, 6)
                                                        .padding(.vertical, 2)
                                                        .background(Capsule().fill(SignerColors.primaryUltraLight))
                                                }
                                            }
                                            Text(sig.dateCreated.formatted(date: .abbreviated, time: .shortened))
                                                .font(SignerTypography.caption1)
                                                .foregroundColor(SignerColors.textSecondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(SignerColors.textSecondary)
                                    }
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Saved Signatures")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { loadSignatures() }
        }
    }

    private func loadSignatures() {
        if let data = UserDefaults.standard.data(forKey: "savedSignatures"),
           let sigs = try? JSONDecoder().decode([SavedSignature].self, from: data) {
            savedSignatures = sigs
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
