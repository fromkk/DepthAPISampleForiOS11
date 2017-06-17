//
//  UIColorExtension.swift
//  DepthSample
//
//  Created by Kazuya Ueoka on 2017/06/17.
//  Copyright © 2017 fromKK. All rights reserved.
//

import UIKit

extension UIColor {
    func toImage(with size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        self.setFill()
        
        let bezier: UIBezierPath = UIBezierPath(rect: CGRect(origin: .zero, size: size))
        bezier.fill()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
