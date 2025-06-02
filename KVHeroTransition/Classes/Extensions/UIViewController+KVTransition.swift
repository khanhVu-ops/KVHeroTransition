//
//  UIViewController+KVTransition.swift
//  Pods
//
//  Created by Khanh Vu on 2/6/25.
//

import UIKit

public extension UIViewController {
    
    /// Present view controller with hero transition
    func presentWithHeroTransition(
        _ viewController: UIViewController & KVTransitionAnimatable,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let presentingVC = self as? KVTransitionAnimatable else {
            present(viewController, animated: animated, completion: completion)
            return
        }
        
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = KVHeroTransitionManager(
            presentingViewController: presentingVC,
            presentedViewController: viewController
        )
        
        present(viewController, animated: animated, completion: completion)
    }
    
    /// Present view controller with Pinterest-style transition
    func presentWithPinterestTransition(
        _ viewController: UIViewController & KVTransitionAnimatable,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let presentingVC = self as? KVTransitionAnimatable else {
            present(viewController, animated: animated, completion: completion)
            return
        }
        
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = KVPinterestTransitionManager(
            presentingViewController: presentingVC,
            presentedViewController: viewController
        )
        
        present(viewController, animated: animated, completion: completion)
    }
}
