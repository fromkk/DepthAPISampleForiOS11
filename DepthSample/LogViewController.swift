//
//  LogViewController.swift
//  DepthSample
//
//  Created by Kazuya Ueoka on 2017/06/19.
//  Copyright © 2017 fromKK. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {
    var log: String! {
        didSet {
            self.logLabel.text = self.log
        }
    }
    
    lazy var logLabel: UILabel = { () -> UILabel in
        let label: UILabel = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var scrollView: UIScrollView = { () -> UIScrollView in
        let scrollView: UIScrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var contentView: UIView = { () -> UIView in
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var closeButton: UIBarButtonItem = { () -> UIBarButtonItem in
        let button: UIBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(self.handle(closeButton:)))
        return button
    }()
    
    override func loadView() {
        super.loadView()
        
        self.title = "Log"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        self.navigationItem.leftBarButtonItem = self.closeButton
        
        self.view.backgroundColor = .white
        self.view.addSubview(self.scrollView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.scrollView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.scrollView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.scrollView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.scrollView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            ])
        
        self.scrollView.addSubview(self.contentView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.contentView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.contentView, attribute: .centerX, relatedBy: .equal, toItem: self.scrollView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.contentView, attribute: .top, relatedBy: .equal, toItem: self.scrollView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.contentView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.scrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            ])
        
        self.contentView.addSubview(self.logLabel)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.logLabel, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1.0, constant: 16.0),
            NSLayoutConstraint(item: self.logLabel, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: -16.0),
            NSLayoutConstraint(item: self.logLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 16.0),
            NSLayoutConstraint(item: self.logLabel, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: -16.0),
            ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logLabel.text = self.log
    }
    
    @objc private func handle(closeButton: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
