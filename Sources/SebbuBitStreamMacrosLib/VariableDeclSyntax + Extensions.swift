//
//  VariableDeclSyntax + Extensions.swift
//
//
//  Created by Sebastian Toivonen on 30.7.2023.
//

import SwiftSyntax

extension VariableDeclSyntax {
    var isConstantAndInitialized: Bool {
        if bindingSpecifier.text == "let" {
            for binding in bindings {
                if binding.initializer != nil { return true }
            }
        }
        return false
    }
    
    var isStatic: Bool {
        if let modifiers = modifiers {
            return modifiers.contains { $0.name.text == "static"} 
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
        if let simpleTypeIdentifier = type.as(IdentifierTypeSyntax.self) {
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
        return type.is(IdentifierTypeSyntax.self)
    }
    
    func isArrayType(of: String) -> Bool {
        guard let type = variableType else { return false }
        if let simpleTypeIdentifier = type.as(ArrayTypeSyntax.self)?.element.as(IdentifierTypeSyntax.self) {
            return simpleTypeIdentifier.name.text == of
        } else if let simpleTypeIdentifier = type.as(IdentifierTypeSyntax.self) {
            if simpleTypeIdentifier.name.text == "Array" {
                if let genericArguments = simpleTypeIdentifier.genericArgumentClause?.arguments {
                    if genericArguments.count == 1 {
                        if let simpleTypeId = genericArguments.first?.argument.as(IdentifierTypeSyntax.self) {
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
    
    
    var isStoredProperty: Bool {
        if bindings.count != 1 {
            return false
        }
        
        let binding = bindings.first!
        switch binding.accessorBlock?.accessors {
        case .none:
            return true
            
        case .accessors(let node):
            for accessor in node {
                switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    // Observers can occur on a stored property.
                    break
                    
                default:
                    // Other accessors make it a computed property.
                    return false
                }
            }
            
            return true
            
        case .getter:
            return false
        }
    }
}
