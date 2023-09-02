/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Generates human-readable strings for each feedback state.
*/

import Foundation
import RealityKit
import SwiftUI

@available(iOS 17.0, *)
/// Keeps the UI string conversions all in one place for simplicity
final class FeedbackMessages {
    /// Returns the human readable string to display for the given feedback.
    ///
    /// If there's more than one feedback entry, this method concatenates the entries together with a new line in between them.
    static func getFeedbackString(for feedback: ObjectCaptureSession.Feedback) -> String? {
        switch feedback {

            case .objectTooFar:
                return NSLocalizedString(
                    "Move Closer (Object Capture)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Move Closer",
                    comment: "Feedback message to move closer for object capture")

            case .objectTooClose:
                return NSLocalizedString(
                    "Move Farther Away (Object Capture)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Move Farther Away",
                    comment: "Feedback message to move back for object capture")

            case .environmentTooDark, .environmentLowLight:
                return NSLocalizedString(
                    "More Light Required (Object Capture)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "More Light Required",
                    comment: "Feedback message to increase lighting for object capture")

            case .movingTooFast:
                return NSLocalizedString(
                    "Move slower (Object Capture)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Move slower",
                    comment: "Feedback message to slow down for object capture")

            case .outOfFieldOfView:
                return NSLocalizedString(
                    "Aim at your object (Object Capture)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Aim at your object",
                    comment: "Feedback message to aim at your object for object capture")

            default:
                return nil
        }
    }
}
