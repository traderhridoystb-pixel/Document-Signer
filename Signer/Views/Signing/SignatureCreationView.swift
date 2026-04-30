import SwiftUI
import PhotosUI

struct SignatureCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var paths: [DrawingPath] = []
    @State private var currentPath: [CGPoint] = []
    @State private var typedSignature = ""
    @State private var selectedFont = 0
    @State private var strokeColor: Color = .black
    @State private var strokeWidth: CGFloat = 3.0
    @State private var scannedImage: UIImage?
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isProcessing = false

    let onComplete: (Data) -> Void

    private let signatureFonts = [
        "Snell Roundhand",
        "Bradley Hand",
        "Marker Felt",
        "Noteworthy",
        "Zapfino",
        "Didot",
        "Georgia",
        "Baskerville",
        "Copperplate",
        "Palatino",
        "American Typewriter",
        "Courier New"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Mode", selection: $selectedTab) {
                    Text("Draw").tag(0)
                    Text("Type").tag(1)
                    Text("Scan").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if selectedTab == 0 {
                    drawingView
                } else if selectedTab == 1 {
                    typingView
                } else {
                    scanView
                }

                HStack(spacing: 16) {
                    Button(action: clearCanvas) {
                        Text("Clear")
                            .secondaryButtonStyle()
                    }

                    Button(action: saveSignature) {
                        Text("Use Signature")
                            .primaryButtonStyle()
                    }
                    .disabled(selectedTab == 2 && scannedImage == nil)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Create Signature")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraPickerView { image in
                    processScannedSignature(image)
                }
            }
            .photosPicker(isPresented: $showingPhotoLibrary, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newValue in
                if let item = newValue {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            processScannedSignature(image)
                        }
                        selectedPhotoItem = nil
                    }
                }
            }
            .overlay {
                if isProcessing {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.3)
                            Text("Extracting signature...")
                                .font(SignerTypography.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "1C1C1E")))
                    }
                }
            }
        }
    }

    // MARK: - Scan View
    private var scanView: some View {
        VStack(spacing: 16) {
            if let scannedImage {
                ZStack {
                    // Checkerboard pattern to show transparency
                    CheckerboardBackground()
                        .clipShape(RoundedRectangle(cornerRadius: SignerRadius.md))

                    Image(uiImage: scannedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(20)
                }
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: SignerRadius.md)
                        .stroke(SignerColors.primary, lineWidth: 2)
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Text("Background removed — signature ready to use")
                    .font(SignerTypography.caption1)
                    .foregroundColor(SignerColors.accent)

                HStack(spacing: 16) {
                    Button(action: {
                        scannedImage = nil
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retake")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(SignerColors.textSecondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: SignerRadius.sm)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(SignerColors.primary)
                        .padding(.top, 24)

                    VStack(spacing: 8) {
                        Text("Scan Your Handwritten Signature")
                            .font(SignerTypography.title3)
                            .foregroundColor(SignerColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Sign on white paper with a dark pen, then take a photo or choose from your library. The background will be automatically removed.")
                            .font(SignerTypography.caption1)
                            .foregroundColor(SignerColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    HStack(spacing: 16) {
                        Button(action: { showingCamera = true }) {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 24))
                                Text("Camera")
                                    .font(SignerTypography.caption1)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: SignerRadius.md)
                                    .fill(SignerColors.primaryGradient)
                            )
                        }

                        Button(action: { showingPhotoLibrary = true }) {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 24))
                                Text("Photo Library")
                                    .font(SignerTypography.caption1)
                            }
                            .foregroundColor(SignerColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: SignerRadius.md)
                                    .stroke(SignerColors.primary, lineWidth: 1.5)
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }

            Spacer()
        }
    }

    // MARK: - Drawing View
    private var drawingView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ForEach([Color.black, Color.blue, Color.red, Color(hex: "1E40AF")], id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(strokeColor == color ? SignerColors.primary : .clear, lineWidth: 2)
                                .padding(-3)
                        )
                        .onTapGesture {
                            strokeColor = color
                        }
                }

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "lineweight")
                        .foregroundColor(SignerColors.textSecondary)
                    Slider(value: $strokeWidth, in: 1...8, step: 0.5)
                        .frame(width: 80)
                        .tint(SignerColors.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ZStack {
                RoundedRectangle(cornerRadius: SignerRadius.md)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: SignerRadius.md)
                            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [6]))
                    )

                Path { path in
                    path.move(to: CGPoint(x: 40, y: 200))
                    path.addLine(to: CGPoint(x: UIScreen.main.bounds.width - 80, y: 200))
                }
                .stroke(Color(.systemGray4), lineWidth: 0.5)

                Text("Sign here")
                    .font(SignerTypography.caption1)
                    .foregroundColor(Color(.systemGray3))
                    .offset(y: 180)
                    .opacity(paths.isEmpty ? 1 : 0)

                Canvas { context, size in
                    for path in paths {
                        var drawPath = Path()
                        guard let firstPoint = path.points.first else { continue }
                        drawPath.move(to: firstPoint)
                        for point in path.points.dropFirst() {
                            drawPath.addLine(to: point)
                        }
                        context.stroke(
                            drawPath,
                            with: .color(path.color),
                            lineWidth: path.lineWidth
                        )
                    }

                    if !currentPath.isEmpty {
                        var drawPath = Path()
                        drawPath.move(to: currentPath[0])
                        for point in currentPath.dropFirst() {
                            drawPath.addLine(to: point)
                        }
                        context.stroke(
                            drawPath,
                            with: .color(strokeColor),
                            lineWidth: strokeWidth
                        )
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentPath.append(value.location)
                        }
                        .onEnded { _ in
                            let newPath = DrawingPath(
                                points: currentPath,
                                color: strokeColor,
                                lineWidth: strokeWidth
                            )
                            paths.append(newPath)
                            currentPath = []
                        }
                )
            }
            .frame(height: 240)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Typing View
    private var typingView: some View {
        VStack(spacing: 16) {
            TextField("Type your name", text: $typedSignature)
                .font(.system(size: 20))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: SignerRadius.md)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(signatureFonts.enumerated()), id: \.offset) { index, fontName in
                        Button(action: { selectedFont = index }) {
                            Text(typedSignature.isEmpty ? "Signature" : typedSignature)
                                .font(.custom(fontName, size: 22))
                                .foregroundColor(selectedFont == index ? SignerColors.primary : SignerColors.textPrimary)
                                .lineLimit(1)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: SignerRadius.sm)
                                        .fill(selectedFont == index ? SignerColors.primaryUltraLight : Color(.systemGray6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: SignerRadius.sm)
                                        .stroke(selectedFont == index ? SignerColors.primary : .clear, lineWidth: 1.5)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            ZStack {
                RoundedRectangle(cornerRadius: SignerRadius.md)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: SignerRadius.md)
                            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [6]))
                    )

                if !typedSignature.isEmpty {
                    Text(typedSignature)
                        .font(.custom(signatureFonts[selectedFont], size: 36))
                        .foregroundColor(.black)
                } else {
                    Text("Preview")
                        .font(SignerTypography.body)
                        .foregroundColor(Color(.systemGray3))
                }
            }
            .frame(height: 120)
            .padding(.horizontal, 20)

            Spacer()
        }
    }

    // MARK: - Actions
    private func clearCanvas() {
        paths = []
        currentPath = []
        typedSignature = ""
        scannedImage = nil
        HapticManager.impact(.light)
    }

    private func processScannedSignature(_ image: UIImage) {
        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async {
            let processed = SignatureImageProcessor.removeBackground(from: image)
            DispatchQueue.main.async {
                scannedImage = processed
                isProcessing = false
                HapticManager.notification(.success)
            }
        }
    }

    private func saveSignature() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 160))
        let image: UIImage

        if selectedTab == 0 {
            image = renderer.image { context in
                UIColor.clear.setFill()
                context.fill(CGRect(origin: .zero, size: CGSize(width: 400, height: 160)))

                let scale = CGSize(width: 400.0 / (UIScreen.main.bounds.width - 40), height: 160.0 / 240.0)

                for path in paths {
                    let bezierPath = UIBezierPath()
                    guard let first = path.points.first else { continue }
                    bezierPath.move(to: CGPoint(x: first.x * scale.width, y: first.y * scale.height))
                    for point in path.points.dropFirst() {
                        bezierPath.addLine(to: CGPoint(x: point.x * scale.width, y: point.y * scale.height))
                    }
                    bezierPath.lineWidth = path.lineWidth
                    UIColor(path.color).setStroke()
                    bezierPath.stroke()
                }
            }
        } else if selectedTab == 1 {
            image = renderer.image { context in
                UIColor.clear.setFill()
                context.fill(CGRect(origin: .zero, size: CGSize(width: 400, height: 160)))

                let font = UIFont(name: signatureFonts[selectedFont], size: 48) ?? UIFont.systemFont(ofSize: 48)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: UIColor.black
                ]
                let text = typedSignature as NSString
                let textSize = text.size(withAttributes: attributes)
                let x = (400 - textSize.width) / 2
                let y = (160 - textSize.height) / 2
                text.draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
            }
        } else {
            guard let scannedImg = scannedImage else { return }
            let targetSize = CGSize(width: 400, height: 160)
            let imgRenderer = UIGraphicsImageRenderer(size: targetSize)
            image = imgRenderer.image { _ in
                UIColor.clear.setFill()
                UIRectFill(CGRect(origin: .zero, size: targetSize))
                let aspectRatio = scannedImg.size.width / scannedImg.size.height
                var drawWidth = targetSize.width
                var drawHeight = drawWidth / aspectRatio
                if drawHeight > targetSize.height {
                    drawHeight = targetSize.height
                    drawWidth = drawHeight * aspectRatio
                }
                let x = (targetSize.width - drawWidth) / 2
                let y = (targetSize.height - drawHeight) / 2
                scannedImg.draw(in: CGRect(x: x, y: y, width: drawWidth, height: drawHeight))
            }
        }

        if let data = image.pngData() {
            onComplete(data)
            HapticManager.notification(.success)
            dismiss()
        }
    }
}

