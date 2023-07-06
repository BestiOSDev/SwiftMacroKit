import SwiftCompilerPlugin
import SwiftSyntax
import Foundation
import SwiftUI
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        return "(\(argument), \(literal: argument.description))"
    }
}

public enum kFontName: String, CaseIterable {
    case light = "PingFangSC-Light"
    case bold = "PingFangSC-Semibold"
    case regular = "PingFangSC-Regular"
    case medium = "PingFangSC-Medium"
    public static var allValues: [String] {
        return [kFontName.light.rawValue, kFontName.bold.rawValue, kFontName.regular.rawValue, kFontName.medium.rawValue]
    }
}

public struct URLMacro: ExpressionMacro {
    enum MacroError: Error {
        case unableToCreateURL
    }
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        guard let content = node.argumentList.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first?.description, let _ = URL(string: content) else {
            throw MacroError.unableToCreateURL // 无法生成 URL，报错
        }
        return "URL(string: \"\(raw: content)\")!"
    }
}

public struct PingFangFontMacro: ExpressionMacro {
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        guard let name = node.argumentList.first?.expression.as(MemberAccessExprSyntax.self)?.name.description else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        let fontName = kFontName.allValues.first { n in
            n.lowercased().contains(name)
        } ?? kFontName.regular.rawValue
        guard let fontSize = node.argumentList.last?.expression.as(FloatLiteralExprSyntax.self)?.floatingDigits.description else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        return "Font.custom(\"\(raw: fontName)\", fixedSize:\(raw: fontSize))"
    }
}

public struct ConstantMacro: DeclarationMacro {
    
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        debugPrint(node)
        guard
            let name = node.argumentList.first?
                .expression
                .as(StringLiteralExprSyntax.self)?
                .segments
                .first?
                .as(StringSegmentSyntax.self)?
                .content.text
        else {
            fatalError("compiler bug: invalid arguments")
        }
        
        let camelName = name.split(separator: "_")
            .map { String($0) }
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
        
        return ["public static var \(raw: camelName) = \(literal: name)"]
    }
    
}

public struct AddCompletionHandlerMacro: PeerMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        debugPrint(declaration)
        guard let declSyntax = declaration.as(FunctionDeclSyntax.self) else {
            fatalError("compiler bug: invalid arguments")
        }
        let signature = declSyntax.signature
        let funcName = declSyntax.identifier.description
        let firstName = signature.input.parameterList.first?.secondName?.description ?? ""
        let firstType = signature.input.parameterList.first?.type.description ?? ""
        let returnType = signature.output?.as(ReturnClauseSyntax.self)?.returnType.as(OptionalTypeSyntax.self)?.wrappedType.as(SimpleTypeIdentifierSyntax.self)?.name.description ?? ""
        return [
            """
            func \(raw: funcName)(_ \(raw: firstName): \(raw: firstType), completion: ((_ element: \(raw: returnType)?) -> Void)?) {
                Task {
                    let result = await fetchDetail(id)
                    completion?(result)
                }
            }
            """
        ]
    }
    
}

public struct UserDefaultMacro: AccessorMacro {
    
//    private static func getDefaultValue(expression: ExprSyntax?) -> Any? {
//        if let ex = expression?.as(StringLiteralExprSyntax.self) {
//            return ex.segments.first?.as(StringSegmentSyntax.self)?.content.description
//        } else if let ex = expression?.as(BooleanLiteralExprSyntax.self) {
//            return (ex.booleanLiteral.description == "true")
//        } else if let ex = expression?.as(IntegerLiteralExprSyntax.self) {
//            return Int(ex.digits.description)
//        } else if let ex = expression?.as(FloatLiteralExprSyntax.self) {
//            return Float(ex.floatingDigits.description)
//        } else if let ex = expression?.as(ArrayExprSyntax.self) {
//            debugPrint(ex.elements)
//            return Array(ex.elements)
//        }
//        else {
//            return nil
//        }
//    }
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        let defaultKey = node.argument?.as(TupleExprElementListSyntax.self)?.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content.description
        let propertyName = defaultKey ?? (declaration.as(VariableDeclSyntax.self)?.bindings.as(PatternBindingListSyntax.self)?.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.description ?? "")
        let propertyType = declaration.as(VariableDeclSyntax.self)?.bindings.as(PatternBindingListSyntax.self)?.first?.typeAnnotation?.type.as(OptionalTypeSyntax.self)?.wrappedType.as(SimpleTypeIdentifierSyntax.self)?.name.description ?? "Any"
        let getAccessor: AccessorDeclSyntax =
          """
          get {
            let value = UserDefaults.standard.object(forKey: \"\(raw: propertyName)\") as? \(raw: propertyType)
            return value
          }
          """
        let setAccessor: AccessorDeclSyntax =
          """
          set {
            UserDefaults.standard.setValue(newValue, forKey: \"\(raw: propertyName)\")
          }
          """

        
        return [getAccessor, setAccessor]
    }
}

public struct StatePropertiesMacro: MemberAttributeMacro {
   
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        return [
          """
          @State
          """
        ]
    }
    
}

public struct DescriptionMacro: MemberMacro {

    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            fatalError("compiler bug: unknown error")
        }
        let className = classDecl.identifier.text
        let variables = classDecl.memberBlock.members
            .compactMap { member -> PatternBindingListSyntax? in
                member.decl.as(VariableDeclSyntax.self)?.bindings
            }.compactMap { bindings -> String? in
                bindings.first?.pattern
                    .as(IdentifierPatternSyntax.self)?
                    .identifier.text
            }
            .map { "\($0): \\(\($0))" }
            .joined(separator: ", ")
        let contentVariable = context.makeUniqueName("content")
        return [
            """
            var description: String {
                var \(raw: contentVariable) = "\(raw: className)"
                \(raw: contentVariable) += "(\(raw: variables))"
                return \(raw: contentVariable)
            }
            """
        ]
    }
}

extension DescriptionMacro: ConformanceMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingConformancesOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [(SwiftSyntax.TypeSyntax, SwiftSyntax.GenericWhereClauseSyntax?)] {
        
        return [("CustomStringConvertible", nil)]
    }
}

@main
struct SwiftMacroKitPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        URLMacro.self,
        PingFangFontMacro.self,
        ConstantMacro.self,
        AddCompletionHandlerMacro.self,
        UserDefaultMacro.self,
        StatePropertiesMacro.self,
        DescriptionMacro.self,
    ]
}
