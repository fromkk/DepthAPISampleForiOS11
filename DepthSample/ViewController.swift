//
//  ViewController.swift
//  DepthSample
//
//  Created by Kazuya Ueoka on 2017/06/13.
//  Copyright © 2017 fromKK. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    private enum Constants {
        static let numberOfColumns: Int = 3
        static let itemMargin: CGFloat = 2.0
    }
    
    private lazy var collectionLayout: UICollectionViewLayout = { () -> UICollectionViewLayout in
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        let length: CGFloat = ((UIScreen.main.bounds.size.width - (Constants.itemMargin * CGFloat(Constants.numberOfColumns + 1))) / CGFloat(Constants.numberOfColumns))
        layout.itemSize = CGSize(width: length, height: length)
        layout.minimumLineSpacing = Constants.itemMargin
        layout.minimumInteritemSpacing = Constants.itemMargin
        
        return layout
    }()
    
    lazy var collectionView: UICollectionView = { () -> UICollectionView in
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    var fetchResult: PHFetchResult <PHAsset>? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    lazy var imageManager: PHCachingImageManager = PHCachingImageManager()
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Depth Sample"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        self.view.backgroundColor = .white
        self.view.addSubview(self.collectionView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.collectionView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.collectionView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.collectionView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.collectionView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            ])
        
        self.handlePhotoLibraryAuthorization(with: PHPhotoLibrary.authorizationStatus())
        
        PHPhotoLibrary.shared().register(self)
    }
    
    private func handlePhotoLibraryAuthorization(with status: PHAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorized:
                self.loadAssets()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    self.handlePhotoLibraryAuthorization(with: status)
                })
            default:
                self.showLoadImageFailedAlert()
            }
        }
    }
    
    private func loadAssets() {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
        
        guard let assetCollection: PHAssetCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumDepthEffect, options: nil).firstObject else {
            return
        }
        
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        let options: PHFetchOptions = PHFetchOptions()
        options.sortDescriptors = [sortDescriptor]
        self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: options)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func showLoadImageFailedAlert() {
        DispatchQueue.main.async {
            let alertController: UIAlertController = UIAlertController(title: "Error", message: "Load images failed", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let asset: PHAsset = self.fetchResult?.object(at: indexPath.row) else {
            return
        }
        
        guard let cell: Cell = cell as? Cell else { return }
        
        cell.requestID = self.imageManager.requestImage(for: asset, targetSize: CGSize(width: cell.bounds.size.width * UIScreen.main.scale, height: cell.bounds.size.height * UIScreen.main.scale), contentMode: .aspectFill, options: nil) { (image, info) in
            cell.imageView.image = image
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell: Cell = cell as? Cell else { return }
        if let requestID = cell.requestID {
            self.imageManager.cancelImageRequest(requestID)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset: PHAsset = self.fetchResult?.object(at: indexPath.row) else {
            return
        }
        
        let depthViewController: DepthViewController = DepthViewController()
        depthViewController.asset = asset
        self.navigationController?.pushViewController(depthViewController, animated: true)
    }
}

extension ViewController {
    
    class Cell: UICollectionViewCell {
        static let reuseIdentifier: String = "ViewControllerCell"
        
        lazy var imageView: UIImageView = { () -> UIImageView in
            let imageView: UIImageView = UIImageView(frame: CGRect.zero)
            imageView.contentMode = .scaleAspectFill
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.clipsToBounds = true
            return imageView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.setup()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            
            self.setup()
        }
        
        private var isSetuped: Bool = false
        private func setup() {
            guard !self.isSetuped else { return }
            defer { self.isSetuped = true }
            
            self.addSubview(self.imageView)
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: self.imageView, attribute: .width, relatedBy: .equal, toItem: self.contentView, attribute: .width, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.imageView, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.imageView, attribute: .centerX, relatedBy: .equal, toItem: self.contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self.imageView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0),
                ])
        }
        var requestID: PHImageRequestID?
    }
}

extension ViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.loadAssets()
        }
    }
}
