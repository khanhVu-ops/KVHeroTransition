//
//  KVTransitionAnimatable.swift
//  KVHeroTransition
//
//  Created by Khanh Vu on 2/6/25.
//

import UIKit

public protocol KVTransitionAnimatable where Self: UIViewController {
    
    // MARK: - Visual Properties
    
    /// The corner curve of the animated view
    var cornerCurve: CALayerCornerCurve { get }
    
    /// The corner radius of the animated view
    var cornerRadius: CGFloat { get }
    
    /// The frame of the image view for transition
    var imageViewFrame: CGRect? { get }
    
    /// Whether interactive dismiss gesture is enabled
    var enableInteractionDismiss: Bool { get }
    
    // MARK: - Content Methods
    
    /// Returns the hero image for transition animation
    func heroImage() -> UIImage?
    
    func heroImageContentMode() -> UIView.ContentMode
    
    /// Returns the view that responds to dismiss interaction
    func interactionViewForDismiss() -> UIView?
    
    // MARK: - Lifecycle Methods
    
    /// Called when transition animation is about to start
    func animationWillStart(transitionType: KVTransitionType)
    
    /// Called when transition animation has ended
    func animationDidEnd(transitionType: KVTransitionType)
    
    /// Called during interactive dismiss gesture
    func interactDismiss(state: KVInteractDismissState)
}

// MARK: - Default Implementation

public extension KVTransitionAnimatable {
    
    var cornerCurve: CALayerCornerCurve {
        return .continuous
    }
    
    var cornerRadius: CGFloat {
        return 0.0
    }
    
    var enableInteractionDismiss: Bool {
        return false
    }
    
    func animationWillStart(transitionType: KVTransitionType) {
        // Default empty implementation
    }
    
    func animationDidEnd(transitionType: KVTransitionType) {
        // Default empty implementation
    }
    
    func interactDismiss(state: KVInteractDismissState) {
        // Default empty implementation
    }
    
    func interactionViewForDismiss() -> UIView? {
        return nil
    }
    
    func heroImage() -> UIImage? {
        return nil
    }
    
    func heroImageContentMode() -> UIView.ContentMode {
        return .scaleAspectFill
    }
}
