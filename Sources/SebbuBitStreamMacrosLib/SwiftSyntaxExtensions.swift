//
//  SwiftSyntaxExtensions.swift
//  
//
//  Created by Sebastian Toivonen on 1.8.2023.
//

import SwiftSyntax

extension DeclGroupSyntax {
    func descriptiveDeclKind(withArticle article: Bool = false) -> String {
        switch self {
        case is ActorDeclSyntax:
            return article ? "an actor" : "actor"
        case is ClassDeclSyntax:
            return article ? "a class" : "class"
        case is ExtensionDeclSyntax:
            return article ? "an extension" : "extension"
        case is ProtocolDeclSyntax:
            return article ? "a protocol" : "protocol"
        case is StructDeclSyntax:
            return article ? "a struct" : "struct"
        case is EnumDeclSyntax:
            return article ? "an enum" : "enum"
        default:
            fatalError("Unknown DeclGroupSyntax")
        }
    }
    
    func storedProperties() -> [VariableDeclSyntax] {
        return memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  variable.isStoredProperty else {
                return nil
            }
            return variable
        }
    }
    
    var isStoredProperty: Bool {
        if let variable = self.as(VariableDeclSyntax.self), variable.isStoredProperty {
            return true
        }
        return false
    }
}
