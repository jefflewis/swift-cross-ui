import Foundation
import JavaKit

// Adapted from https://github.com/PureSwift/Android/blob/e980a12f6d7236bed32ff687b40dae2366ac8e91/Demo/app/src/main/swift/JavaRetainedValue.swift#L13
/// Java class that retains a Swift value for the duration of its lifetime.
@JavaClass("dev.swiftcrossui.androidbackend.SwiftObject")
open class SwiftObject: JavaObject {
    @JavaMethod
    @_nonoverride public convenience init(swiftObject: Int64, type: String, environment: JNIEnvironment? = nil)

    @JavaMethod
    open func getSwiftObject() -> Int64

    @JavaMethod
    open func getType() -> String
}

@JavaImplementation("dev.swiftcrossui.androidbackend.SwiftObject")
extension SwiftObject {
    @JavaMethod
    public func toStringSwift() -> String {
        "[a Swift object]"
    }

    @JavaMethod
    public func finalizeSwift() {
        // release owned swift value
        release()
    }
}

extension SwiftObject {
    convenience init<T>(_ value: T, environment: JNIEnvironment? = nil) {
        let box = JavaRetainedValue(value)
        let type = box.type
        self.init(swiftObject: box.id, type: type, environment: environment)
        // retain value
        retain(box)
    }

    func valueObject() -> JavaRetainedValue {
        let id = getSwiftObject()
        guard let object = Self.store.withLock({ $0[id] }) else {
            fatalError()
        }
        return object
    }
}

private extension SwiftObject {
    static let store = RetainedStore()

    func retain(_ value: JavaRetainedValue) {
        Self.store.withLock { $0[value.id] = value }
    }

    func release() {
        let id = getSwiftObject()
        Self.store.withLock { $0[id] = nil }
    }
}

private final class RetainedStore: @unchecked Sendable {
    let lock = NSLock()
    var values = [JavaRetainedValue.ID: JavaRetainedValue]()

    func withLock<T>(_ body: (inout [JavaRetainedValue.ID: JavaRetainedValue]) -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body(&values)
    }
}

/// Swift Object retained until released by Java object.
final class JavaRetainedValue: Identifiable, @unchecked Sendable {
    let value: Any

    var type: String {
        String(describing: Swift.type(of: value))
    }

    var id: Int64 {
        Int64(ObjectIdentifier(self).hashValue)
    }

    init<T>(_ value: T) {
        self.value = value
    }
}
