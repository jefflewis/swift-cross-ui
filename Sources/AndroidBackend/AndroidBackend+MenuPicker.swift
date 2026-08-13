import AndroidKit
import SwiftCrossUI

@JavaClass("dev.swiftcrossui.androidbackend.CustomSpinner")
class CustomSpinner: AndroidKit.Spinner {
    @JavaMethod
    @_nonoverride convenience init(
        _ activity: AndroidApp.Activity?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    func update(_ onChange: SwiftAction?, _ options: [String], _ isEnabled: Bool)

    @JavaMethod
    func selectOption(_ index: Int32)
}

extension AndroidBackend {
    public func createPicker(style: BackendPickerStyle) -> Widget {
        guard style == .menu else {
            fatalError("Unsupported picker style \(style)")
        }
        return CustomSpinner(Self.activity, environment: Self.env.env)
            .as(AndroidKit.View.self)!
    }

    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping (Int?) -> Void
    ) {
        let picker = picker.as(CustomSpinner.self)!
        let action = SwiftAction(environment: Self.env.env) {
            let position = picker.getSelectedItemPosition()
            let invalidPosition: Int32 = try! JavaClass<AndroidKit.AdapterView>().INVALID_POSITION
            onChange(position == invalidPosition ? nil : Int(position))
        }
        picker.update(action, options, environment.isEnabled)
    }

    public func setSelectedOption(ofPicker picker: Widget, to selectedOption: Int?) {
        picker.as(CustomSpinner.self)!.selectOption(Int32(selectedOption ?? -1))
    }
}
