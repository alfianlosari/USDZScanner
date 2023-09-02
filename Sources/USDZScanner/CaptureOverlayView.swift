/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A full-screen overlay UI with buttons that control the capture.
*/

import Foundation
import RealityKit
import SwiftUI

@available(iOS 17.0, *)
struct CaptureOverlayView: View {
    @EnvironmentObject var appModel: AppDataModel
    var session: ObjectCaptureSession

    // This sample passes the binding from parent to allow this view
    // to control whether certain panels are shown in `CapturePrimaryView`.
    @Binding var showInfo: Bool

    @State private var hasDetectionFailed = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                CloseButton()
                CancelButton()
                    .opacity(!shouldShowTutorial ? 1 : 0)
                    .disabled(shouldDisableCancelButton ? true : false)
                Spacer()
                NextButton()
                    .opacity(shouldShowNextButton ? 1 : 0)
                    .disabled(!shouldShowNextButton)
            }
            .foregroundColor(.white)

            Spacer()

            if shouldShowTutorial, let url = Bundle.module.url(
                forResource: appModel.orbit.feedbackVideoName(
                    for: UIDevice.current.userInterfaceIdiom,
                    isObjectFlippable: appModel.isObjectFlippable),
                withExtension: "mp4") {
                TutorialVideoView(url: url, isInReviewSheet: false)
                    .frame(maxHeight: horizontalSizeClass == .regular ? 350 : 280)

                Spacer()
            } else if !capturingStarted {
                BoundingBoxGuidanceView(session: session, hasDetectionFailed: hasDetectionFailed)
            }

            HStack(alignment: .bottom, spacing: 0) {
                HStack(spacing: 0) {
                    if case .capturing = session.state {
                        NumOfImagesButton(session: session)
                            .rotationEffect(rotationAngle)
                            .transition(.opacity)
                    } else if case .detecting = session.state {
                        ResetBoundingBoxButton(session: session)
                            .transition(.opacity)
                    } else if case .ready = session.state {
                        FilesButton()
                            .transition(.opacity)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)

                if !capturingStarted {
                    CaptureButton(session: session, isObjectFlipped: appModel.isObjectFlipped, hasDetectionFailed: $hasDetectionFailed)
                        .layoutPriority(1)
                }

                HStack {
                    Spacer()

                    if !capturingStarted {
                        HelpButton(showInfo: $showInfo)
                            .transition(.opacity)
                    } else if case .capturing = session.state {
                        ManualShotButton(session: session)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .opacity(shouldShowTutorial ? 0 : 1) // Keeps tutorial view centered.
        }
        .padding()
        .padding(.horizontal, 15)
        .background(shouldShowTutorial ? Color.black.opacity(0.5) : .clear)
        .allowsHitTesting(!shouldShowTutorial)
        .animation(.default, value: shouldShowTutorial)
        .background {
            if !shouldShowTutorial && appModel.messageList.activeMessage != nil {
                VStack {
                    Rectangle()
                        .frame(height: 130)
                        .hidden()

                    FeedbackView(messageList: appModel.messageList)
                        .layoutPriority(1)
                }
                .rotationEffect(rotationAngle)
            }
        }
        .task {
            for await _ in NotificationCenter.default.notifications(named:
                    UIDevice.orientationDidChangeNotification).map({ $0.name }) {
                withAnimation {
                    deviceOrientation = UIDevice.current.orientation
                }
            }
        }
    }

    private var capturingStarted: Bool {
        switch session.state {
            case .initializing, .ready, .detecting:
                return false
            default:
                return true
        }
    }

    private var shouldShowTutorial: Bool {
        if appModel.orbitState == .initial,
           case .capturing = session.state,
           appModel.orbit == .orbit1 {
            return true
        }
        return false
    }

    private var shouldShowNextButton: Bool {
        capturingStarted && !shouldShowTutorial
    }

    private var shouldDisableCancelButton: Bool {
        shouldShowTutorial || session.state == .ready || session.state == .initializing
    }

    private var rotationAngle: Angle {
        switch deviceOrientation {
            case .landscapeLeft:
                return Angle(degrees: 90)
            case .landscapeRight:
                return Angle(degrees: -90)
            case .portraitUpsideDown:
                return Angle(degrees: 180)
            default:
                return Angle(degrees: 0)
        }
    }
}

@available(iOS 17.0, *)
@MainActor
private struct BoundingBoxGuidanceView: View {
    var session: ObjectCaptureSession
    var hasDetectionFailed: Bool

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        HStack {
            if let guidanceText = guidanceText {
                Text(guidanceText)
                    .font(.callout)
                    .bold()
                    .foregroundColor(.white)
                    .transition(.opacity)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: horizontalSizeClass == .regular ? 400 : 360)
            }
        }
    }

    private var guidanceText: String? {
        if case .ready = session.state {
            if hasDetectionFailed {
                return NSLocalizedString(
                    "Can‘t find your object. It should be larger than 3in (8cm) in each dimension.",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Can‘t find your object. It should be larger than 3in (8cm) in each dimension.",
                    comment: "Feedback message when detection has failed.")
            } else {
                return NSLocalizedString(
                    "Move close and center the dot on your object, then tap Continue. (Object Capture, State)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Move close and center the dot on your object, then tap Continue.",
                    comment: "Feedback message to fill camera feed with object.")
            }
        } else if case .detecting = session.state {
            return NSLocalizedString(
                "Move around to ensure that the whole object is inside the box. Drag handles to manually resize. (Object Capture, State)",
                bundle: AppDataModel.bundleForLocalizedStrings,
                value: "Move around to ensure that the whole object is inside the box. Drag handles to manually resize.",
                comment: "Feedback message to size box to object.")
        } else {
            return nil
        }
    }
}
