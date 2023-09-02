/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A timed queue of messages that modifies published properties.
*/

import Combine
import Dispatch
import Foundation
import SwiftUI

/// Adds a message to a queue that appears with a minimum duration.
///
/// The duration extends if the queue refreshes and automatically removes items for which the timer is expired.
class TimedMessageList: ObservableObject {
    /// A unique container for a message string and timestamps.
    ///
    /// SwiftUI can consistently animate each `Message` instance because the
    /// type adopts the `Identifiable` proptocol.
    /// The `id` property is unique and consistent for the life of the instance,
    /// as opposed to the `message` property, which may have identical content
    /// to another message instance.
    struct Message: Identifiable {
        /// A stable identifier which ensures that animations work properly.
        let id = UUID()

        /// The text of the message.
        let message: String

        /// The message's creation date.
        let startTime = Date()

        /// The message's expiration date.
        ///
        /// The property is `private` so the app can maintain a single timer state.
        /// Only the `TimedMessageList` type can add time extensions.
        fileprivate(set) var endTime: Date?

        init(_ string: String) {
            message = string
        }

        /// Returns a Boolean that indicates whether the message's expiration
        /// date is in the past.
        func hasExpired() -> Bool {
            guard let endTime else {
                return false
            }
            return Date() >= endTime
        }
    }

    /// The list's next message in its queue.
    @Published var activeMessage: Message? = nil

    /// An ordered list of the messages in the list.
    private var messages = [Message]() {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))

            if activeMessage?.message != messages.first?.message {
                withAnimation {
                    activeMessage = messages.first
                }
            }
        }
    }

    /// A timer the message list configures to fire at the time when the
    /// message with the nearest expiration date (in the future) expires.
    private var timer: Timer?

    private let feedbackMessageMinimumDurationSecs: Double = 2.0

    /// Creates a new message from a string and adds it to the list.
    /// - Parameter string: The text of a message.
    func add(_ msg: String) {
        dispatchPrecondition(condition: .onQueue(.main))

        if let index = messages.lastIndex(where: { $0.message == msg }) {
            messages[index].endTime = nil
        } else {
            messages.append(Message(msg))
        }
        setTimer()
    }

    /// Removes the message with the given string.
    /// - Parameter msg: A string to display for the message
    func remove(_ msg: String) {
        dispatchPrecondition(condition: .onQueue(.main))

        guard let index = messages.lastIndex(where: { $0.message == msg }) else { return }
        var endTime = Date()
        let earliestAcceptableEndTime = messages[index].startTime + feedbackMessageMinimumDurationSecs
        if endTime < earliestAcceptableEndTime {
            endTime = earliestAcceptableEndTime
        }
        messages[index].endTime = endTime
        setTimer()
    }

    /// Sets timer to fire when the message with the nearest expiration
    /// date (in the future) expires.
    private func setTimer() {
        dispatchPrecondition(condition: .onQueue(.main))

        timer?.invalidate()
        timer = nil

        // Removes expired timers.
        cullExpired()

        // Finds the next expiration time in the future.
        if let nearestEndTime = (messages.compactMap { $0.endTime }).min() {

            // Makes a new timer that fires when the message expires.
            let duration = nearestEndTime.timeIntervalSinceNow
            timer = Timer.scheduledTimer(timeInterval: duration,
                                         target: self,
                                         selector: #selector(onTimer),
                                         userInfo: nil,
                                         repeats: false)

        }
    }

    private func cullExpired() {
        dispatchPrecondition(condition: .onQueue(.main))

        withAnimation {
            messages.removeAll(where: { $0.hasExpired() })
        }
    }

    @objc
    private func onTimer() {
        dispatchPrecondition(condition: .onQueue(.main))
        timer?.invalidate()
        cullExpired()
        setTimer()
    }
}
