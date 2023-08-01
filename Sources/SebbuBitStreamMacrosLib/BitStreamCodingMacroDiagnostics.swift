//
//  BitStreamCodingMacroDiagnostics.swift
//
//
//  Created by Sebastian Toivonen on 1.8.2023.
//

import SwiftSyntax
import SwiftDiagnostics

enum BitStreamCodingDiagnostic {
    case requiresEnumClassOrStruct(DeclGroupSyntax)
    case requiresStoredProperty(String)
    case argumentMustBeIntegerLiteral(String)
    case argumentMustBeFloatLiteral(String)
    case attributeRequiresArgumentCount(Int)
    
    case requiresVariableName
    case requiresTypeAnnotation
    
    case custom(String)
}

extension BitStreamCodingDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), position: node.position, message: self)
    }
    
    func error(at node: some SyntaxProtocol) -> Error {
        DiagnosticsError(diagnostics: [diagnose(at: node)])
    }
    
    var message: String {
        switch self {
        case .requiresEnumClassOrStruct(let decl):
            "'@BitStreamCoding' can only be attached to an enum, struct or class, not \(decl.descriptiveDeclKind(withArticle: true))"
        case .requiresStoredProperty(let attributeMacro):
            "'\(attributeMacro)' can only be applied to stored properties"
        case .argumentMustBeIntegerLiteral(let argument):
            "Parameter '\(argument)' must be an integer literal"
        case .argumentMustBeFloatLiteral(let argument):
            "Parameter '\(argument)' must be a float literal"
        case .attributeRequiresArgumentCount(let desiredCount):
            "Attribute must have \(desiredCount) arguments"
        case .requiresVariableName:
            "Variable has no name"
        case .requiresTypeAnnotation:
            "Explicitly provide the type annotation"
        case .custom(let message):
            message
        }
    }
    
    var severity: DiagnosticSeverity {
        switch self {
        case .requiresEnumClassOrStruct(_):
            .error
        case .requiresStoredProperty(_):
            .error
        case .argumentMustBeIntegerLiteral(_):
            .error
        case .argumentMustBeFloatLiteral(_):
            .error
        case .attributeRequiresArgumentCount(_):
            .error
        case .requiresVariableName:
            .error
        case .requiresTypeAnnotation:
            .error
        case .custom(_):
            .error
        }
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "Swift", id: "BitStreamCoding.\(self)")
    }
}

