import SwiftUI
import UIKit

enum HrxBoardLane: String, CaseIterable, Identifiable {
    case sheet
    case trace
    case book
    case notes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sheet: return "Sheet"
        case .trace: return "Trace"
        case .book: return "Book"
        case .notes: return "Notes"
        }
    }
}

struct HrxLaneShell: View {
    @State private var lane: HrxBoardLane = .sheet
    @State private var topInset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(HrxBoardLane.allCases) { item in
                    Button {
                        lane = item
                    } label: {
                        Text(item.title)
                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .textCase(.uppercase)
                            .foregroundColor(lane == item ? .hrxOnFill : .hrxInk)
                            .frame(maxWidth: .infinity)
                            .padding(.top, topInset + 8)
                            .padding(.bottom, 10)
                            .background(lane == item ? Color.hrxAccent : Color.hrxSheet)
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay(alignment: .bottom) {
                Rectangle().fill(Color.hrxInk).frame(height: 2)
            }
            .background(HrxTopProbe(top: $topInset))

            Group {
                switch lane {
                case .sheet:
                    NavigationStack { HrxDawnOvalPane() }
                case .trace:
                    NavigationStack { HrxTraceBoardPane() }
                case .book:
                    NavigationStack { HrxLedgerRollPane() }
                case .notes:
                    NavigationStack { HrxIceNotePane() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: .top)
        .hrxSheetBackdrop("HrxArenaGlow", veil: 0)
    }
}

struct HrxTopProbe: UIViewRepresentable {
    @Binding var top: CGFloat

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            let inset = uiView.window?.safeAreaInsets.top ?? 0
            if inset > 1, abs(inset - top) > 0.5 {
                top = inset
            }
        }
    }
}
