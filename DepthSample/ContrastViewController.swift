//
//  ContrastViewController.swift
//  DepthSample
//
//  Created by Kazuya Ueoka on 2017/06/26.
//  Copyright © 2017 fromKK. All rights reserved.
//

import UIKit

protocol ContrastViewControllerDelegate: class {
    func contrastVC(_ viewController: ContrastViewController, didFiltered filteredImage: CIImage)
}

class ContrastViewController: UIViewController {
    
    var baseDisparityImage: CIImage!
    weak var delegate: ContrastViewControllerDelegate?
    
    lazy var imageView: UIImageView = { () -> UIImageView in
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var slider: UISlider = { () -> UISlider in
        let slider: UISlider = UISlider()
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 1.0
        slider.addTarget(self, action: #selector(ContrastViewController.handle(slider:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    lazy var closeButton: UIBarButtonItem = { () -> UIBarButtonItem in
        let button: UIBarButtonItem = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(ContrastViewController.onTap(closeButton:)))
        return button
    }()
    
    lazy var doneButton: UIBarButtonItem = {
        let button: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(ContrastViewController.onTap(doneButton:)))
        return button
    }()
    
    override func loadView() {
        super.loadView()
        
        self.title = "Contrast"
        self.navigationItem.leftBarButtonItem = self.closeButton
        self.navigationItem.rightBarButtonItem = self.doneButton
        
        self.view.backgroundColor = .white
        self.imageView.image = UIImage(ciImage: self.baseDisparityImage)
        self.view.addSubview(self.imageView)
        self.imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0, constant: 0.0).isActive = true
        self.imageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1.0, constant: 0.0).isActive = true
        self.imageView.centerXAnchor.anchorWithOffset(to: self.view.centerXAnchor).constraint(equalToConstant: 0.0).isActive = true
        self.imageView.centerYAnchor.anchorWithOffset(to: self.view.centerYAnchor).constraint(equalToConstant: 0.0).isActive = true
        
        self.view.addSubview(self.slider)
        self.slider.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9, constant: 0.0).isActive = true
        self.slider.centerXAnchor.anchorWithOffset(to: self.view.centerXAnchor).constraint(equalToConstant: 0.0).isActive = true
        self.slider.bottomAnchor.anchorWithOffset(to: self.view.safeAreaLayoutGuide.bottomAnchor).constraint(equalToConstant: 10.0).isActive = true
        self.handle(slider: self.slider)
    }
    
}

extension ContrastViewController {
    
    @objc fileprivate func onTap(closeButton: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func resultImage(with slider: UISlider) -> CIImage {
        let bias: CGFloat = -0.1
        return self.baseDisparityImage.applyingFilter("CIColorMatrix", withInputParameters: [
            "inputRVector" : CIVector(x: CGFloat(slider.value), y: 0, z: 0, w: 0),
            "inputGVector" : CIVector(x: 0, y: CGFloat(slider.value), z: 0, w: 0),
            "inputBVector" : CIVector(x: 0, y: 0, z: CGFloat(slider.value), w: 0),
            "inputBiasVector" : CIVector(x: bias, y: bias, z: bias, w: 0)])
    }
    
    @objc fileprivate func onTap(doneButton: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.delegate?.contrastVC(self, didFiltered: self.resultImage(with: self.slider))
        }
    }
    
    @objc fileprivate func handle(slider: UISlider) {
        print(#function, slider.value)
        
        // Clamp the mask values to [0,1]
        self.imageView.image = UIImage(ciImage: self.resultImage(with: slider))
    }
}
