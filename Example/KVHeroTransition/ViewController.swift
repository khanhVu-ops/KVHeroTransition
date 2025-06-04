//
//  ViewController.swift
//  KVHeroTransition
//
//  Created by Khanh Vu on 06/02/2025.
//  Copyright (c) 2025 Khanh Vu. All rights reserved.
//

import UIKit
import KVHeroTransition

class ViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let heroButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hero Transition Demo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    private let pinterestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pinterest Transition Demo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemPink
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    private let bannerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Banner Transition Demo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        title = "Transition Demos"
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(heroButton)
        stackView.addArrangedSubview(pinterestButton)
        stackView.addArrangedSubview(bannerButton)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        heroButton.addTarget(self, action: #selector(heroButtonTapped), for: .touchUpInside)
        pinterestButton.addTarget(self, action: #selector(pinterestButtonTapped), for: .touchUpInside)
        bannerButton.addTarget(self, action: #selector(bannerButtonTapped), for: .touchUpInside)
    }
    
    @objc private func heroButtonTapped() {
        let heroDemoVC = HeroTransitionDemoViewController(type: .hero)
        self.navigationController?.pushViewController(heroDemoVC, animated: true)
    }
    
    @objc private func pinterestButtonTapped() {
        let heroDemoVC = HeroTransitionDemoViewController(type: .pinterest)
        self.navigationController?.pushViewController(heroDemoVC, animated: true)
    }
    
    @objc private func bannerButtonTapped() {
        let heroDemoVC = HeroTransitionDemoViewController(type: .banner)
        self.navigationController?.pushViewController(heroDemoVC, animated: true)
    }
}

