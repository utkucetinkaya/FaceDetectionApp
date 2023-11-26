//
//  UIColor+Ext.swift
//  FaceDetectionApp
//
//  Created by Utku Çetinkaya on 26.11.2023.
//

import UIKit

extension UIColor {
    static var navigationBackground: UIColor {
        UIColor(named: "NavigationBackground") ?? .tintColor
    }

    static var primaryColor: UIColor {
        UIColor(named: "PrimaryColor") ?? .secondarySystemBackground
    }

    static var secondaryColor: UIColor {
        UIColor(named: "SecondaryColor") ?? .tintColor
    }
    
    static var faceBoxColor: UIColor {
        UIColor(named: "FaceBoxColor") ?? .tintColor
    }
    
    static var textColor: UIColor {
        UIColor(named: "TextColor") ?? .tintColor
    }
}
