//
//  UIImageExtension.swift
//  DepthSample
//
//  Created by Kazuya Ueoka on 2017/06/17.
//  Copyright © 2017 fromKK. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImage(with size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        self.draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
