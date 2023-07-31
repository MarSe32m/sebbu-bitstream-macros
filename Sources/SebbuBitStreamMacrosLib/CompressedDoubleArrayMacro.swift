//
//  CompressedDoubleArrayMacro.swift
//  
//
//  Created by Sebastian Toivonen on 31.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct CompressedDoubleArrayMacro: MemberAttributeMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AttributeSyntax] {
        []
    }
    
    private static func getMinValue(_ arguments: [TupleExprElementSyntax]) throws -> String {
        if let value = arguments[0].expression.as(IntegerLiteralExprSyntax.self)?.digits.text {
            return value
        } else if let value = arguments[0].expression.as(FloatLiteralExprSyntax.self)?.floatingDigits.text {
            return value
        } else if let operatorExpression = arguments[0].expression.as(PrefixOperatorExprSyntax.self) {
            let operatorToken = operatorExpression.operatorToken?.text ?? ""
            if let value = operatorExpression.postfixExpression.as(FloatLiteralExprSyntax.self)?.floatingDigits.text {
                return operatorToken + value
            } else if let value = operatorExpression.postfixExpression.as(IntegerLiteralExprSyntax.self)?.digits.text {
                return operatorToken + value
            }
        }
        let message = SimpleDiagnosticMessage(message: "min be a floatLiteral or integerLiteral", diagnosticID: MessageID(domain: "", id: "floatLiteral"), severity: .error)
        let diagnostic = Diagnostic(node: Syntax(arguments[0]), position: arguments[0].position, message: message)
        throw DiagnosticsError(diagnostics: [diagnostic])
    }
    
    private static func getMaxValue(_ arguments: [TupleExprElementSyntax]) throws -> String {
        if let value = arguments[1].expression.as(IntegerLiteralExprSyntax.self)?.digits.text {
            return value
        } else if let value = arguments[1].expression.as(FloatLiteralExprSyntax.self)?.floatingDigits.text {
            return value
        } else if let operatorExpression = arguments[1].expression.as(PrefixOperatorExprSyntax.self) {
            let operatorToken = operatorExpression.operatorToken?.text ?? ""
            if let value = operatorExpression.postfixExpression.as(FloatLiteralExprSyntax.self)?.floatingDigits.text {
                return operatorToken + value
            } else if let value = operatorExpression.postfixExpression.as(IntegerLiteralExprSyntax.self)?.digits.text {
                return operatorToken + value
            }
        }
        let message = SimpleDiagnosticMessage(message: "max must be a floatLiteral or integerLiteral", diagnosticID: MessageID(domain: "", id: "floatLiteral"), severity: .error)
        let diagnostic = Diagnostic(node: Syntax(arguments[1]), position: arguments[1].position, message: message)
        throw DiagnosticsError(diagnostics: [diagnostic])
    }
    
    private static func getBits(_ arguments: [TupleExprElementSyntax]) throws -> String {
        if let value = arguments[2].expression.as(IntegerLiteralExprSyntax.self)?.digits.text {
            return value
        }
        let message = SimpleDiagnosticMessage(message: "bits must be an integerLiteral", diagnosticID: MessageID(domain: "", id: "integerLiteral"), severity: .error)
        let diagnostic = Diagnostic(node: Syntax(arguments[2]), position: arguments[2].position, message: message)
        throw DiagnosticsError(diagnostics: [diagnostic])
    }
    
    private static func getMaxCount(_ arguments: [TupleExprElementSyntax]) throws -> String {
        if let value = arguments[3].expression.as(IntegerLiteralExprSyntax.self)?.digits.text {
            return value
        }
        let message = SimpleDiagnosticMessage(message: "maxCount must be a positive integerLiteral", diagnosticID: MessageID(domain: "", id: "integerLiteral"), severity: .error)
        let diagnostic = Diagnostic(node: Syntax(arguments[3]), position: arguments[3].position, message: message)
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
            let message = SimpleDiagnosticMessage(message: "Double array compression can only be applied to Double arrays. Explicitly provide the type annotation.", diagnosticID: MessageID(domain: "", id: "annotation"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        guard variableDecl.isArrayType(of: "Double") else {
            //TODO: Provide fix-it
            let message = SimpleDiagnosticMessage(message: "Double array compression can only be applied to Double arrays.", diagnosticID: MessageID(domain: "", id: "only-double-arrays"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        let arguments = try arguments(from: attribute, desiredAttributeCount: 4)
        
        let minValue = try getMinValue(arguments)
        let maxValue = try getMaxValue(arguments)
        let bits = try getBits(arguments)
        let maxCount = try getMaxCount(arguments)
        
        guard let minFloat = Float(minValue), let maxFloat = Float(maxValue), minFloat < maxFloat else {
            let message = SimpleDiagnosticMessage(message: "The minimum value must be less than the maximum value.", diagnosticID: MessageID(domain: "", id: "min < max"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        
        guard let intBits = Int(bits), intBits > 0, intBits <= 64 else {
            let message = SimpleDiagnosticMessage(message: "bits must be more than 0 and less than or equal to 64", diagnosticID: MessageID(domain: "", id: "min < max"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        
        guard let maxCountInt = Int(maxCount), maxCountInt > 0, maxCountInt <= 1 << 29 else {
            let message = SimpleDiagnosticMessage(message: "", diagnosticID: MessageID(domain: "Max count must be less than or equal to 2^29.", id: "maxCount < 2^29"), severity: .error)
            let diagnostic = Diagnostic(node: Syntax(variableDecl), position: variableDecl.position, message: message)
            throw DiagnosticsError(diagnostics: [diagnostic])
        }
        
        let compressor = "DoubleCompressor(minValue: \(minValue), maxValue: \(maxValue), bits: \(bits))"
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
