/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Custom SwiftUI View for showing the tutorial stack.
*/

import SwiftUI

/// Top-level view containing a tabbed view of each of the help pages.
struct HelpPageView: View {
    @Binding var showInfo: Bool

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Capture Help").foregroundColor(.secondary)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showInfo = false
                        }},
                           label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.init(white: 0.7, opacity: 0.5))
                            .font(.title)
                    })
                }

                TabView {
                    ObjectHelpPageView()
                    EnvironmentHelpPageView()
                }
                .tabViewStyle(PageTabViewStyle())
                .onAppear() {
                    UIPageControl.appearance().currentPageIndicatorTintColor = .black
                    UIPageControl.appearance().pageIndicatorTintColor = .lightGray
                }

            }.padding()
        }
        .navigationTitle("Scanning Info")
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private struct TutorialPageView: View {
    let pageName: String
    let imageName: String
    let imageCaption: String
    let prosTitle: String
    let pros: [String]
    let consTitle: String
    let cons: [String]

    var body: some View {
        GeometryReader { geomReader in
            VStack(alignment: .leading) {
                Text(pageName)
                    .foregroundColor(.primary)
                    .font(.largeTitle)
                    .bold()

                Text(imageCaption)
                    .foregroundColor(.secondary)

                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                // Leaves 25% margins.
                    .frame(width: 0.85 * geomReader.size.width)
                    .padding(.leading)

                ProConListView(prosTitle: prosTitle, pros: pros, consTitle: consTitle, cons: cons)

                Spacer()
            }
            .frame(width: geomReader.size.width, height: geomReader.size.height)
        }
        .navigationBarTitle(pageName, displayMode: .inline)
    }
}

private struct ObjectHelpPageView: View {
    var body: some View {
        let caption = "Opaque, matte objects with varied surface textures scan best. Capture all sides of your object in a series of orbits.\n"

        TutorialPageView(pageName: "Capturing Objects",
                         imageName: "ObjectCharacteristicsTips",
                         imageCaption: caption,
                         prosTitle: "Ideal Object Characteristics",
                         pros: ["Varied Surface Texture",
                                "Non-reflective, matte surface",
                                "Solid, opaque" ],
                         consTitle: "May Reduce Quality",
                         cons: ["Shiny materials",
                                "Transparent, transluscent objects"])
    }
}

private struct EnvironmentHelpPageView: View {
    var body: some View {
        let caption = "Make sure you have even, good lighting and a stable environment for scanning.  If scanning outdoors, cloudy days work best.\n"
        TutorialPageView(pageName: "Environment",
                         imageName: "EnvironmentTips",
                         imageCaption: caption,
                         prosTitle: "Ideal Environment Characteristics",
                         pros: ["Diffuse, consistent lighting",
                                "Space around intended object",
                                " "],
                         consTitle: "May Reduce Quality",
                         cons: ["Sunny, directional lighting",
                                "Inconsistent shadows"])
    }
}

private struct ProConListView: View {
    let prosTitle: String
    let pros: [String]
    let consTitle: String
    let cons: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Divider()
                .padding(.bottom, 5.0)

            HStack {
                Text(prosTitle)
                    .bold()

                Spacer()

                Text(Image(systemName: "checkmark.circle"))
                    .bold()
                    .foregroundColor(.green)
            }

            ForEach(pros, id: \.self) { pro in
                Text(pro)
                    .foregroundColor(.secondary)
            }

            Text("HIDDEN SPACER")
                .hidden()

            Divider()
                .padding(.bottom, 5.0)

            HStack {
                Text(consTitle)
                    .bold()

                Spacer()

                Text(Image(systemName: "xmark.circle"))
                    .bold()
                    .foregroundColor(.red)
            }

            ForEach(cons, id: \.self) { con in
                Text(con)
                    .foregroundColor(.secondary)
            }
        }
    }
}

/// Green checkmark label used to denote a "Do" example.
private struct PositiveLabel: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Group {
            Label(title: {
                Text(text)
                    .foregroundColor(.secondary)
            }, icon: {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            })
        }
    }
}

/// Red x-mark label used to denote a "Don't" example.
private struct NegativeLabel: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Group {
            Label(title: {
                Text(text)
                    .foregroundColor(.secondary)
            }, icon: {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.red)
            })
        }
    }
}

#if DEBUG
struct HelpPageView_Previews: PreviewProvider {
    @State static var showInfo = false

    static var previews: some View {
        HelpPageView(showInfo: $showInfo)
    }
}
#endif // DEBUG
