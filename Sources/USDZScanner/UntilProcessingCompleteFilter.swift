/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An asynchronous sequence filter this sample applies to the photogrammetry session.
*/

import Foundation
import RealityKit

@available(iOS 17.0, *)
struct UntilProcessingCompleteFilter<Base>: AsyncSequence,
                                            AsyncIteratorProtocol where Base: AsyncSequence, Base.Element == PhotogrammetrySession.Output {
    func makeAsyncIterator() -> UntilProcessingCompleteFilter {
        return self
    }

    typealias AsyncIterator = Self
    typealias Element = PhotogrammetrySession.Output

    private let inputSequence: Base
    private var completed: Bool = false
    private var iterator: Base.AsyncIterator

    init(input: Base) where Base.Element == Element {
        inputSequence = input
        iterator = inputSequence.makeAsyncIterator()
    }

    mutating func next() async -> Element? {
        if completed {
            return nil
        }

        guard let nextElement = try? await iterator.next() else {
            completed = true
            return nil
        }

        if case .processingComplete = nextElement {
            completed = true
        }
        if case .processingCancelled = nextElement {
            completed = true
        }

        return nextElement
    }
}
