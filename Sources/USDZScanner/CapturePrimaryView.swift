/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Top-level view for the object capture session that shows the info panel and other items during the session.
*/

import Foundation
import RealityKit
import SwiftUI

@available(iOS 17.0, *)
struct CapturePrimaryView: View {
    @EnvironmentObject var appModel: AppDataModel
    var session: ObjectCaptureSession

    // Pauses the scanning and shows tutorial pages. This sample passes it as
    // a binding to the two views so buttons can change the state.
    @State var showInfo: Bool = false
    @State private var showOnboardingView: Bool = false

    var body: some View {
        ZStack {
            ObjectCaptureView(session: session,
                              cameraFeedOverlay: { GradientBackground() })
            .blur(radius: appModel.showPreviewModel ? 45 : 0)
            .transition(.opacity)
            if shouldShowOverlayView {
                CaptureOverlayView(session: session, showInfo: $showInfo)
            }
        }
        .sheet(isPresented: $showInfo) {
            HelpPageView(showInfo: $showInfo)
                .padding()
        }
        .sheet(isPresented: $showOnboardingView,
               onDismiss: { [weak appModel] in appModel?.setPreviewModelState(shown: false) },
               content: {[weak appModel] in
            if let appModel = appModel, let onboardingState = appModel.determineCurrentOnboardingState() {
                OnboardingView(state: onboardingState)
            }
        })
        .task {
            for await userCompletedScanPass in session.userCompletedScanPassUpdates where userCompletedScanPass {
                    appModel.setPreviewModelState(shown: true)
            }
        }
        .onChange(of: appModel.showPreviewModel, {_, showPreviewModel in
            if !showInfo {
                showOnboardingView = showPreviewModel
            }
        })
        .onChange(of: showInfo) {
            appModel.setPreviewModelState(shown: showInfo)
        }
        .onAppear(perform: {
            UIApplication.shared.isIdleTimerDisabled = true
        })
        .onDisappear(perform: {
            UIApplication.shared.isIdleTimerDisabled = false
        })
        .id(session.id)
    }

    private var shouldShowOverlayView: Bool {
        !showInfo && !appModel.showPreviewModel && !session.isPaused && session.cameraTracking == .normal
    }
}

private struct GradientBackground: View {
    private let gradient = LinearGradient(
        colors: [.black.opacity(0.4), .clear],
        startPoint: .top,
        endPoint: .bottom
    )
    private let frameHeight: CGFloat = 300

    var body: some View {
        VStack {
            gradient
                .frame(height: frameHeight)

            Spacer()

            gradient
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .frame(height: frameHeight)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
