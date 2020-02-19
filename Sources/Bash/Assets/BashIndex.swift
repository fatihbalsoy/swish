//
//  BashIndex.swift
//  
//
//  Created by Fatih Balsoy on 2/19/20.
//


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let bashIndex = try BashIndex(json)

import Foundation

// MARK: - BashIndex
class BashIndex: Codable {
    let bashCommands: BashCommands

    init(bashCommands: BashCommands) {
        self.bashCommands = bashCommands
    }
}

// MARK: BashIndex convenience initializers and mutators

extension BashIndex {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(BashIndex.self, from: data)
        self.init(bashCommands: me.bashCommands)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        bashCommands: BashCommands? = nil
    ) -> BashIndex {
        return BashIndex(
            bashCommands: bashCommands ?? self.bashCommands
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// BashCommands.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let bashCommands = try BashCommands(json)

import Foundation

// MARK: - BashCommands
class BashCommands: Codable {
    let bash, touch, mkdir, ls: BashCodable

    init(bash: BashCodable, touch: BashCodable, mkdir: BashCodable, ls: BashCodable) {
        self.bash = bash
        self.touch = touch
        self.mkdir = mkdir
        self.ls = ls
    }
}

// MARK: BashCommands convenience initializers and mutators

extension BashCommands {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(BashCommands.self, from: data)
        self.init(bash: me.bash, touch: me.touch, mkdir: me.mkdir, ls: me.ls)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        bash: BashCodable? = nil,
        touch: BashCodable? = nil,
        mkdir: BashCodable? = nil,
        ls: BashCodable? = nil
    ) -> BashCommands {
        return BashCommands(
            bash: bash ?? self.bash,
            touch: touch ?? self.touch,
            mkdir: mkdir ?? self.mkdir,
            ls: ls ?? self.ls
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// BashCodable.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let bash = try BashCodable(json)

import Foundation

// MARK: - BashCodable
class BashCodable: Codable {
    let discription, usage: String

    init(discription: String, usage: String) {
        self.discription = discription
        self.usage = usage
    }
}

// MARK: BashCodable convenience initializers and mutators

extension BashCodable {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(BashCodable.self, from: data)
        self.init(discription: me.discription, usage: me.usage)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        discription: String? = nil,
        usage: String? = nil
    ) -> BashCodable {
        return BashCodable(
            discription: discription ?? self.discription,
            usage: usage ?? self.usage
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// JSONSchemaSupport.swift

import Foundation

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
