//
//  CompressedUIntArrayMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct CompressedUIntArrayMacro: MemberAttributeMacro {
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
    
    private static func getMaxCount(_ arguments: [TupleExprElementSyntax]) throws -> String {
        if let value = arguments[2].expression.as(IntegerLiteralExprSyntax.self)?.digits.text {
            return value
        }
        let message = SimpleDiagnosticMessage(message: "maxCount must be an integerLiteral", diagnosticID: MessageID(domain: "", id: "integerLiteral"), severity: .error)
        let diagnostic = Diagnostic(node: Syntax(arguments[2]), position: arguments[2].position, message: message)
        throw DiagnosticsError(diagnostics: [diagnostic])
    }
    
    internal static func getSyntax(attribute: SwiftSyntax.AttributeSyntax,  _ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        guard let variableName = variableDecl.variableName else {
            let message = SimpleDiagnosticMessage(message: "Variable has no name.", diagnosticID: MessageID(domain: "", id: "no-variable-name"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        guard variableDecl.variableType != nil else {
            //TODO: Provide fix-it
            let message = SimpleDiagnosticMessage(message: "Unsigned integer array compression can only be applied to arrays of type [UInt], [UInt64], [UInt32], [UInt16] or [UInt8]. Explicitly provide the type annotation.", diagnosticID: MessageID(domain: "", id: "annotation"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        guard variableDecl.isArrayType(of: "UInt", "UInt64", "UInt32", "UInt16", "UInt8") else {
            //TODO: Provide fix-it
            let message = SimpleDiagnosticMessage(message: "Integer array compression can only be applied to arrays of type [UInt], [UInt64], [UInt32], [UInt16] or [UInt8].", diagnosticID: MessageID(domain: "", id: "only-int-arrays"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        let arguments = try arguments(from: attribute, desiredAttributeCount: 3)
        
        let minValue = try getMinValue(arguments)
        let maxValue = try getMaxValue(arguments)
        let maxCount = try getMaxCount(arguments)
        
        let (minAllowed, maxAllowed) =
            if variableDecl.isArrayType(of: "UInt") {
                (0, UInt64(UInt.max))
            } else if variableDecl.isArrayType(of: "UInt64") {
                (0, UInt64.max)
            } else if variableDecl.isArrayType(of: "UInt32") {
                (0, UInt64(UInt32.max))
            } else if variableDecl.isArrayType(of: "UInt16") {
                (0, UInt64(UInt16.max))
            } else if variableDecl.isArrayType(of: "UInt8") {
                (0, UInt64(UInt8.max))
            } else {
                fatalError("Unreachable")
            }
        
        guard let minInt = Int(minValue), let maxInt = Int(maxValue), minInt < maxInt else {
            let message = SimpleDiagnosticMessage(message: "The minimum value must be less than the maximum value", diagnosticID: MessageID(domain: "", id: "min < max"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        
        guard minInt >= minAllowed else {
            let message = SimpleDiagnosticMessage(message: "The minimum value must be more than or equal to \(minAllowed)", diagnosticID: MessageID(domain: "", id: "min >= minAllowed"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(arguments[0]), position: arguments[0].position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        
        guard maxInt <= maxAllowed else {
            let message = SimpleDiagnosticMessage(message: "The maximum value must be less than or equal to \(maxAllowed)", diagnosticID: MessageID(domain: "", id: "max <= maxAllowed"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(arguments[1]), position: arguments[1].position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        
        guard let intMaxCount = Int(maxCount), intMaxCount > 0, intMaxCount < 1 << 29 else {
            let message = SimpleDiagnosticMessage(message: "maxCount must be more than zero and less than 2^29", diagnosticID: MessageID(domain: "", id: "maxCount < 1 << 29"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        
        let compressor = "UIntCompressor(minValue: \(minValue), maxValue: \(maxValue))"
        let compressorName = "__\(variableName)Compressor"
        let compressorVarDecl = "let \(compressorName) = \(compressor)"
        let initSyntax = """
                        \(compressorVarDecl)
                        self.\(variableName) = try \(compressorName).read(maxCount: \(maxCount), from: &stream)
                        """
        let encodeSyntax = """
                        \(compressorVarDecl)
                        \(compressorName).write(self.\(variableName), maxCount: \(maxCount), to: &stream)
                        """
        return (initSyntax, encodeSyntax)
    }
}
