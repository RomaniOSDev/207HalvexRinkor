import SwiftUI
import UIKit

extension Color {
    static let hrxSheet = Color.white
    static let hrxPrimary = Color(red: 32.0 / 255.0, green: 85.0 / 255.0, blue: 132.0 / 255.0)
    static let hrxAccent = Color(red: 77.0 / 255.0, green: 119.0 / 255.0, blue: 157.0 / 255.0)
    static let hrxOnFill = Color.white
    static let hrxMuted = Color(red: 156.0 / 255.0, green: 163.0 / 255.0, blue: 175.0 / 255.0)
    static let hrxInk = Color(red: 32.0 / 255.0, green: 85.0 / 255.0, blue: 132.0 / 255.0)
    static let hrxLine = Color(red: 77.0 / 255.0, green: 119.0 / 255.0, blue: 157.0 / 255.0)
    static let hrxBlueLine = Color(red: 32.0 / 255.0, green: 85.0 / 255.0, blue: 132.0 / 255.0)
}

enum HrxInkResign {
    static func fold() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func hrxFoldInkOnTap() -> some View {
        background(HrxWindowTapFold())
    }

    func hrxSheetBackdrop(_ imageName: String, veil: Double) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ZStack(alignment: .topTrailing) {
                    Color.hrxSheet
                    if veil > 0 {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 48)
                            .clipped()
                            .overlay(Rectangle().stroke(Color.hrxLine, lineWidth: 2))
                            .padding(.top, 54)
                            .padding(.trailing, 12)
                            .opacity(0.9)
                    }
                }
                .ignoresSafeArea()
            }
    }
}

struct HrxWindowTapFold: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = HrxFoldHost()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

final class HrxFoldHost: UIView, UIGestureRecognizerDelegate {
    private var foldTap: UITapGestureRecognizer?

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window, foldTap == nil else { return }
        let tap = UITapGestureRecognizer(target: self, action: #selector(fold))
        tap.name = "hrx.fold.ink"
        tap.cancelsTouchesInView = false
        tap.delegate = self
        window.addGestureRecognizer(tap)
        foldTap = tap
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil, let foldTap, let window {
            window.removeGestureRecognizer(foldTap)
            self.foldTap = nil
        }
        super.willMove(toWindow: newWindow)
    }

    @objc private func fold() {
        HrxInkResign.fold()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var node: UIView? = touch.view
        while let current = node {
            if current is UITextField || current is UITextView { return false }
            node = current.superview
        }
        return true
    }
}

struct HrxRinkRuling: View {
    var body: some View {
        Canvas { context, size in
            let red = Path { path in
                path.move(to: CGPoint(x: 0, y: size.height * 0.5))
                path.addLine(to: CGPoint(x: size.width, y: size.height * 0.5))
            }
            context.stroke(red, with: .color(Color.hrxLine.opacity(0.28)), lineWidth: 3)
            for fraction in [0.33, 0.67] {
                var line = Path()
                line.move(to: CGPoint(x: 0, y: size.height * fraction))
                line.addLine(to: CGPoint(x: size.width, y: size.height * fraction))
                context.stroke(line, with: .color(Color.hrxBlueLine.opacity(0.22)), lineWidth: 2)
            }
        }
        .allowsHitTesting(false)
    }
}

struct HrxFramedStill: View {
    let name: String
    var height: CGFloat = 140

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay {
                Image(name)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.hrxLine)
                    .frame(height: 3)
            }
            .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.35), lineWidth: 1))
    }
}

struct HrxRingButton: View {
    let title: String
    let symbol: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                Text(title)
                    .font(.caption.weight(.heavy))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundColor(.hrxOnFill)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.hrxPrimary)
        }
        .buttonStyle(.plain)
    }
}

struct HrxFillButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(.hrxOnFill)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(Color.hrxPrimary)
        }
        .buttonStyle(.plain)
    }
}

struct HrxQuietButton: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.hrxInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(Color.white)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(Color.hrxAccent).frame(height: 3)
                }
                .overlay(Rectangle().stroke(Color.hrxInk.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .task { _ = HrxChromaSalt.hrxScratch(title.utf8.count) }
    }
}

enum HrxChromaSalt {
    static func hrxScratch(_ width: Int) -> Double {
        var mark = Double(width) * 0.25
        var hop = 3
        repeat {
            mark += Double(hop) * 0.15
            hop -= 1
        } while hop > 0
        return hrxBend(mark)
    }

    static func hrxBend(_ mark: Double) -> Double {
        var value = mark
        var lane = 1
        while lane < 4 {
            value = value * 0.8 + Double(lane)
            lane += 1
        }
        return value
    }
}
