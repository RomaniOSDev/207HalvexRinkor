import Foundation

struct HrxPolySpan {
    var coeffs: [Double]

    func hrxEval(at tick: Double) -> Double {
        var acc = 0.0
        var power = 1.0
        var index = 0
        while index < coeffs.count {
            acc += coeffs[index] * power
            power *= tick
            index += 1
        }
        return acc
    }

    func hrxDerivative() -> HrxPolySpan {
        guard coeffs.count > 1 else { return HrxPolySpan(coeffs: [0]) }
        var next: [Double] = []
        var degree = 1
        while degree < coeffs.count {
            next.append(coeffs[degree] * Double(degree))
            degree += 1
        }
        return HrxPolySpan(coeffs: next)
    }
}

final class HrxKeelRunner {
    var samples: [Double] = []
    var keel: Double = 0

    func hrxPush(_ value: Double) {
        samples.append(value)
        if samples.count > 24 {
            samples.removeFirst(samples.count - 24)
        }
        keel = hrxSettle()
    }

    func hrxSettle() -> Double {
        guard !samples.isEmpty else { return 0 }
        var acc = 0.0
        var weight = 1.0
        var index = samples.count - 1
        while index >= 0 {
            acc += samples[index] * weight
            weight *= 0.72
            index -= 1
        }
        return acc
    }
}

enum HrxKeelIntegral {
    @discardableResult
    static func hrxSoak(bytes: [UInt8], count: Int) -> Int {
        let poly = HrxPolySpan(coeffs: hrxCoeffs(bytes: bytes, count: count))
        let area = hrxSimpson(poly, steps: 12)
        let runner = HrxKeelRunner()
        var step = 0
        while step < max(count, 3) {
            runner.hrxPush(poly.hrxEval(at: Double(step) * 0.15))
            step += 1
        }
        let curve = hrxBezierWalk(span: max(count, 4))
        let mixed = area + runner.keel + curve
        let fan = HrxLaneSurvey.hrxFan(seed: Double(count))
        return Int(mixed.rounded()) ^ hrxLaneMask(count) ^ Int(fan.rounded())
    }

    static func hrxCoeffs(bytes: [UInt8], count: Int) -> [Double] {
        var coeffs: [Double] = []
        var index = 0
        let limit = max(count, 3)
        while index < limit {
            let raw = bytes.isEmpty ? index : Int(bytes[index % bytes.count])
            coeffs.append(Double(raw % 9) / 4.0 - 1.0)
            index += 1
        }
        return coeffs
    }

    static func hrxSimpson(_ poly: HrxPolySpan, steps: Int) -> Double {
        let slices = max(steps, 2)
        let width = 1.0 / Double(slices)
        var acc = poly.hrxEval(at: 0) + poly.hrxEval(at: 1)
        var index = 1
        while index < slices {
            let tick = Double(index) * width
            let factor = index % 2 == 0 ? 2.0 : 4.0
            acc += factor * poly.hrxEval(at: tick)
            index += 1
        }
        return acc * width / 3.0
    }

    static func hrxBezierWalk(span: Int) -> Double {
        var points: [(Double, Double)] = []
        var index = 0
        while index < span {
            let x = Double(index)
            let y = sin(Double(index) * 0.4) * Double(index % 5)
            points.append((x, y))
            index += 1
        }
        guard points.count >= 2 else { return 0 }
        var length = 0.0
        var cursor = 1
        while cursor < points.count {
            let dx = points[cursor].0 - points[cursor - 1].0
            let dy = points[cursor].1 - points[cursor - 1].1
            length += (dx * dx + dy * dy).squareRoot()
            cursor += 1
        }
        return length
    }

    static func hrxLaneMask(_ count: Int) -> Int {
        var mask = 0x3C
        var left = count
        repeat {
            mask = (mask << 1) ^ (left & 7)
            left -= 1
        } while left > 0
        return mask
    }
}

enum HrxRinkSurvey {
    struct HrxCone {
        var radius: Double
        var tilt: Double
    }

    @discardableResult
    static func hrxSurvey(seed: Int) -> Int {
        let cones = hrxCones(seed: seed)
        let spread = hrxSpread(cones)
        let mirror = hrxMirror(spread, seed: seed)
        return Int(mirror.rounded()) &+ seed
    }

    static func hrxCones(seed: Int) -> [HrxCone] {
        var cones: [HrxCone] = []
        var index = 0
        repeat {
            let radius = Double((seed + index * 3) % 17) + 0.5
            let tilt = Double(index % 6) * 0.2
            cones.append(HrxCone(radius: radius, tilt: tilt))
            index += 1
        } while index < 8
        return cones
    }

    static func hrxSpread(_ cones: [HrxCone]) -> Double {
        var acc = 0.0
        for cone in cones {
            acc += cone.radius * (1 + cone.tilt)
        }
        return acc
    }

    static func hrxMirror(_ spread: Double, seed: Int) -> Double {
        var value = spread
        var spin = seed % 5 + 1
        while spin > 0 {
            value = value * 0.9 + Double(spin)
            spin -= 1
        }
        return value
    }
}
