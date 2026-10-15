import SwiftUI

struct HrxGlideIntroPane: View {
    @EnvironmentObject private var vault: HrxRinkVault
    @State private var page = 0

    private let boards: [(image: String, title: String, body: String)] = [
        ("HrxOvalIce", "Count the laps", "Tap each lap as you glide. The ribbon fills toward the goal you set."),
        ("HrxBladeClose", "Practice one edge", "A skill of the day waits on the sheet. Reps stay on this phone."),
        ("HrxGlideMotion", "Read the trace", "Laps, minutes, and edges draw their own lines across the week.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(Array(boards.enumerated()), id: \.offset) { index, board in
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .frame(height: 220)
                            .overlay {
                                Image(board.image)
                                    .resizable()
                                    .scaledToFill()
                            }
                            .clipped()
                            .overlay(alignment: .bottom) {
                                Rectangle().fill(Color.hrxLine).frame(height: 6)
                            }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LENGTH \(index + 1)")
                                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                .foregroundColor(.hrxLine)
                            Text(board.title)
                                .font(.title2.weight(.heavy))
                                .foregroundColor(.hrxInk)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(board.body)
                                .font(.body)
                                .foregroundColor(.hrxPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(18)
                        .background(Color.hrxSheet)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 0) {
                ForEach(0..<boards.count, id: \.self) { index in
                    Rectangle()
                        .fill(index == page ? Color.hrxInk : Color.hrxLine.opacity(0.35))
                        .frame(height: 8)
                }
            }
            HrxFillButton(title: page == boards.count - 1 ? "Step on the ice" : "Next length") {
                if page == boards.count - 1 {
                    vault.hrxMarkIntroCleared()
                } else {
                    withAnimation { page += 1 }
                }
            }
            .padding(16)
        }
        .background(Color.hrxSheet.ignoresSafeArea())
    }
}
