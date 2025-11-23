import UIKit
import SwiftUI

extension UIDevice {
    public struct DidShakeNotification: NotificationCenter.MainActorMessage {
        public typealias Subject = Void
    }
}

extension NotificationCenter.MessageIdentifier where Self == NotificationCenter.BaseMessageIdentifier<UIDevice.DidShakeNotification> {
    public static var didShake: NotificationCenter.BaseMessageIdentifier<UIDevice.DidShakeNotification> {
        .init()
    }
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        if motion == .motionShake {
            NotificationCenter.default.post(UIDevice.DidShakeNotification())
        }
    }
}

struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void
    @State private var token: NotificationCenter.ObservationToken?

    func body(content: Content) -> some View {
        content
            .onAppear {
                token = NotificationCenter.default
                    .addObserver(of: UIDevice.DidShakeNotification.Subject.self, for: .didShake) { _ in
                        action()
                    }
            }
            .onDisappear {
                if let token {
                    NotificationCenter.default.removeObserver(token)
                }
            }
    }
}

extension View {
    func onShake(_ action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}
