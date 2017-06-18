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
    
    enum Mode {
        case disparity
        case chromakey
        
        var toString: String {
            switch self {
            case .disparity:
                return "Disparity"
            case .chromakey:
                return "Chroma key"
            }
        }
    }
    var mode: Mode? {
        didSet {
            guard let mode: Mode = self.mode else { return }
            
            switch mode {
            case .disparity:
                self.loadDisparityImage()
            case .chromakey:
                self.loadDisparityWithChromakey()
            }
        }
    }
    
    var asset: PHAsset!
    
    private lazy var imageManager: PHImageManager = PHImageManager()
    private lazy var menuButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(self.handle(menuButton:)))
    
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
        self.navigationItem.rightBarButtonItem = self.menuButton
        
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
    }
    
    @objc private func handle(menuButton: UIBarButtonItem) {
        let modesViewController: ModeViewController = ModeViewController()
        modesViewController.modeSelected { [weak self] (mode) in
            self?.mode = mode
        }
        
        let navigationController: UINavigationController = UINavigationController(rootViewController: modesViewController)
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension DepthViewController {
    fileprivate func loadBaseImage() {
        let options: PHImageRequestOptions = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        
        self.imageManager.requestImage(for: self.asset, targetSize: CGSize(width: UIScreen.main.bounds.size.width * UIScreen.main.scale, height: UIScreen.main.bounds.size.height * UIScreen.main.scale), contentMode: .aspectFit, options: options) { (image, info) in
            DispatchQueue.main.async {
                self.baseImageView.image = image
            }
        }
    }
    
    fileprivate func loadDisparityImage() {
        self.asset.requestContentEditingInput(with: nil) { (input, info) in
            guard let imageURL: URL = input?.fullSizeImageURL else {
                return
            }
            
            if let disparityImage: CIImage = CIImage(contentsOf: imageURL, options: [kCIImageAuxiliaryDisparity: true]) {
                DispatchQueue.main.async {
                    self.disparityImageView.image = UIImage(ciImage: disparityImage)
                }
            }
        }
    }
    
    fileprivate func loadDisparityWithChromakey() {
        self.asset.requestContentEditingInput(with: nil) { (input, info) in
            guard let imageURL: URL = input?.fullSizeImageURL else {
                return
            }
            
            if let disparityImage: CIImage = CIImage(contentsOf: imageURL, options: [kCIImageAuxiliaryDisparity: true]) {
                self.handleDisparity(with: disparityImage)
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
            self.disparityImageView.image = UIImage(ciImage: maskedImage)
        }
    }
}
