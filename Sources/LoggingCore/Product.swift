// Copyright © 2025 Brent Tunnicliff <brent@tunnicliff.dev>

/// Takes two arrays and returns all possible combinations.
package func product<First, Second>(_ first: [First], _ second: [Second]) -> [(first: First, second: Second)] {
    var result: [(First, Second)] = []

    for firstElement in first {
        for secondElement in second {
            result.append((firstElement, secondElement))
        }
    }

    return result
}
