import SwiftMacroKit
import SwiftMacroKitMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftUI
import XCTest

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "URL": URLMacro.self,
    "PingFangFont": PingFangFontMacro.self,
    "Constant": ConstantMacro.self,
    "AddCompletionHandler": AddCompletionHandlerMacro.self,
    "UserDefault" : UserDefaultMacro.self,
    "StateProperties": StatePropertiesMacro.self,
    "Description": DescriptionMacro.self
]

final class SwiftMacroKitTests: XCTestCase {
    func testMacro() {
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
    }
    
    func testMacroWithStringLiteral() {
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
    }
    
    func testUrlMacro1() {
        assertMacroExpansion("""
        #URL("123")
        """, expandedSource: """
        URL(string: "123")!
        """, macros: testMacros)
    }
    
    func testUrlMacro2() {
        assertMacroExpansion("""
        #URL("https://www.baidu.com")
        """, expandedSource: """
        URL(string: "https://www.baidu.com")!
        """, macros: testMacros)
    }
    
    func testFontMacro() {
        assertMacroExpansion("""
            #PingFangFont(.bold, fontSize: 15.0)
        """, expandedSource: """
        Font.custom("PingFangSC-Semibold", fixedSize: 15.0)
        """, macros: testMacros)
    }
    
    func testConstMacro() {
        assertMacroExpansion("""
        struct MyConstaints {
            #Constant("app_id")
            #Constant("empty_image")
            #Constant("error_tip")
        }
        """, expandedSource: """
        struct MyConstaints {
            public static var appId = "app_id"
            public static var emptyImage = "empty_image"
            public static var errorTip = "error_tip"
        }
        """, macros: testMacros)
    }
    
    func testPeerMacro() {
        assertMacroExpansion(
            """
            public struct MyConstaints {
                @AddCompletionHandler()
                func fetchDetail(_ id: Int) async -> String? {
                    return "hello world"
                }
            }
            """, expandedSource:
            """
            public struct MyConstaints {
                @AddCompletionHandler()
                func fetchDetail(_ id: Int) async -> String? {
                    return "hello world"
                }
                func fetchDetail(_ id: Int, completion: ((_ element: String?) -> Void)?) {
                    Task {
                        let result = await fetchDetail(id)
                        completion?(result)
                    }
                }
            }
            """, macros: testMacros
        )
    }
    
    func testAccessorMacro() {
        assertMacroExpansion(
            """
            @UserDefault(key: "titleArray")
            var titleArray: [String]?
            """, expandedSource:
            """
            @UserDefault(key: "titleArray")
            var titleArray: [String]?
            """, macros: testMacros)
    }
    
    func testMemberAttributed() {
        assertMacroExpansion(
            """
            @StateProperties
            struct OldStorage {
                var x: Int
                var y: Int
            }
            """, expandedSource:
            """
            @StateProperties
            struct OldStorage {
                @State
                var x: Int
                @State
                var y: Int
            }
            """, macros: testMacros
        )
    }
    
    func testMemberMacro() {
        
        assertMacroExpansion("""
        @Description
        class BusinessModel: CustomStringConvertible {
            var count: Int = 0
            var tag: String?
        }
        """, expandedSource: """
        @Description
        class BusinessModel: CustomStringConvertible {
            var count: Int = 0
            var tag: String?
            var description: String {
                "BusinessModel(count: 0, tag: nil)"
            }
        }
        """, macros: testMacros)
        
    }
    
    func testConformanceMacro() {
        assertMacroExpansion("""
        @Description
        class BusinessModel: CustomStringConvertible {
            var count: Int = 0
            var tag: String?
        }
        """, expandedSource: """
        @Description
        class BusinessModel: CustomStringConvertible {
            var count: Int = 0
            var tag: String?
            var description: String {
                "BusinessModel(count: 0, tag: nil)"
            }
            func foo() {

            }
        }
        extension BusinessModel : MyCustomProtocol  {}
        """, macros: testMacros)
        
    }
    
}
