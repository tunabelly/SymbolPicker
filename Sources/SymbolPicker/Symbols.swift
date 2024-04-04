//
//  Symbols.swift
//  SymbolPicker
//
//  Created by Yubo Qin on 1/12/23.
//

import Foundation

/// Simple singleton class for providing symbols list per platform availability.
class Symbols {

    /// Singleton instance.
    static let shared = Symbols()

    /// Array of all available symbol name strings.
    let allSymbols: [String]

    private init() {
        // first try to get the list dynamically so it's up-to-date for all new OS versions
        let dynamicSymbolNames = Self.loadAndParseAvailableSFSymbols()
        
        if dynamicSymbolNames.isEmpty == false {
            // use the dynamic list
            self.allSymbols = dynamicSymbolNames
        }
        else {
            // determine which hardcoded list to use
            var filename: String!
            
            if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *) {
                filename = "sfsymbol5"
            } else if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                filename = "sfsymbol4"
            } else {
                filename = "sfsymbol"
            }
            
            // load the list
            self.allSymbols = Self.fetchSFSymbolsFromTextFile(filename)
        }
    }
    
    /// Return a dynamic list of available SF Symbols for the current OS.
    private static func loadAndParseAvailableSFSymbols() -> [String] {
        let bundleName = "com.apple.CoreGlyphs"
        let fileName = "name_availability"
        let keyName = "symbols"
        
        var allSymbols = [String]()
        
        // try to load the system bundle that contains the list
        if let bundle = Bundle(identifier: bundleName),
           let resourcePath = bundle.path(forResource: fileName, ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: resourcePath),
           let plistSymbols = plist[keyName] as? [String: String] {
            // get the list of keys, which are the symbol names
            allSymbols = Array(plistSymbols.keys)
        }
        
        return allSymbols
    }


    private static func fetchSFSymbolsFromTextFile(_ fileName: String) -> [String] {
        // load the internal plist
        guard let path = Bundle.module.path(forResource: fileName, ofType: "txt"),
              let content = try? String(contentsOfFile: path) else {
            #if DEBUG
            assertionFailure("[SymbolPicker] Failed to load bundle resource file.")
            #endif
            return []
        }
        
        // split the file into lines and return that as an array
        return content
            .split(separator: "\n")
            .map { String($0) }
    }

}
