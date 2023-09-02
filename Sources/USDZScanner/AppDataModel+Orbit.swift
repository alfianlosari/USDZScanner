/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Device orbit component of a data model that maintains the state of the app.
*/

import UIKit

extension AppDataModel {
    enum Orbit: Int, CaseIterable, Identifiable, Comparable {
        case orbit1, orbit2, orbit3

        var id: Int {
            rawValue
        }

        var image: String {
            let imagesByIndex = ["1.circle", "2.circle", "3.circle"]
            return imagesByIndex[id]
        }

        var imageSelected: String {
            let imagesByIndex = ["1.circle.fill", "2.circle.fill", "3.circle.fill"]
            return imagesByIndex[id]
        }

        func next() -> Self {
            let currentIndex = Self.allCases.firstIndex(of: self)!
            let nextIndex = Self.allCases.index(after: currentIndex)
            return Self.allCases[nextIndex == Self.allCases.endIndex ? Self.allCases.endIndex - 1 : nextIndex]
        }

        func feedbackString(isObjectFlippable: Bool) -> String {
            switch self {
                case .orbit1:
                    return LocString.segment1FeedbackString
                case .orbit2, .orbit3:
                    if isObjectFlippable {
                        return LocString.segment2And3FlippableFeedbackString
                    } else {
                        if case .orbit2 = self {
                            return LocString.segment2UnflippableFeedbackString
                        }
                        return LocString.segment3UnflippableFeedbackString
                    }
            }
        }

        func feedbackVideoName(for interfaceIdiom: UIUserInterfaceIdiom, isObjectFlippable: Bool) -> String {
            switch self {
                case .orbit1:
                    return interfaceIdiom == .pad ? "ScanPasses-iPad-FixedHeight-1" : "ScanPasses-iPhone-FixedHeight-1"
                case .orbit2:
                    let iPhoneVideoName = isObjectFlippable ? "ScanPasses-iPhone-FixedHeight-2" : "ScanPasses-iPhone-FixedHeight-unflippable-low"
                    let iPadVideoName = isObjectFlippable ? "ScanPasses-iPad-FixedHeight-2" : "ScanPasses-iPad-FixedHeight-unflippable-low"
                    return interfaceIdiom == .pad ? iPadVideoName : iPhoneVideoName
                case .orbit3:
                    let iPhoneVideoName = isObjectFlippable ? "ScanPasses-iPhone-FixedHeight-3" : "ScanPasses-iPhone-FixedHeight-unflippable-high"
                    let iPadVideoName = isObjectFlippable ? "ScanPasses-iPad-FixedHeight-3" : "ScanPasses-iPad-FixedHeight-unflippable-high"
                    return interfaceIdiom == .pad ? iPadVideoName : iPhoneVideoName
            }
        }

        static func < (lhs: AppDataModel.Orbit, rhs: AppDataModel.Orbit) -> Bool {
            guard let lhsIndex = Self.allCases.firstIndex(of: lhs),
                  let rhsIndex = Self.allCases.firstIndex(of: rhs) else {
                return false
            }
            return lhsIndex < rhsIndex
        }
    }
}

extension AppDataModel {
    // A segment can have n orbits. An orbit can reset to go from the capturing state back to it's initial state.
    enum OrbitState {
        case initial, capturing
    }
}
