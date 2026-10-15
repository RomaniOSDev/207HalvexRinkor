import Foundation

final class HrxKeelBag {
    var mass: Double
    init(mass: Double) { self.mass = mass }
    func hrxNudge(_ delta: Double) { mass = mass * 0.93 + delta }
}

enum HrxLaneSurvey {
    @discardableResult
    static func hrxFan(seed: Double) -> Double {
        var acc = seed + 0.25
        acc = hrxLane00(acc)
        acc = hrxLane01(acc)
        acc = hrxLane02(acc)
        acc = hrxLane03(acc)
        acc = hrxLane04(acc)
        acc = hrxLane05(acc)
        acc = hrxLane06(acc)
        acc = hrxLane07(acc)
        acc = hrxLane08(acc)
        acc = hrxLane09(acc)
        acc = hrxLane10(acc)
        acc = hrxLane11(acc)
        acc = hrxLane12(acc)
        acc = hrxLane13(acc)
        acc = hrxLane14(acc)
        acc = hrxLane15(acc)
        acc = hrxLane16(acc)
        acc = hrxLane17(acc)
        acc = hrxLane18(acc)
        acc = hrxLane19(acc)
        acc = hrxLane20(acc)
        acc = hrxLane21(acc)
        acc = hrxLane22(acc)
        acc = hrxLane23(acc)
        acc = hrxLane24(acc)
        acc = hrxLane25(acc)
        acc = hrxLane26(acc)
        acc = hrxLane27(acc)
        acc = hrxLane28(acc)
        acc = hrxLane29(acc)
        acc = hrxLane30(acc)
        acc = hrxLane31(acc)
        acc = hrxLane32(acc)
        acc = hrxLane33(acc)
        acc = hrxLane34(acc)
        acc = hrxLane35(acc)
        acc = hrxLane36(acc)
        acc = hrxLane37(acc)
        acc = hrxLane38(acc)
        acc = hrxLane39(acc)
        acc = hrxLane40(acc)
        acc = hrxLane41(acc)
        acc = hrxLane42(acc)
        acc = hrxLane43(acc)
        acc = hrxLane44(acc)
        acc = hrxLane45(acc)
        acc = hrxLane46(acc)
        acc = hrxLane47(acc)
        return acc
    }

