import SwiftUI

struct SignatureCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var paths: [DrawingPath] = []
    @State private var currentPath: [CGPoint] = []
    @State private var typedSignature = ""
    @State private var selectedFont = 0
    @State private var strokeColor: Color = .black
    @State private var strokeWidth: CGFloat = 3.0

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
                // Tab selector
                Picker("Mode", selection: $selectedTab) {
                    Text("Draw").tag(0)
                    Text("Type").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if selectedTab == 0 {
                    drawingView
                } else {
                    typingView
                }

                // Action buttons
                HStack(spacing: 16) {
                    Button(action: clearCanvas) {
                        Text("Clear")
                            .secondaryButtonStyle()
                    }

                    Button(action: saveSignature) {
                        Text("Use Signature")
                            .primaryButtonStyle()
                    }
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
        }
    }

    // MARK: - Drawing View
    private var drawingView: some View {
        VStack(spacing: 12) {
            // Color picker
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

                // Stroke width
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

            // Canvas
            ZStack {
                RoundedRectangle(cornerRadius: SignerRadius.md)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: SignerRadius.md)
                            .stroke(Color(.systemGray4), style: StrokeStyle(lineWidth: 1, dash: [6]))
                    )

                // Signature line
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

                // Drawn paths
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

                    // Current path being drawn
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

            // Font selection
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

            // Preview
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
        HapticManager.impact(.light)
    }

    private func saveSignature() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 160))
        let image: UIImage

        if selectedTab == 0 {
            // Render drawn signature
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
        } else {
            // Render typed signature
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
        }

        if let data = image.pngData() {
            onComplete(data)
            HapticManager.notification(.success)
            dismiss()
        }
    }
}
