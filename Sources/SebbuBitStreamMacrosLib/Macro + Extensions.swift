//
//  MemberAttributeMacro + Extensions.swift
//  
//
//  Created by Sebastian Toivonen on 30.7.2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

enum LiteralType {
    case integer
    case float
}

extension Macro {
    static func check(variable: VariableDeclSyntax, attribute: String) throws {
        guard variable.variableName != nil else {
            throw BitStreamCodingDiagnostic.requiresVariableName.error(at: Syntax(variable))
        }
        guard variable.variableType != nil else {
            throw BitStreamCodingDiagnostic.requiresTypeAnnotation.error(at: Syntax(variable))
        }
        guard !variable.isStatic else {
            throw BitStreamCodingDiagnostic.custom("'\(attribute)' can only be applied to non-static stored properties.").error(at: Syntax(variable))
        }
    }
    
    static func arguments(from attribute: SwiftSyntax.AttributeSyntax, desiredArgumentCount: Int) throws -> [TupleExprElementSyntax] {
        guard case .argumentList(let argumentList) = attribute.argument else {
            throw BitStreamCodingDiagnostic.custom("No arguments supplied for attribute").error(at: Syntax(attribute))
        }
        let arguments = argumentList.children(viewMode: .sourceAccurate).compactMap { $0.as(TupleExprElementSyntax.self) }
        if desiredArgumentCount == arguments.count { return arguments }
        throw BitStreamCodingDiagnostic.attributeRequiresArgumentCount(desiredArgumentCount).error(at: Syntax(attribute))
    }
    
    static func get(_ arguments: [TupleExprElementSyntax], name: String, position: Int, as type: LiteralType...) throws -> String {
        if let value = arguments[position].expression.as(IntegerLiteralExprSyntax.self)?.digits.text, type.contains(.integer) {
            return value
        } else if let value = arguments[position].expression.as(FloatLiteralExprSyntax.self)?.floatingDigits.text, type.contains(.float) {
            return value
        } else if let operatorExpression = arguments[position].expression.as(PrefixOperatorExprSyntax.self) {
            let operatorToken = operatorExpression.operatorToken?.text ?? ""
            if let value = operatorExpression.postfixExpression.as(FloatLiteralExprSyntax.self)?.floatingDigits.text, type.contains(.float) {
                return operatorToken + value
            } else if let value = operatorExpression.postfixExpression.as(IntegerLiteralExprSyntax.self)?.digits.text, type.contains(.integer) {
                return operatorToken + value
            }
        }
        switch type.first! {
        case .integer:
            throw BitStreamCodingDiagnostic.argumentMustBeIntegerLiteral(name).error(at: Syntax(arguments[position]))
        case .float:
            throw BitStreamCodingDiagnostic.argumentMustBeFloatLiteral(name).error(at: Syntax(arguments[position]))
        }
    }
}