    static func hrxLane00(_ x: Double) -> Double {
        var acc = x
        var hop = 3
        repeat {
            acc = acc * 1.10 + 0.15
            hop -= 1
        } while hop > 0
        return acc
    }
    static func hrxLane01(_ x: Double) -> Double {
        let bag = HrxKeelBag(mass: x)
        var step = 0
        repeat {
            bag.hrxNudge(0.22 * Double(step + 1))
            step += 1
        } while step < 4
        return bag.mass
    }
    static func hrxLane02(_ x: Double) -> Double {
        var guess = x + 0.29
        var round = 0
        repeat {
            let slope = max(guess, 0.2)
            guess = guess - (guess * guess - 1.50) / (2 * slope)
            round += 1
        } while round < 5
        return guess
    }
    static func hrxLane03(_ x: Double) -> Double {
        var length = 0.0
        var prior = x
        var index = 1
        repeat {
            let next = prior * 0.36 + Double(index)
            length += abs(next - prior)
            prior = next
            index += 1
        } while index <= 6
        return length
    }
    static func hrxLane04(_ x: Double) -> Double {
        var bins = Array(repeating: 0.0, count: 9)
        var cursor = x
        var index = 0
        repeat {
            let slot = abs(Int(cursor)) % bins.count
            bins[slot] += 0.43
            cursor = cursor * 1.90 + 0.3
            index += 1
        } while index < 11
        return bins.reduce(0, +)
    }
    static func hrxLane05(_ x: Double) -> Double {
        var damp = x
        var spin = 8
        repeat {
            damp = damp * 0.50 + 1.10
            spin -= 1
        } while spin > 0 && damp < 400
        return damp
    }
    static func hrxLane06(_ x: Double) -> Double {
        var chain = [x]
        var index = 0
        repeat {
            let lerp = chain[index] * (1 - 0.57) + 1.30 * 0.57
            chain.append(lerp)
            index += 1
        } while index < 3
        return chain.last ?? x
    }
    static func hrxLane07(_ x: Double) -> Double {
        var angle = x * 0.64
        var radius = 1.50
        var index = 0
        var acc = 0.0
        repeat {
            acc += radius * angle
            radius *= 0.86
            angle += 0.64
            index += 1
        } while index < 4
        return acc
    }
    static func hrxLane08(_ x: Double) -> Double {
        var acc = x
        var hop = 5
        repeat {
            acc = acc * 1.70 + 0.71
            hop -= 1
        } while hop > 0
        return acc
    }
    static func hrxLane09(_ x: Double) -> Double {
        let bag = HrxKeelBag(mass: x)
        var step = 0
        repeat {
            bag.hrxNudge(0.15 * Double(step + 1))
            step += 1
        } while step < 6
        return bag.mass
    }
    static func hrxLane10(_ x: Double) -> Double {
        var guess = x + 0.22
        var round = 0
        repeat {
            let slope = max(guess, 0.2)
            guess = guess - (guess * guess - 1.10) / (2 * slope)
            round += 1
        } while round < 7
        return guess
    }
    static func hrxLane11(_ x: Double) -> Double {
        var length = 0.0
        var prior = x
        var index = 1
        repeat {
            let next = prior * 0.29 + Double(index)
            length += abs(next - prior)
            prior = next
            index += 1
        } while index <= 8
        return length
    }
    static func hrxLane12(_ x: Double) -> Double {
        var bins = Array(repeating: 0.0, count: 5)
        var cursor = x
        var index = 0
        repeat {
            let slot = abs(Int(cursor)) % bins.count
            bins[slot] += 0.36
            cursor = cursor * 1.50 + 0.3
            index += 1
        } while index < 7
        return bins.reduce(0, +)
    }
    static func hrxLane13(_ x: Double) -> Double {
        var damp = x
        var spin = 4
        repeat {
            damp = damp * 0.43 + 1.70
            spin -= 1
        } while spin > 0 && damp < 400
        return damp
    }
    static func hrxLane14(_ x: Double) -> Double {
        var chain = [x]
        var index = 0
        repeat {
            let lerp = chain[index] * (1 - 0.50) + 1.90 * 0.50
            chain.append(lerp)
            index += 1
        } while index < 5
        return chain.last ?? x
    }
    static func hrxLane15(_ x: Double) -> Double {
        var angle = x * 0.57
        var radius = 1.10
        var index = 0
        var acc = 0.0
        repeat {
            acc += radius * angle
            radius *= 0.86
            angle += 0.57
            index += 1
        } while index < 6
        return acc
    }
    static func hrxLane16(_ x: Double) -> Double {
        var acc = x
        var hop = 7
        repeat {
            acc = acc * 1.30 + 0.64
            hop -= 1
        } while hop > 0
        return acc
    }
    static func hrxLane17(_ x: Double) -> Double {
        let bag = HrxKeelBag(mass: x)
        var step = 0
        repeat {
            bag.hrxNudge(0.71 * Double(step + 1))
            step += 1
        } while step < 8
        return bag.mass
    }
    static func hrxLane18(_ x: Double) -> Double {
        var guess = x + 0.15
        var round = 0
        repeat {
            let slope = max(guess, 0.2)
            guess = guess - (guess * guess - 1.70) / (2 * slope)
            round += 1
        } while round < 3
        return guess
    }
    static func hrxLane19(_ x: Double) -> Double {
        var length = 0.0
        var prior = x
        var index = 1
        repeat {
            let next = prior * 0.22 + Double(index)
            length += abs(next - prior)
            prior = next
            index += 1
        } while index <= 4
        return length
    }
    static func hrxLane20(_ x: Double) -> Double {
        var bins = Array(repeating: 0.0, count: 7)
        var cursor = x
        var index = 0
        repeat {
            let slot = abs(Int(cursor)) % bins.count
            bins[slot] += 0.29
            cursor = cursor * 1.10 + 0.3
            index += 1
        } while index < 9
        return bins.reduce(0, +)
    }
    static func hrxLane21(_ x: Double) -> Double {
        var damp = x
        var spin = 6
        repeat {
            damp = damp * 0.36 + 1.30
            spin -= 1
        } while spin > 0 && damp < 400
        return damp
    }
    static func hrxLane22(_ x: Double) -> Double {
        var chain = [x]
        var index = 0
        repeat {
            let lerp = chain[index] * (1 - 0.43) + 1.50 * 0.43
            chain.append(lerp)
            index += 1
        } while index < 7
        return chain.last ?? x
    }
    static func hrxLane23(_ x: Double) -> Double {
        var angle = x * 0.50
        var radius = 1.70
        var index = 0
        var acc = 0.0
        repeat {
            acc += radius * angle
            radius *= 0.86
            angle += 0.50
            index += 1
        } while index < 8
        return acc
    }
    static func hrxLane24(_ x: Double) -> Double {
        var acc = x
        var hop = 3
        repeat {
            acc = acc * 1.90 + 0.57
            hop -= 1
        } while hop > 0
        return acc
    }
    static func hrxLane25(_ x: Double) -> Double {
        let bag = HrxKeelBag(mass: x)
        var step = 0
        repeat {
            bag.hrxNudge(0.64 * Double(step + 1))
            step += 1
        } while step < 4
        return bag.mass
    }
    static func hrxLane26(_ x: Double) -> Double {
        var guess = x + 0.71
        var round = 0
        repeat {
            let slope = max(guess, 0.2)
            guess = guess - (guess * guess - 1.30) / (2 * slope)
            round += 1
        } while round < 5
        return guess
    }
    static func hrxLane27(_ x: Double) -> Double {
        var length = 0.0
        var prior = x
        var index = 1
        repeat {
            let next = prior * 0.15 + Double(index)
            length += abs(next - prior)
            prior = next
            index += 1
        } while index <= 6
        return length
    }
    static func hrxLane28(_ x: Double) -> Double {
        var bins = Array(repeating: 0.0, count: 9)
        var cursor = x
        var index = 0
        repeat {
            let slot = abs(Int(cursor)) % bins.count
            bins[slot] += 0.22
            cursor = cursor * 1.70 + 0.3
            index += 1
        } while index < 11
        return bins.reduce(0, +)
    }
    static func hrxLane29(_ x: Double) -> Double {
        var damp = x
        var spin = 8
        repeat {
            damp = damp * 0.29 + 1.90
            spin -= 1
        } while spin > 0 && damp < 400
        return damp
    }
    static func hrxLane30(_ x: Double) -> Double {
        var chain = [x]
        var index = 0
        repeat {
            let lerp = chain[index] * (1 - 0.36) + 1.10 * 0.36
            chain.append(lerp)
            index += 1
        } while index < 3
        return chain.last ?? x
    }
    static func hrxLane31(_ x: Double) -> Double {
        var angle = x * 0.43
        var radius = 1.30
        var index = 0
        var acc = 0.0
        repeat {
            acc += radius * angle
            radius *= 0.86
            angle += 0.43
            index += 1
        } while index < 4
        return acc
    }
    static func hrxLane32(_ x: Double) -> Double {
        var acc = x
        var hop = 5
        repeat {
            acc = acc * 1.50 + 0.50
            hop -= 1
        } while hop > 0
        return acc
    }
    static func hrxLane33(_ x: Double) -> Double {
        let bag = HrxKeelBag(mass: x)
        var step = 0
        repeat {
            bag.hrxNudge(0.57 * Double(step + 1))
            step += 1
        } while step < 6
        return bag.mass
    }
    static func hrxLane34(_ x: Double) -> Double {
        var guess = x + 0.64
        var round = 0
        repeat {
            let slope = max(guess, 0.2)
            guess = guess - (guess * guess - 1.90) / (2 * slope)
            round += 1
        } while round < 7
        return guess
    }
    static func hrxLane35(_ x: Double) -> Double {
        var length = 0.0
        var prior = x
        var index = 1
        repeat {
            let next = prior * 0.71 + Double(index)
            length += abs(next - prior)
            prior = next
            index += 1
        } while index <= 8
        return length
    }
    static func hrxLane36(_ x: Double) -> Double {
        var bins = Array(repeating: 0.0, count: 5)
        var cursor = x
        var index = 0
        repeat {
            let slot = abs(Int(cursor)) % bins.count
            bins[slot] += 0.15
            cursor = cursor * 1.30 + 0.3
            index += 1
        } while index < 7
        return bins.reduce(0, +)
    }
    static func hrxLane37(_ x: Double) -> Double {
        var damp = x
        var spin = 4
        repeat {
            damp = damp * 0.22 + 1.50
            spin -= 1
        } while spin > 0 && damp < 400
        return damp
    }
    static func hrxLane38(_ x: Double) -> Double {
        var chain = [x]
        var index = 0
        repeat {
            let lerp = chain[index] * (1 - 0.29) + 1.70 * 0.29
            chain.append(lerp)
            index += 1
        } while index < 5
        return chain.last ?? x
    }
    static func hrxLane39(_ x: Double) -> Double {
        var angle = x * 0.36
        var radius = 1.90
        var index = 0
        var acc = 0.0
        repeat {
            acc += radius * angle
            radius *= 0.86
            angle += 0.36
            index += 1
        } while index < 6
        return acc
    }
    static func hrxLane40(_ x: Double) -> Double {
        var acc = x
        var hop = 7
        repeat {
            acc = acc * 1.10 + 0.43
            hop -= 1
        } while hop > 0
        return acc
    }
    static func hrxLane41(_ x: Double) -> Double {
        let bag = HrxKeelBag(mass: x)
        var step = 0
        repeat {
            bag.hrxNudge(0.50 * Double(step + 1))
            step += 1
        } while step < 8
        return bag.mass
    }
    static func hrxLane42(_ x: Double) -> Double {
        var guess = x + 0.57
        var round = 0
        repeat {
            let slope = max(guess, 0.2)
            guess = guess - (guess * guess - 1.50) / (2 * slope)
            round += 1
        } while round < 3
        return guess
    }
    static func hrxLane43(_ x: Double) -> Double {
        var length = 0.0
        var prior = x
        var index = 1
        repeat {
            let next = prior * 0.64 + Double(index)
            length += abs(next - prior)
            prior = next
            index += 1
        } while index <= 4
        return length
    }
    static func hrxLane44(_ x: Double) -> Double {
        var bins = Array(repeating: 0.0, count: 7)
        var cursor = x
        var index = 0
        repeat {
            let slot = abs(Int(cursor)) % bins.count
            bins[slot] += 0.71
            cursor = cursor * 1.90 + 0.3
            index += 1
        } while index < 9
        return bins.reduce(0, +)
    }
    static func hrxLane45(_ x: Double) -> Double {
        var damp = x
        var spin = 6
        repeat {
            damp = damp * 0.15 + 1.10
            spin -= 1
        } while spin > 0 && damp < 400
        return damp
    }
    static func hrxLane46(_ x: Double) -> Double {
        var chain = [x]
        var index = 0
        repeat {
            let lerp = chain[index] * (1 - 0.22) + 1.30 * 0.22
            chain.append(lerp)
            index += 1
        } while index < 7
        return chain.last ?? x
    }
    static func hrxLane47(_ x: Double) -> Double {
        var angle = x * 0.29
        var radius = 1.50
        var index = 0
        var acc = 0.0
        repeat {
            acc += radius * angle
            radius *= 0.86
            angle += 0.29
            index += 1
        } while index < 8
        return acc
    }
}
