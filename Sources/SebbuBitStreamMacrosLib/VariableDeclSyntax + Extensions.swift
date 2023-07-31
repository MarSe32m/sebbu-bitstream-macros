//
//  VariableDeclSyntax + Extensions.swift
//  
//
//  Created by Sebastian Toivonen on 30.7.2023.
//

import SwiftSyntax

extension VariableDeclSyntax {
    var isConstantAndInitialized: Bool {
        if bindingKeyword.text == "let" {
            for binding in bindings {
                if binding.initializer != nil { return true }
            }
        }
        return false
    }
    
    var variableName: String? {
        for binding in bindings {
            if let identifierPatternSyntax = binding.as(PatternBindingSyntax.self)?.pattern.as(IdentifierPatternSyntax.self) {
                return identifierPatternSyntax.identifier.text
            }
        }
        return nil
    }
    
    var variableType: TypeSyntax? {
        for binding in bindings {
            if let typeAnnotation = binding.as(PatternBindingSyntax.self)?.typeAnnotation {
                return typeAnnotation.type
            }
        }
        return nil
    }
    
    func isSimpleType(of: String) -> Bool {
        guard let type = variableType else { return false }
        if let simpleTypeIdentifier = type.as(SimpleTypeIdentifierSyntax.self) {
            return simpleTypeIdentifier.name.text == of
        }
        return false
    }
    
    func isSimpleType(of: String...) -> Bool {
        for _type in of {
            if isSimpleType(of: _type) { return true }
        }
        return false
    }
    
    func isSimpleType() -> Bool {
        guard let type = variableType else { return false }
        return type.is(SimpleTypeIdentifierSyntax.self)
    }
    
    func isArrayType(of: String) -> Bool {
        guard let type = variableType else { return false }
        if let simpleTypeIdentifier = type.as(ArrayTypeSyntax.self)?.elementType.as(SimpleTypeIdentifierSyntax.self) {
            return simpleTypeIdentifier.name.text == of
        } else if let simpleTypeIdentifier = type.as(SimpleTypeIdentifierSyntax.self) {
            if simpleTypeIdentifier.name.text == "Array" {
                if let genericArguments = simpleTypeIdentifier.genericArgumentClause?.arguments {
                    if genericArguments.count == 1 {
                        if let simpleTypeId = genericArguments.first?.argumentType.as(SimpleTypeIdentifierSyntax.self) {
                            return simpleTypeId.name.text == of
                        }
                    }
                }
            }
        }
        return false
    }
    
    func isArrayType(of: String...) -> Bool {
        for _type in of {
            if isArrayType(of: _type) { return true }
        }
        return false
    }
    
    func isArrayType() -> Bool {
        guard let type = variableType else { return false }
        return type.is(ArrayTypeSyntax.self)
    }
}
