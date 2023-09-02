/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
View to show during the reconstruction phase until the session receives a model output.
*/

import Foundation
import RealityKit
import SwiftUI
import os

@available(iOS 17.0, *)
struct ReconstructionPrimaryView: View {
    @EnvironmentObject var appModel: AppDataModel
    let outputFile: URL
    let onCompletedCallback: (URL) -> Void

    @State private var completed: Bool = false
    @State private var cancelled: Bool = false

    var body: some View {
        if completed && !cancelled {
            ModelView(modelFile: outputFile, endCaptureCallback: { [weak appModel] in
                appModel?.endCapture()
                onCompletedCallback(outputFile)
            })
        } else {
            ReconstructionProgressView(outputFile: outputFile,
                                       completed: $completed,
                                       cancelled: $cancelled)
            .onAppear(perform: {
                UIApplication.shared.isIdleTimerDisabled = true
            })
            .onDisappear(perform: {
                UIApplication.shared.isIdleTimerDisabled = false
            })
            .interactiveDismissDisabled()
        }
    }
}

@available(iOS 17.0, *)
struct ReconstructionProgressView: View {
    static let logger = Logger(subsystem: GuidedCaptureSampleApp.subsystem,
                               category: "ReconstructionProgressView")

    let logger = ReconstructionProgressView.logger

    @EnvironmentObject var appModel: AppDataModel
    let outputFile: URL
    @Binding var completed: Bool
    @Binding var cancelled: Bool

    @State private var progress: Float = 0
    @State private var estimatedRemainingTime: TimeInterval?
    @State private var processingStageDescription: String?
    @State private var pointCloud: PhotogrammetrySession.PointCloud?
    @State private var gotError: Bool = false
    @State private var error: Error?
    @State private var isCancelling: Bool = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var padding: CGFloat {
        horizontalSizeClass == .regular ? 60.0 : 24.0
    }
    private func isReconstructing() -> Bool {
        return !completed && !gotError && !cancelled
    }

    var body: some View {
        VStack(spacing: 0) {
            if isReconstructing() {
                HStack {
                    Button(action: {
                        logger.log("Cancelling...")
                        isCancelling = true
                        appModel.photogrammetrySession?.cancel()
                    }, label: {
                        Text(LocalizedString.cancel)
                            .font(.headline)
                            .bold()
                            .padding(30)
                            .foregroundColor(.blue)
                    })
                    .padding(.trailing)

                    Spacer()
                }
            }

            Spacer()

            TitleView()

            Spacer()

            ProgressBarView(progress: progress,
                            estimatedRemainingTime: estimatedRemainingTime,
                            processingStageDescription: processingStageDescription)
            .padding(padding)

            Spacer()
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
        .alert(
            "Failed:  " + (error != nil  ? "\(String(describing: error!))" : ""),
            isPresented: $gotError,
            actions: {
                Button("OK") {
                    logger.log("Calling restart...")
                    appModel.state = .restart
                }
            },
            message: {}
        )
        .task {
            precondition(appModel.state == .reconstructing)
            assert(appModel.photogrammetrySession != nil)
            let session = appModel.photogrammetrySession!

            let outputs = UntilProcessingCompleteFilter(input: session.outputs)
            do {
                try session.process(requests: [.modelFile(url: outputFile)])
            } catch {
                logger.error("Processing the session failed!")
            }
            for await output in outputs {
                switch output {
                    case .inputComplete:
                        break
                    case .requestProgress(let request, fractionComplete: let fractionComplete):
                        if case .modelFile = request {
                            progress = Float(fractionComplete)
                        }
                    case .requestProgressInfo(let request, let progressInfo):
                        if case .modelFile = request {
                            estimatedRemainingTime = progressInfo.estimatedRemainingTime
                            processingStageDescription = progressInfo.processingStage?.processingStageString
                        }
                    case .requestComplete(let request, _):
                        switch request {
                            case .modelFile(_, _, _):
                                logger.log("RequestComplete: .modelFile")
                            case .modelEntity(_, _), .bounds, .poses, .pointCloud:
                                // Not supported yet
                                break
                            @unknown default:
                                logger.warning("Received an output for an unknown request: \(String(describing: request))")
                        }
                    case .requestError(_, let requestError):
                        if !isCancelling {
                            gotError = true
                            error = requestError
                        }
                    case .processingComplete:
                        if !gotError {
                            completed = true
                            appModel.state = .viewing
                        }
                    case .processingCancelled:
                        cancelled = true
                        appModel.state = .restart
                    case .invalidSample(id: _, reason: _), .skippedSample(id: _), .automaticDownsampling:
                        continue
                    case .stitchingIncomplete:
                        break
                    @unknown default:
                        logger.warning("Received an unknown output: \(String(describing: output))")
                }
            }
            print(">>>>>>>>>> RECONSTRUCTION TASK EXIT >>>>>>>>>>>>>>>>>")
        }
    }

    struct LocalizedString {
        static let cancel = NSLocalizedString(
            "Cancel (Object Reconstruction)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Cancel",
            comment: "Button title to cancel reconstruction")
    }

}

extension PhotogrammetrySession.Output.ProcessingStage {
    var processingStageString: String? {
        switch self {
            case .preProcessing:
                return NSLocalizedString(
                    "Pre-Processing (Reconstruction)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Pre-Processing…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            case .imageAlignment:
                return NSLocalizedString(
                    "Aligning Images (Reconstruction)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Aligning Images…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            case .pointCloudGeneration:
                return NSLocalizedString(
                    "Generating Point Cloud (Reconstruction)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Generating Point Cloud…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            case .meshGeneration:
                return NSLocalizedString(
                    "Generating Mesh (Reconstruction)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Generating Mesh…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            case .textureMapping:
                return NSLocalizedString(
                    "Mapping Texture (Reconstruction)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Mapping Texture…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            case .optimization:
                return NSLocalizedString(
                    "Optimizing (Reconstruction)",
                    bundle: AppDataModel.bundleForLocalizedStrings,
                    value: "Optimizing…",
                    comment: "Feedback message during the object reconstruction phase."
                )
            default:
                return nil
        }
    }
}

private struct TitleView: View {
    var body: some View {
        Text(LocalizedString.processingTitle)
            .font(.largeTitle)
            .fontWeight(.bold)

    }

    private struct LocalizedString {
        static let processingTitle = NSLocalizedString(
            "Processing title (Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Processing",
            comment: "Title of processing view during processing phase."
        )
    }
}
