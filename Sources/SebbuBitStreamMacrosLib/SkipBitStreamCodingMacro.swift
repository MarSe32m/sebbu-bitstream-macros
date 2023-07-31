//
//  SkipBitStreamCodingMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct SkipBitStreamCodingMacro: MemberAttributeMacro {
    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingAttributesFor member: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [AttributeSyntax] {
        []
    }
    
    internal static func getSyntax() -> (String, String) {
        return ("", "")
    }
}
