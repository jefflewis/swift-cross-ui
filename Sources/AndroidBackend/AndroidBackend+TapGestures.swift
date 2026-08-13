import AndroidKit
import SwiftCrossUI

extension AndroidBackend {
    public func createTapGestureTarget(wrapping child: Widget, gesture: TapGesture) -> Widget {
        child
    }

    public func updateTapGestureTarget(
        _ tapGestureTarget: Widget,
        gesture: TapGesture,
        environment: EnvironmentValues,
        action: @escaping () -> Void
    ) {
        let listener = ViewOnClickListener(action: action, environment: Self.env.env)
        tapGestureTarget.setOnClickListener(
            listener.as(AndroidView.View.OnClickListener.self)
        )
        tapGestureTarget.setEnabled(environment.isEnabled)
    }
}
