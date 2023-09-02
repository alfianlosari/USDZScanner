/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Value type for holding the various info about a particular snapshot file.
*/

import Combine
import Foundation
import SwiftUI
import UIKit

struct ShotFileInfo {
    let fileURL: URL
    let id: UInt32

    init?(url: URL) {
        fileURL = url
        guard let shotID = CaptureFolderManager.parseShotId(url: url) else {
            return nil
        }

        id = shotID
    }
}

extension ShotFileInfo: Identifiable { }
