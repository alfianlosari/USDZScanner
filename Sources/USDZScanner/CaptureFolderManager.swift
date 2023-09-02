/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class that supports the creation, listing, and filename support of a capture folder.
*/

import Dispatch
import Foundation
import os

class CaptureFolderManager: ObservableObject {
    static let logger = Logger(subsystem: GuidedCaptureSampleApp.subsystem,
                                category: "CaptureFolderManager")

    private let logger = CaptureFolderManager.logger

    // The top-level capture directory that contains Images and Snapshots subdirectories.
    // This sample automatically creates this directory at `init()` with timestamp.
    let rootScanFolder: URL

    // Subdirectory of `rootScanFolder` for images
    let imagesFolder: URL

    // Subdirectory of `rootScanFolder` for snapshots
    let snapshotsFolder: URL

    // Subdirectory to output model files.
    let modelsFolder: URL

    @Published var shots: [ShotFileInfo] = []

    init?() {
        guard let newFolder = CaptureFolderManager.createNewScanDirectory() else {
            logger.error("Unable to create a new scan directory.")
            return nil
        }
        rootScanFolder = newFolder

        // Creates the subdirectories.
        imagesFolder = newFolder.appendingPathComponent("Images/")
        guard CaptureFolderManager.createDirectoryRecursively(imagesFolder) else {
            return nil
        }

        snapshotsFolder = newFolder.appendingPathComponent("Snapshots/")
        guard CaptureFolderManager.createDirectoryRecursively(snapshotsFolder) else {
            return nil
        }

        modelsFolder = newFolder.appendingPathComponent("Models/")
        guard CaptureFolderManager.createDirectoryRecursively(modelsFolder) else {
            return nil
        }
    }

    func loadShots() async throws {
        logger.debug("Loading snapshots (async)...")

        var newShots: [ShotFileInfo] = []

        let imgUrls = try FileManager.default
            .contentsOfDirectory(at: imagesFolder,
                                 includingPropertiesForKeys: [],
                                 options: [.skipsHiddenFiles])
            .filter { $0.isFileURL
                && $0.lastPathComponent.hasSuffix(CaptureFolderManager.heicImageExtension)
            }
        for imgUrl in imgUrls {
            guard let shotFileInfo = ShotFileInfo(url: imgUrl) else {
                logger.error("Can't get shotId from url: \"\(imgUrl)\")")
                continue
            }

            newShots.append(shotFileInfo)
        }

        // Sorts and then makes the final replacement in the published array.
        newShots.sort(by: { $0.id < $1.id })
        shots = newShots
    }

    /// Retrieves the image id from of an existing file at a URL.\
    ///
    /// - Parameter url: URL of the photo for which this method returns the image id.
    /// - Returns: The image ID if `url` is valid; otherwise `nil`.
    static func parseShotId(url: URL) -> UInt32? {
        let photoBasename = url.deletingPathExtension().lastPathComponent
        logger.debug("photoBasename = \(photoBasename)")

        guard let endOfPrefix = photoBasename.lastIndex(of: "_") else {
            logger.warning("Can't get endOfPrefix!")
            return nil
        }

        let imgPrefix = photoBasename[...endOfPrefix]
        guard imgPrefix == imageStringPrefix else {
            logger.warning("Prefix doesn't match!")
            return nil
        }

        let idString = photoBasename[photoBasename.index(after: endOfPrefix)...]
        guard let id = UInt32(idString) else {
            logger.warning("Can't convert idString=\"\(idString)\" to uint32!")
            return nil
        }

        return id
    }

    // Returns the basename for file with the given `id`.
    static func imageIdString(for id: UInt32) -> String {
        return String(format: "%@%04d", imageStringPrefix, id)
    }

    /// Returns the file URL for the HEIC image that matches the specified
    /// image id  in a specified output directory.
    ///
    /// - Parameters:
    ///   - outputDir: The directory where the capture session saves images.
    ///   - id: Identifier of an image.
    /// - Returns: `outputDir` URL if the image exists
    static func heicImageUrl(in outputDir: URL, id: UInt32) -> URL {
        return outputDir
            .appendingPathComponent(imageIdString(for: id))
            .appendingPathExtension(heicImageExtension)
    }

    /// Creates a new Scans directory based on the current timestamp in the top level Documents
    /// folder.
    /// - Returns: The new Scans folder's file URL, or `nil` on error.
    static func createNewScanDirectory() -> URL? {
        guard let capturesFolder = rootScansFolder() else {
            logger.error("Can't get user document dir!")
            return nil
        }

        let formatter = ISO8601DateFormatter()
        let timestamp = formatter.string(from: Date())
        let newCaptureDir = capturesFolder
            .appendingPathComponent(timestamp, isDirectory: true)

        logger.log("Creating capture path: \"\(String(describing: newCaptureDir))\"")
        let capturePath = newCaptureDir.path
        do {
            try FileManager.default.createDirectory(atPath: capturePath,
                                                    withIntermediateDirectories: true)
        } catch {
            logger.error("Failed to create capturepath=\"\(capturePath)\" error=\(String(describing: error))")
            return nil
        }
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: capturePath, isDirectory: &isDir)
        guard exists && isDir.boolValue else {
            return nil
        }

        return newCaptureDir
    }

    // - MARK: Private interface below.

    /// Creates all path components for the output directory.
    /// - Parameter outputDir: A URL for the new output directory.
    /// - Returns: A Boolean value that indicates whether the method succeeds,
    /// otherwise `false` if it encounters an error, such as if the file already
    /// exists or the method couldn't create the file.
    private static func createDirectoryRecursively(_ outputDir: URL) -> Bool {
        guard outputDir.isFileURL else {
            return false
        }
        let expandedPath = outputDir.path
        var isDirectory: ObjCBool = false
        let fileManager = FileManager()
        guard !fileManager.fileExists(atPath: outputDir.path, isDirectory: &isDirectory) else {
            logger.error("File already exists at \(expandedPath, privacy: .private)")
            return false
        }

        logger.log("Creating dir recursively: \"\(expandedPath, privacy: .private)\"")

        let result: ()? = try? fileManager.createDirectory(atPath: expandedPath,
                                                           withIntermediateDirectories: true)

        guard result != nil else {
            return false
        }

        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: expandedPath, isDirectory: &isDir) && isDir.boolValue else {
            logger.error("Dir \"\(expandedPath, privacy: .private)\" doesn't exist after creation!")
            return false
        }

        logger.log("... success creating dir.")
        return true
    }

    // Constants this sample appends in front of the capture id to get a file basename.
    private static let imageStringPrefix = "IMG_"
    private static let heicImageExtension = "HEIC"

    /// Returns the app documents folder for all our captures.
    private static func rootScansFolder() -> URL? {
        guard let documentsFolder =
                try? FileManager.default.url(for: .documentDirectory,
                                             in: .userDomainMask,
                                             appropriateFor: nil, create: false) else {
            return nil
        }
        return documentsFolder.appendingPathComponent("Scans/", isDirectory: true)
    }
}
