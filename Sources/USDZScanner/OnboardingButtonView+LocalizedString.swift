/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The localized strings the onboarding button view uses.
*/

import Foundation

extension OnboardingButtonView {
    struct LocalizedString {
        static let `continue` = NSLocalizedString(
            "Continue (Object Capture, Point Cloud)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Continue",
            comment: "Title of button to continue to flip the object and capture more."
        )

        static let finish = NSLocalizedString(
            "Finish (Object Capture, Point Cloud)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Finish",
            comment: "Title for finish button on the object capture screen."
        )

        static let skip = NSLocalizedString(
            "Skip (Object Capture, Point Cloud)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Skip",
            comment: "Title for skip button on the object capture screen."
        )

        static let cannotFlipYourObject = NSLocalizedString(
            "Can't flip your object? (Object Capture, Point Cloud)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Can't flip your object?",
            comment: "Title for button on the object capture screen that lets users indicate that their object cannot be flipped."
        )

        static let flipAnyway = NSLocalizedString(
            "Flip object anyway (Object Capture, Point Cloud)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Flip object anyway",
            comment: "Title for button on the object capture screen that lets users indicate they want to flip their object."
        )

        static let cancel = NSLocalizedString(
            "Cancel (Object Capture, Point Cloud)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Cancel",
            comment: "Title of button to close review page."
        )
    }
}
