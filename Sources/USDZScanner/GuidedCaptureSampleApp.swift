/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Top-level app structure of the view hierarchy.
*/

import SwiftUI

@main
struct GuidedCaptureSampleApp: App {
    static let subsystem: String = "com.alfianlosari.GuidedCapture"
    @State var isScanObjectPresenting = false
    @State var url: URL?
    
    var body: some Scene {
        WindowGroup {
            if #available(iOS 17.0, *) {
                VStack {
                    
                    Button("Scan Object") {
                        isScanObjectPresenting = true
                    }
                    
                    if let url {
                        Text(url.absoluteString)
                    }
                    
                }
                .sheet(isPresented: $isScanObjectPresenting, content: {
                    USDZScanner { url in
                        self.url = url
                        isScanObjectPresenting = false
                    }
                })
            }
        }
    }
}
