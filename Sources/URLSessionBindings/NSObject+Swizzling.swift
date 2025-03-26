import Foundation

extension NSObject {
    static func swizzleHandler(
        original originalSelector: Selector,
        replacement swizzledSelector: Selector,
        for swizzleDestination: AnyClass
    ) -> () -> Void {
        return {
            guard let originalMethod = class_getInstanceMethod(swizzleDestination, originalSelector),
                  let swizzledMethod = class_getInstanceMethod(swizzleDestination, swizzledSelector)
            else {
                fatalError("Error at swizzling for \(swizzleDestination)")
            }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
