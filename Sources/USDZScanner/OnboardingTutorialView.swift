/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The guidance view that shows the video tutorial or the point cloud on the review screen.
*/

import Foundation
import RealityKit
import SwiftUI

/// The view that either shows the point cloud or plays the guidance tutorials on the review screens.
/// This depends on `currentState` in `onboardingStateMachine`.
@available(iOS 17.0, *)
struct OnboardingTutorialView: View {
    @EnvironmentObject var appModel: AppDataModel
    var session: ObjectCaptureSession
    @ObservedObject var onboardingStateMachine: OnboardingStateMachine

    var body: some View {
        VStack {
            ZStack {
                if shouldShowTutorialInReview, let url = tutorialUrl {
                    TutorialVideoView(url: url, isInReviewSheet: true)
                        .padding(30)
                } else {
                    ObjectCapturePointCloudView(session: session)
                        .padding(30)
                }

                VStack {
                    Spacer()
                    HStack {
                        ForEach(AppDataModel.Orbit.allCases) { orbit in
                            if let orbitImageName = getOrbitImageName(orbit: orbit) {
                                Text(Image(systemName: orbitImageName))
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.bottom)
                }
            }
            .frame(maxHeight: .infinity)

            VStack {
                Text(title)
                    .font(.largeTitle)
                    .lineLimit(3)
                    .minimumScaleFactor(0.5)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                    .frame(maxWidth: .infinity)

                Text(detailText)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.leading, UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30)
            .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30)

        }
    }

    private var shouldShowTutorialInReview: Bool {
        switch onboardingStateMachine.currentState {
            case .flipObject, .flipObjectASecondTime, .captureFromLowerAngle, .captureFromHigherAngle:
                return true
            default:
                return false
        }
    }

    private let onboardingStateToTutorialNameMapOnIphone: [OnboardingState: String] = [
        .flipObject: "ScanPasses-iPhone-FixedHeight-2",
        .flipObjectASecondTime: "ScanPasses-iPhone-FixedHeight-3",
        .captureFromLowerAngle: "ScanPasses-iPhone-FixedHeight-unflippable-low",
        .captureFromHigherAngle: "ScanPasses-iPhone-FixedHeight-unflippable-high"
    ]

    private let onboardingStateToTutorialNameMapOnIpad: [OnboardingState: String] = [
        .flipObject: "ScanPasses-iPad-FixedHeight-2",
        .flipObjectASecondTime: "ScanPasses-iPad-FixedHeight-3",
        .captureFromLowerAngle: "ScanPasses-iPad-FixedHeight-unflippable-low",
        .captureFromHigherAngle: "ScanPasses-iPad-FixedHeight-unflippable-high"
    ]

    private var tutorialUrl: URL? {
        let videoName: String
        if UIDevice.current.userInterfaceIdiom == .pad {
            videoName = onboardingStateToTutorialNameMapOnIpad[onboardingStateMachine.currentState] ?? "ScanPasses-iPad-FixedHeight-1"
        } else {
            videoName = onboardingStateToTutorialNameMapOnIphone[onboardingStateMachine.currentState] ?? "ScanPasses-iPhone-FixedHeight-1"
        }
        return Bundle.module.url(forResource: videoName, withExtension: "mp4")
    }

    private func getOrbitImageName(orbit: AppDataModel.Orbit) -> String? {
        guard let session = appModel.objectCaptureSession else { return nil }
        let orbitCompleted = session.userCompletedScanPass
        let orbitCompleteImage = orbit <= appModel.orbit ? orbit.imageSelected : orbit.image
        let orbitNotCompleteImage = orbit < appModel.orbit ? orbit.imageSelected : orbit.image
        return orbitCompleted ? orbitCompleteImage : orbitNotCompleteImage
    }

    private let onboardingStateToTitleMap: [OnboardingState: String] = [
        .tooFewImages: LocalizedString.tooFewImagesTitle,
        .firstSegmentNeedsWork: LocalizedString.firstSegmentNeedsWorkTitle,
        .firstSegmentComplete: LocalizedString.firstSegmentCompleteTitle,
        .secondSegmentNeedsWork: LocalizedString.secondSegmentNeedsWorkTitle,
        .secondSegmentComplete: LocalizedString.secondSegmentCompleteTitle,
        .thirdSegmentNeedsWork: LocalizedString.thirdSegmentNeedsWorkTitle,
        .thirdSegmentComplete: LocalizedString.thirdSegmentCompleteTitle,
        .flipObject: LocalizedString.flipObjectTitle,
        .flipObjectASecondTime: LocalizedString.flipObjectASecondTimeTitle,
        .flippingObjectNotRecommended: LocalizedString.flippingObjectNotRecommendedTitle,
        .captureFromLowerAngle: LocalizedString.captureFromLowerAngleTitle,
        .captureFromHigherAngle: LocalizedString.captureFromHigherAngleTitle
    ]

    private var title: String {
        onboardingStateToTitleMap[onboardingStateMachine.currentState] ?? ""
    }

    private let onboardingStateTodetailTextMap: [OnboardingState: String] = [
        .tooFewImages: String(format: LocalizedString.tooFewImagesDetailText, AppDataModel.minNumImages),
        .firstSegmentNeedsWork: LocalizedString.firstSegmentNeedsWorkDetailText,
        .firstSegmentComplete: LocalizedString.firstSegmentCompleteDetailText,
        .secondSegmentNeedsWork: LocalizedString.secondSegmentNeedsWorkDetailText,
        .secondSegmentComplete: LocalizedString.secondSegmentCompleteDetailText,
        .thirdSegmentNeedsWork: LocalizedString.thirdSegmentNeedsWorkDetailText,
        .thirdSegmentComplete: LocalizedString.thirdSegmentCompleteDetailText,
        .flipObject: LocalizedString.flipObjectDetailText,
        .flipObjectASecondTime: LocalizedString.flipObjectASecondTimeDetailText,
        .flippingObjectNotRecommended: LocalizedString.flippingObjectNotRecommendedDetailText,
        .captureFromLowerAngle: LocalizedString.captureFromLowerAngleDetailText,
        .captureFromHigherAngle: LocalizedString.captureFromHigherAngleDetailText
    ]

    private var detailText: String {
        onboardingStateTodetailTextMap[onboardingStateMachine.currentState] ?? ""
    }
}
