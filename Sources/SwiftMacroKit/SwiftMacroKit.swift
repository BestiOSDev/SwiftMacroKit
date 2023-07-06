// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Foundation
import SwiftMacroKitMacros
/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "SwiftMacroKitMacros", type: "StringifyMacro")


@freestanding(expression)
public macro URL(_ value: String) -> URL = #externalMacro(module: "SwiftMacroKitMacros", type: "URLMacro")

@freestanding(expression)
public macro PingFangFont(_ name: kFontName, fontSize: CGFloat) -> Font  = #externalMacro(module: "SwiftMacroKitMacros", type: "PingFangFontMacro")

@freestanding(declaration, names: arbitrary)
public macro Constant(_ value: String) = #externalMacro(module: "SwiftMacroKitMacros", type: "ConstantMacro")

@attached(peer, names: overloaded)
public macro AddCompletionHandler() =
    #externalMacro(module: "SwiftMacroKitMacros", type: "AddCompletionHandlerMacro")

@attached(accessor, names: named(_store))
public macro UserDefault(key: String? = nil) = #externalMacro(module: "SwiftMacroKitMacros", type: "UserDefaultMacro")

@attached(memberAttribute)
public macro StateProperties() = #externalMacro(module: "SwiftMacroKitMacros", type: "StatePropertiesMacro")

@attached(member, names: named(description), named(foo))
@attached(conformance)
public macro Description() = #externalMacro(module: "SwiftMacroKitMacros", type: "DescriptionMacro")
