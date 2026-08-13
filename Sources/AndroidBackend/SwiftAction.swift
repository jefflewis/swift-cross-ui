import JavaKit

/// A Java class that allows us to pass Swift `() -> Void` closures to Java code.
@JavaClass("dev.swiftcrossui.androidbackend.SwiftAction")
open class SwiftAction: JavaObject {
    @JavaMethod
    @_nonoverride public convenience init(
        closureObject: SwiftObject?,
        environment: JNIEnvironment? = nil
    )

    @JavaMethod
    open func getClosureObject() -> SwiftObject?
}

@JavaImplementation("dev.swiftcrossui.androidbackend.SwiftAction")
extension SwiftAction {
    @JavaMethod
    public func callSwift() {
        guard let object = getClosureObject(),
              let action = object.valueObject().value as? () -> Void
        else {
            log("Warning: SwiftAction didn't hold a closure")
            return
        }
        action()
    }
}

extension SwiftAction {
    convenience init(environment: JNIEnvironment? = nil, action: @escaping () -> Void) {
        let object = SwiftObject(action, environment: environment)
        self.init(closureObject: object, environment: environment)
    }
}
