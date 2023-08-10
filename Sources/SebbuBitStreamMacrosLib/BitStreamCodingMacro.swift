import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct PathMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        return []
    }
}

public struct BitStreamCodingMacro: MemberMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        if declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self)  {
            return try basicExpansion(of: node, providingMembersOf: declaration, in: context)
        } else if declaration.is(EnumDeclSyntax.self) {
            return try enumExpansion(of: node, providingMembersOf: declaration, in: context)
        } else {
            throw DiagnosticsError(diagnostics: [
                BitStreamCodingDiagnostic.requiresEnumClassOrStruct(declaration).diagnose(at: node)
            ])
        }
    }
    
    private static func throwMultipleAttributesApplied(_ attribute: AttributeSyntax) throws {
        throw BitStreamCodingDiagnostic.custom("Multiple BitStream attributes supplied. Only one is allowed.").error(at: Syntax(attribute))
    }
    
    private static func basicExpansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        var initSyntax: [String] = []
        var encodeSyntax: [String] = []
        for variableDecl in declaration.storedProperties() where !variableDecl.isStatic {
            // We don't want to encode and decode constants
            if variableDecl.isConstantAndInitialized { continue }
            guard let attributes = variableDecl.attributes, !attributes.isEmpty else {
                let (_init, _encode) = try getDefaultSyntax(variableDecl)
                initSyntax.append(_init)
                encodeSyntax.append(_encode)
                continue
            }
            var generatedSyntax = false
            for attributeListItem in attributes {
                guard let attribute = attributeListItem.as(SwiftSyntax.AttributeSyntax.self) else {
                    continue
                }
                guard let attributeName = attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text else { continue }
                
                switch attributeName {
                case "SkipBitStreamCoding":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = SkipBitStreamCodingMacro.getSyntax()
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                case "CompressedFloat":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = try CompressedFloatMacro.getSyntax(attribute: attribute, variableDecl)
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                case "CompressedDouble":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = try CompressedDoubleMacro.getSyntax(attribute: attribute, variableDecl)
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                case "CompressedInt":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = try CompressedIntMacro.getSyntax(attribute: attribute, variableDecl)
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                case "CompressedUInt":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = try CompressedUIntMacro.getSyntax(attribute: attribute, variableDecl)
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                case "NumberOfBits":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = try NumberOfBitsMacro.getSyntax(attribute: attribute, variableDecl)
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                case "CompressedFloatArray":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = try CompressedFloatArrayMacro.getSyntax(attribute: attribute, variableDecl)
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                case "CompressedDoubleArray":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = try CompressedDoubleArrayMacro.getSyntax(attribute: attribute, variableDecl)
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                case "CompressedIntArray":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = try CompressedIntArrayMacro.getSyntax(attribute: attribute, variableDecl)
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                case "CompressedUIntArray":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = try CompressedUIntArrayMacro.getSyntax(attribute: attribute, variableDecl)
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                case "BoundedArray":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = try BoundedArrayMacro.getSyntax(attribute: attribute, variableDecl)
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                case "Bytes":
                    if generatedSyntax { try throwMultipleAttributesApplied(attribute) }
                    generatedSyntax = true
                    let (_init, _encode) = try BytesMacro.getSyntax(attribute: attribute, variableDecl)
                    initSyntax.append(_init)
                    encodeSyntax.append(_encode)
                default:
                    break
                }
            }
            if !generatedSyntax {
                let (_init, _encode) = try getDefaultSyntax(variableDecl)
                initSyntax.append(_init)
                encodeSyntax.append(_encode)
            }
        }
        
        let requiredKeyword = declaration.is(ClassDeclSyntax.self) ? " required " : " "
        
        let initDeclSyntax: DeclSyntax = "@inlinable\npublic\(raw: requiredKeyword)init(from stream: inout ReadableBitStream) throws {\(raw: initSyntax.joined(separator: "\n"))}"
        
        let encodeDeclSyntax: DeclSyntax = "@inlinable\npublic func encode(to stream: inout WritableBitStream) {\(raw: encodeSyntax.joined(separator: "\n"))}"
        
        return [initDeclSyntax, encodeDeclSyntax]
    }
    
    private static func enumExpansion(of node: SwiftSyntax.AttributeSyntax, providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        var cases: [(caseName: String, payloads: [String])] = []
        var initSyntax: [String] = []
        var encodeSyntax: [String] = []
        
        for member in declaration.memberBlock.members {
            guard let enumCaseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { continue }
            for caseElement in enumCaseDecl.elements {
                let caseName = caseElement.name.text
                let payloads = caseElement.parameterClause?.parameters.compactMap {$0.type.as(IdentifierTypeSyntax.self)?.name.text} ?? []
                cases.append((caseName, payloads))
            }
        }
        
        let codingKeysDeclSyntax: DeclSyntax = DeclSyntax(stringLiteral:
                                                            "@usableFromInline\n"
                                                          +  "internal enum CodingKey: UInt32, CaseIterable {\n"
                                                          +  "\(cases.map {"case \($0.caseName)"}.joined(separator: "\n"))"
                                                          +  "}")
        
        for (caseName, payload) in cases {
            var initCase = "case .\(caseName): self = .\(caseName)"
            var encodeCase = "case .\(caseName)"
            
            if !payload.isEmpty {
                initCase += "(\(payload.map {_ in "try stream.read()"}.joined(separator: ", ")))"
                encodeCase += "(\(payload.enumerated().map {index, _ in "let \(caseName)Object\(index)"}.joined(separator: ", "))):"
            } else {
                encodeCase += ":"
            }
            encodeCase += "stream.append(CodingKey.\(caseName))\n"
            for (index, _) in payload.enumerated() {
                encodeCase += "stream.append(\(caseName)Object\(index))\n"
            }
            // Remove last new line
            encodeCase.removeLast()
            
            initSyntax.append(initCase)
            encodeSyntax.append(encodeCase)
        }
        let initDeclSyntax: DeclSyntax = "@inlinable\npublic init(from stream: inout ReadableBitStream) throws {let codingKey = try stream.read() as CodingKey\nswitch codingKey {\(raw: initSyntax.joined(separator: "\n"))}}"
        
        let encodeDeclSyntax: DeclSyntax = "@inlinable\npublic func encode(to stream: inout WritableBitStream) {switch self {\(raw: encodeSyntax.joined(separator: "\n"))}}"
        
        return [codingKeysDeclSyntax, initDeclSyntax, encodeDeclSyntax]
    }
    
    private static func getDefaultSyntax(_ variableDecl: SwiftSyntax.VariableDeclSyntax) throws -> (String, String) {
        guard let variableName = variableDecl.variableName else {
            throw BitStreamCodingDiagnostic.custom("Variable has no name.").error(at: Syntax(variableDecl))
        }
        let initSyntax = "self.\(variableName) = try stream.read()"
        let encodeSyntax = "stream.append(\(variableName))"
        return (initSyntax, encodeSyntax)
    }
}

extension BitStreamCodingMacro: ExtensionMacro {
    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        let newExtension = try ExtensionDeclSyntax("extension \(type): BitStreamCodable") {}
        return [newExtension]
    }
}

@main
struct BitStreamMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BitStreamCodingMacro.self,
        CompressedFloatMacro.self,
        CompressedDoubleMacro.self,
        CompressedIntMacro.self,
        CompressedUIntMacro.self,
        NumberOfBitsMacro.self,
        CompressedFloatArrayMacro.self,
        CompressedDoubleArrayMacro.self,
        CompressedIntArrayMacro.self,
        CompressedUIntArrayMacro.self,
        BoundedArrayMacro.self,
        BytesMacro.self,
        SkipBitStreamCodingMacro.self,
        PathMacro.self
    ]
}
