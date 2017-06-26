//
//  ModeViewController.swift
//  DepthSample
//
//  Created by Kazuya Ueoka on 2017/06/18.
//  Copyright © 2017 fromKK. All rights reserved.
//

import UIKit

class ModeViewController: UIViewController {
    typealias ModeSelected = (DepthViewController.Mode) -> ()
    private var _modeSelected: ModeSelected?
    func modeSelected(_ modeSelected: @escaping ModeSelected) {
        self._modeSelected = modeSelected
    }
    
    let modes: [DepthViewController.Mode] = [.default, .disparity, .chromakey, .contrast, .log]
    
    lazy var tableView: UITableView = { () -> UITableView in
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    lazy var closeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.handle(closeButton:)))
    
    override func loadView() {
        super.loadView()
        
        self.title = "Mode"
        self.navigationItem.leftBarButtonItem = self.closeButton
        
        self.view.backgroundColor = .white
        self.view.addSubview(self.tableView)
        self.tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0, constant: 0.0).isActive = true
        self.tableView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1.0, constant: 0.0).isActive = true
        self.tableView.centerXAnchor.anchorWithOffset(to: self.view.centerXAnchor).constraint(equalToConstant: 0.0).isActive = true
        self.tableView.centerYAnchor.anchorWithOffset(to: self.view.centerYAnchor).constraint(equalToConstant: 0.0).isActive = true
    }
    
    @objc private func handle(closeButton: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ModeViewController {
    class Cell: UITableViewCell {
        static let reuseIdentifier: String = "ModeCell"
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
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
            
            self.contentView.addSubview(self.titleLabel)
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: self.titleLabel, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1.0, constant: 16.0),
                NSLayoutConstraint(item: self.titleLabel, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: 16.0),
                NSLayoutConstraint(item: self.titleLabel, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 8.0),
                NSLayoutConstraint(item: self.titleLabel, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: -16.0),
                ])
        }
        
        lazy var titleLabel: UILabel = { () -> UILabel in
            let label: UILabel = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    }
}

extension ModeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.modes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath)
        if let cell: Cell = cell as? Cell {
            cell.titleLabel.text = self.modes[indexPath.row].toString
        }
        return cell
    }
}

extension ModeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self._modeSelected?(self.modes[indexPath.row])
        }
    }
}