// MARK: - Signature Image Processor (Background Removal)
enum SignatureImageProcessor {
    static func removeBackground(from image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }

        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return image }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Analyze the image to find the average background brightness
        var totalBrightness: Double = 0
        let sampleCount = min(width * height, 10000)
        let step = max(1, (width * height) / sampleCount)

        for i in stride(from: 0, to: width * height, by: step) {
            let offset = i * bytesPerPixel
            let r = Double(pixelData[offset])
            let g = Double(pixelData[offset + 1])
            let b = Double(pixelData[offset + 2])
            totalBrightness += (r + g + b) / 3.0
        }
        let actualSampleCount = ((width * height) + step - 1) / step
        let avgBrightness = totalBrightness / Double(actualSampleCount)

        // Threshold: pixels brighter than this are considered background
        let threshold: Double = min(max(avgBrightness - 30, 180), 230)

        for i in 0..<(width * height) {
            let offset = i * bytesPerPixel
            let r = Double(pixelData[offset])
            let g = Double(pixelData[offset + 1])
            let b = Double(pixelData[offset + 2])
            let brightness = (r + g + b) / 3.0

            if brightness > threshold {
                // Make background transparent
                pixelData[offset] = 0
                pixelData[offset + 1] = 0
                pixelData[offset + 2] = 0
                pixelData[offset + 3] = 0
            } else {
                // Keep ink pixels, boost contrast
                let factor = min(1.0, (threshold - brightness) / threshold)
                let alpha = UInt8(min(255, factor * 255 * 1.5))
                let alphaFraction = Double(alpha) / 255.0
                pixelData[offset] = UInt8(min(Double(alpha), Double(pixelData[offset]) * alphaFraction))
                pixelData[offset + 1] = UInt8(min(Double(alpha), Double(pixelData[offset + 1]) * alphaFraction))
                pixelData[offset + 2] = UInt8(min(Double(alpha), Double(pixelData[offset + 2]) * alphaFraction))
                pixelData[offset + 3] = alpha
            }
        }

        guard let outputContext = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ), let outputImage = outputContext.makeImage() else {
            return image
        }

        return UIImage(cgImage: outputImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

// MARK: - Camera Picker
struct CameraPickerView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, dismiss: dismiss)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void
        let dismiss: DismissAction

        init(onCapture: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onCapture = onCapture
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

// MARK: - Checkerboard Background (shows transparency)
struct CheckerboardBackground: View {
    let squareSize: CGFloat = 8

    var body: some View {
        Canvas { context, size in
            let rows = Int(size.height / squareSize) + 1
            let cols = Int(size.width / squareSize) + 1

            for row in 0..<rows {
                for col in 0..<cols {
                    let isLight = (row + col) % 2 == 0
                    let rect = CGRect(
                        x: CGFloat(col) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    context.fill(
                        Path(rect),
                        with: .color(isLight ? Color(.systemGray6) : Color(.systemGray5))
                    )
                }
            }
        }
    }
}
