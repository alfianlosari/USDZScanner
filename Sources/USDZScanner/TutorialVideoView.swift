/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view that plays the tutorial.
*/

import SwiftUI

struct TutorialVideoView: View {
    @EnvironmentObject var appModel: AppDataModel
    let url: URL
    let isInReviewSheet: Bool
    @State var isShowing = false

    private let textDelay: TimeInterval = 0.3
    private let animationDuration: TimeInterval = 4
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            PlayerView(
                url: url,
                isTransparent: true,
                isStacked: false,
                isInverted: isInReviewSheet && colorScheme == .light,
                shouldLoop: false
            )
            .opacity(isShowing ? 1 : 0)
            .overlay(alignment: .bottom) {
                if !isInReviewSheet {
                    Text(appModel.orbit.feedbackString(isObjectFlippable: appModel.isObjectFlippable))
                        .font(.headline)
                        .opacity(isShowing ? 1 : 0)
                        .padding(.bottom, 16)
                }
            }
            if isInReviewSheet {
                Spacer(minLength: 28)
            }
        }
        .foregroundColor(.white)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + textDelay) {
                withAnimation {
                    isShowing = true
                }
            }
            if !isInReviewSheet {
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    appModel.orbitState = .capturing
                }
            }
        }
    }
}
