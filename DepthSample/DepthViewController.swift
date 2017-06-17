//
//  DepthViewController.swift
//  DepthSample
//
//  Created by Kazuya Ueoka on 2017/06/13.
//  Copyright © 2017 fromKK. All rights reserved.
//

import UIKit
import Photos

class DepthViewController: UIViewController {
    var asset: PHAsset!
    
    private lazy var imageManager: PHImageManager = PHImageManager()
    
    private func loadBaseImage() {
        let options: PHImageRequestOptions = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        self.imageManager.requestImage(for: self.asset, targetSize: CGSize(width: UIScreen.main.bounds.size.width * UIScreen.main.scale, height: UIScreen.main.bounds.size.height * UIScreen.main.scale), contentMode: .aspectFit, options: options) { (image, info) in
            DispatchQueue.main.async {
                self.baseImageView.image = image
                self.loadDisparityImageView()
            }
        }
    }
    
    private func loadDisparityImageView() {
        self.asset.requestContentEditingInput(with: nil) { (input, info) in
            guard let imageURL: URL = input?.fullSizeImageURL else {
                return
            }
            
            if let disparityImage: CIImage = CIImage(contentsOf: imageURL, options: [kCIImageAuxiliaryDisparity: true]) {
                self.handleDisparity(with: disparityImage.applyingFilter("CIDisparityToDepth", withInputParameters: nil))
            } else if let depthImage: CIImage = CIImage(contentsOf: imageURL, options: [kCIImageAuxiliaryDepth: true]) {
                self.handleDepth(with: depthImage)
            }
        }
    }
    
    private func handleDisparity(with disparityImage: CIImage) {
        let disparityUIImage: UIImage = UIImage(ciImage: disparityImage)
        
        DispatchQueue.main.async {
            guard let image: UIImage = self.baseImageView.image?.resizedImage(with: disparityUIImage.size),
                let ciImage: CIImage = CIImage(image: image) else {
                print(#function, "image cannot load")
                return
            }
            guard let colorImage: UIImage = UIColor.red.toImage(with: disparityUIImage.size) else {
                print(#function, "colorImage create failed")
                return
            }
            
            guard let colorCIImage: CIImage = CIImage(image: colorImage) else {
                print(#function, "colorImage cannot load")
                return
            }
            
            let maskedImage: CIImage = ciImage.applyingFilter("CIBlendWithMask", withInputParameters: [
                kCIInputBackgroundImageKey: colorCIImage,
                kCIInputMaskImageKey: disparityImage.applyingFilter("CIColorClamp", withInputParameters: nil),
                ])
            self.baseImageView.image = UIImage(ciImage: maskedImage)
        }
    }
    
    private func handleDepth(with ciImage: CIImage) {
        print(#function)
        
//        self.disparityImageView.image = UIImage(ciImage: ciImage)
    }
    
    lazy var baseImageView: UIImageView = { () -> UIImageView in
        let imageView: UIImageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var disparityImageView: UIImageView = { () -> UIImageView in
        let imageView: UIImageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func loadView() {
        super.loadView()
        
        self.title = "Depth detail"
        self.navigationItem.largeTitleDisplayMode = .never
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.baseImageView)
        self.view.addSubview(self.disparityImageView)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.baseImageView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.baseImageView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.baseImageView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.baseImageView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.disparityImageView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.disparityImageView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.disparityImageView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.disparityImageView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            ])
        
        self.loadBaseImage()
//        self.loadDisparityImageView()
    }
    
}
