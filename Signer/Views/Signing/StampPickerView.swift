import SwiftUI

struct StampPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (StampTemplate) -> Void

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(StampTemplate.presets) { stamp in
                        StampPreviewCard(stamp: stamp) {
                            onSelect(stamp)
                            dismiss()
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Select Stamp")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct StampPreviewCard: View {
    let stamp: StampTemplate
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.impact(.medium)
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: SignerRadius.md)
                        .fill(Color.white)
                        .frame(height: 80)

                    stampView
                }

                Text(stamp.name)
                    .font(SignerTypography.caption1)
                    .foregroundColor(SignerColors.textSecondary)
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var stampView: some View {
        switch stamp.style {
        case .bordered:
            Text(stamp.text)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(stamp.color)
                .tracking(2)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(stamp.color, lineWidth: 2)
                )
                .rotationEffect(.degrees(-12))

        case .filled:
            Text(stamp.text)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .tracking(2)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(stamp.color)
                )
                .rotationEffect(.degrees(-12))

        case .rounded:
            Text(stamp.text)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(stamp.color)
                .tracking(2)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .overlay(
                    Capsule()
                        .stroke(stamp.color, lineWidth: 2)
                )
        }
    }
}
