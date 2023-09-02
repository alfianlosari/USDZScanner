/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The view that plays the input video.
*/

import AVKit
import SwiftUI

struct PlayerView: UIViewRepresentable {

    /// The location of a video asset.
    let url: URL

    /// A Boolean value that indicates whether the video contains transparent pixesl.
    let isTransparent: Bool

    /// A Boolean value that indicates whether the video contains an alpha mask below it.
    let isStacked: Bool

    /// A Boolean value that indicates whether the video's image is inverted.
    let isInverted: Bool

    /// A Boolean value that indicates whether the player view loops the video.
    let shouldLoop: Bool

    private static let videoSize = CGSize(width: 1280, height: 1080).applying(CGAffineTransformIdentity)
    private static let transparentPixelBufferAttributes = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

    class Coordinator {
        var playerLooper: AVPlayerLooper?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        let playerItem = AVPlayerItem(url: url)
        playerItem.videoComposition = createVideoComposition(for: playerItem)
        let player = AVQueuePlayer(playerItem: playerItem)
        playerView.playerLayer.videoGravity = .resizeAspect
        player.actionAtItemEnd = .pause
        if shouldLoop {
            let playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            context.coordinator.playerLooper = playerLooper
        }
        playerView.player = player
        playerView.playerLayer.pixelBufferAttributes = isTransparent ? Self.transparentPixelBufferAttributes : nil

        return playerView
    }

    func updateUIView(_ playerView: AVPlayerView, context: Context) {
        let currentItemUrl: URL? = (playerView.player?.currentItem?.asset as? AVURLAsset)?.url
        if currentItemUrl != url {
            let playerItem = AVPlayerItem(url: url)
            playerItem.videoComposition = createVideoComposition(for: playerItem)
            playerView.player?.replaceCurrentItem(with: playerItem)
        }
        playerView.player?.play()
    }

    private func createVideoComposition(for playerItem: AVPlayerItem) -> AVVideoComposition {
        let size = PlayerView.videoSize

        let videoSize: CGSize = isStacked ? CGSize(width: size.width, height: size.height / 2.0) : size
        let composition = AVMutableVideoComposition(asset: playerItem.asset, applyingCIFiltersWithHandler: { request in
            let filter: CIFilter

            if isStacked {
                filter = CIFilter(name: "CIBlendWithMask")!
                let sourceRect = CGRect(origin: .zero, size: CGSize(width: videoSize.width, height: videoSize.height))
                let alphaRect = sourceRect.offsetBy(dx: 0, dy: sourceRect.height)
                let transform = CGAffineTransform(translationX: 0, y: -sourceRect.height)
                let inputImage = request.sourceImage.cropped(to: alphaRect).transformed(by: transform)
                let maskImage = request.sourceImage.cropped(to: sourceRect)
                let backgroundImage = CIImage(color: .clear).cropped(to: inputImage.extent)
                filter.setValue(inputImage, forKey: kCIInputImageKey)
                filter.setValue(maskImage, forKey: kCIInputMaskImageKey)
                filter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
            } else {
                filter = CIFilter(name: "CIMaskToAlpha")!
                filter.setValue(request.sourceImage, forKey: kCIInputImageKey)
            }

            if isInverted, let outputImage = filter.outputImage {
                let invertFilterImage = outputImage.applyingFilter("CIColorInvert")
                return request.finish(with: invertFilterImage, context: nil)
            }

            return request.finish(with: filter.outputImage!, context: nil)
        })

        composition.renderSize = videoSize
        return composition
    }
}

class AVPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer! {
        return layer as? AVPlayerLayer
    }

    var player: AVPlayer? {
        get { return playerLayer.player }
        set { playerLayer.player = newValue }
    }
}
