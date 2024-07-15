import UIKit

///////////////////////////////////////////////
/// Learnings from this playground
///     I need to add generation of CustomReflectable to the mocks.
///     This will allow for the access to the static called/assigned option sets (as well as the non-static versions)
///
/// Example of the CustomReflectable implementation in a mock that only has static methods/parameters.
///         extension Mock: CustomReflectable {
///             public var customMirror: Mirror {
///                 Mirror(self,
///                        children: [
///                         "calledStaticMethods": MockLoadingViewHandling.calledStaticMethods,
///                         "assignedStaticParameters": MockLoadingViewHandling.assignedStaticParameters
///                        ],
///                        displayStyle: .none
///                 )
///         }
///
///////////////////////////////////////////////




/// Playgound used explore reflection (Mirror) functionality needed for the StroblMacros

let dateFactory = DateFactory()
print("Looks like the DateFactory source is available: \(dateFactory.now)")
print()
print()

// TODO: Test situations with both static and normal properties!!!!!

//
// Mock with regular properties
//

let mockDateFactory = MockDateCreating()
_ = mockDateFactory.now
let mirror = Mirror(reflecting: mockDateFactory)
print("Looking at the children of mockDateFactory")
print(mirror.displayStyle ?? "no display style")
for (label, value) in mirror.children {
    var isEmptySet = ""
    if let value = value as? MockDateCreating.Method {
        isEmptySet = value.isEmpty ? "Empty Set" : "Set Is Not Empty"
    }
    if let value = value as? MockDateCreating.MethodParameter {
        isEmptySet = value.isEmpty ? "Empty Set" : "Set Is Not Empty"
    }

    print("\tProperty \(label ?? ""): \(value)  {\(type(of: value))}   \(isEmptySet)")
}
print()
if let calledMethods = mirror.descendant("calledMethods") as? MockDateCreating.Method {
    print("calledMethods: \(calledMethods)")
}
if let assignedParameters = mirror.descendant("assignedParameters") as? MockDateCreating.MethodParameter {
    print("assignedParameters: \(assignedParameters)")
}

print()
print("Looking at the children in custom mirror of mockDateFactory")
print(mockDateFactory.customMirror.displayStyle ?? "no display style")
for (label, value) in mockDateFactory.customMirror.children {
    var isEmptySet = ""
    if let value = value as? MockDateCreating.Method {
        isEmptySet = value.isEmpty ? "Empty Set" : "Set Is Not Empty"
    }
    if let value = value as? MockDateCreating.MethodParameter {
        isEmptySet = value.isEmpty ? "Empty Set" : "Set Is Not Empty"
    }

    print("\tProperty \(label ?? ""): \(value)  {\(type(of: value))}   \(isEmptySet)")
}




//
// Mock with static properties
//

let view = UIView()
let mockLoadingViewHandler = MockLoadingViewHandling()
MockLoadingViewHandling.loadingView(in: view)
let staticMirror = Mirror(reflecting: mockLoadingViewHandler)
print()
print()
print()
print()
print("Looking at the children of mockLoadingViewHandler")
print(staticMirror.displayStyle ?? "no display style")
for (label, value) in staticMirror.children {
    var isEmptySet = ""
    if let value = value as? MockLoadingViewHandling.StaticMethod {
        isEmptySet = value.isEmpty ? "Empty Set" : "Set Is Not Empty"
    }
    if let value = value as? MockLoadingViewHandling.StaticMethodParameter {
        isEmptySet = value.isEmpty ? "Empty Set" : "Set Is Not Empty"
    }

    print("\tProperty \(label ?? ""): \(value)  {\(type(of: value))}   \(isEmptySet)")
}
print()
if let calledStaticMethods = staticMirror.descendant("calledStaticMethods") as? MockDateCreating.Method {
    print("calledStaticMethods: \(calledStaticMethods)")
}
if let assignedStaticParameters = staticMirror.descendant("assignedStaticParameters") as? MockDateCreating.MethodParameter {
    print("assignedStaticParameters: \(assignedStaticParameters)")
}

print("Looking at the children in custom mirror of mockLoadingViewHandler")
_ = MockLoadingViewHandling.isLoadingViewShown()
print(mockLoadingViewHandler.customMirror.displayStyle ?? "no display style")
for (label, value) in mockLoadingViewHandler.customMirror.children {
    var isEmptySet = ""
    if let value = value as? MockLoadingViewHandling.StaticMethod {
        isEmptySet = value.isEmpty ? "Empty Set" : "Set Is Not Empty"
    }
    if let value = value as? MockLoadingViewHandling.StaticMethodParameter {
        isEmptySet = value.isEmpty ? "Empty Set" : "Set Is Not Empty"
    }

    print("\tProperty \(label ?? ""): \(value)  {\(type(of: value))}   \(isEmptySet)")
}
if let calledStaticMethods = mockLoadingViewHandler.customMirror.descendant("calledStaticMethods") as? MockDateCreating.Method {
    print("calledStaticMethods: \(calledStaticMethods)")
}
if let assignedStaticParameters = mockLoadingViewHandler.customMirror.descendant("assignedStaticParameters") as? MockDateCreating.MethodParameter {
    print("assignedStaticParameters: \(assignedStaticParameters)")
}
