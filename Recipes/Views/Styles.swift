//
//  Styles.swift
//  Recipes
//
//  Created by Elliot Schrock on 3/1/24.
//

import SwiftUI

/// Not much here, but I like to include a file like this for reusable components and common styling code.

let margin: CGFloat = 16
var maxImageHeight: CGFloat = 300
let singleColumnWidth: CGFloat = 355

/// We don't have a localization file, but I include it for good measure
extension String {
    public func localized() -> String {
        return NSLocalizedString(
            self,
            tableName: "Localizable",
            bundle: .main,
            value: self,
            comment: self
        )
    }
    
    func localized(arguments: [CVarArg]) -> String {
        return String(format: self.localized(), arguments: arguments)
    }
}
