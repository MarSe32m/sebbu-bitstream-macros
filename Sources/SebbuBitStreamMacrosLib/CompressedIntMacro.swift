//
//  CompressedIntMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct CompressedIntMacro: MemberAttributeMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        []
    }
    
    private static func getMinValue(_ arguments: [TupleExprElementSyntax]) throws -> String {
        if let value = arguments[0].expression.as(IntegerLiteralExprSyntax.self)?.digits.text {
            return value
        } else if let operatorExpression = arguments[0].expression.as(PrefixOperatorExprSyntax.self) {
            let operatorToken = operatorExpression.operatorToken?.text ?? ""
            if let value = operatorExpression.postfixExpression.as(IntegerLiteralExprSyntax.self)?.digits.text {
                return operatorToken + value
            }
        }
        let message = SimpleDiagnosticMessage(message: "min must be an integerLiteral", diagnosticID: MessageID(domain: "", id: "intLiteral"), severity: .error)
        let diagnostic = Diagnostic(node: Syntax(arguments[0]), position: arguments[0].position, message: message)
        throw DiagnosticsError(diagnostics: [diagnostic])
    }
    
    private static func getMaxValue(_ arguments: [TupleExprElementSyntax]) throws -> String {
        if let value = arguments[1].expression.as(IntegerLiteralExprSyntax.self)?.digits.text {
            return value
        } else if let operatorExpression = arguments[1].expression.as(PrefixOperatorExprSyntax.self) {
            let operatorToken = operatorExpression.operatorToken?.text ?? ""
            if let value = operatorExpression.postfixExpression.as(IntegerLiteralExprSyntax.self)?.digits.text {
                return operatorToken + value
            }
        }
        let message = SimpleDiagnosticMessage(message: "max must be an integerLiteral", diagnosticID: MessageID(domain: "", id: "intLiteral"), severity: .error)
        let diagnostic = Diagnostic(node: Syntax(arguments[1]), position: arguments[1].position, message: message)
        throw DiagnosticsError(diagnostics: [diagnostic])
    }
    
    internal static func getSyntax(attribute: SwiftSyntax.AttributeSyntax, _ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        guard let variableName = variableDecl.variableName else {
            let message = SimpleDiagnosticMessage(message: "Variable has no name.", diagnosticID: MessageID(domain: "", id: "no-variable-name"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        guard variableDecl.variableType != nil else {
            //TODO: Provide fix-it
            let message = SimpleDiagnosticMessage(message: "Integer compression can only be applied to variables of type Int, Int64, Int32, Int16 or Int8. Explicitly provide the type annotation.", diagnosticID: MessageID(domain: "", id: "annotation"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        guard variableDecl.isSimpleType(of: "Int", "Int64", "Int32", "Int16", "Int8") else {
            //TODO: Provide fix-it
            let message = SimpleDiagnosticMessage(message: "Integer compression can only be applied to variables of type Int, Int64, Int32, Int16 or Int8.", diagnosticID: MessageID(domain: "", id: "only-int"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        let arguments = try arguments(from: attribute, desiredAttributeCount: 2)
        
        let minValue = try getMinValue(arguments)
        let maxValue = try getMaxValue(arguments)
        
        let (minAllowed, maxAllowed) =
            if variableDecl.isSimpleType(of: "Int") {
                (Int64(Int.min), Int64(Int.max))
            } else if variableDecl.isSimpleType(of: "Int64") {
                (Int64(Int64.min), Int64(Int64.max))
            } else if variableDecl.isSimpleType(of: "Int32") {
                (Int64(Int32.min), Int64(Int32.max))
            } else if variableDecl.isSimpleType(of: "Int16") {
                (Int64(Int16.min), Int64(Int16.max))
            } else if variableDecl.isSimpleType(of: "Int8") {
                (Int64(Int8.min), Int64(Int8.max))
            } else {
                fatalError("Unreachable")
            }
        
        guard let minInt = Int(minValue), let maxInt = Int(maxValue), minInt < maxInt else {
            let message = SimpleDiagnosticMessage(message: "The minimum value must be less than the maximum value", diagnosticID: MessageID(domain: "", id: "min < max"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        
        guard minInt >= minAllowed else {
            let message = SimpleDiagnosticMessage(message: "The minimum value must be more than or equal to \(minAllowed)", diagnosticID: MessageID(domain: "", id: "min > minAllowed"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(arguments[0]), position: arguments[0].position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        
        guard maxInt <= maxAllowed else {
            let message = SimpleDiagnosticMessage(message: "The maximum value must be less than or equal to \(maxAllowed)", diagnosticID: MessageID(domain: "", id: "min > minAllowed"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(arguments[1]), position: arguments[1].position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        
        let compressor = "IntCompressor(minValue: \(minValue), maxValue: \(maxValue))"
        let compressorName = "__\(variableName)Compressor"
        let compressorVarDecl = "let \(compressorName) = \(compressor)"
        
        let initSyntax = """
                        \(compressorVarDecl)
                        self.\(variableName) = try \(compressorName).read(from: &stream)
                        """
        let encodeSyntax = """
                            \(compressorVarDecl)
                            \(compressorName).write(self.\(variableName), to: &stream)
                            """
        return (initSyntax, encodeSyntax)
    }
}
