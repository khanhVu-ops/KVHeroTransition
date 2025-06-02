//
//  TransitionAnimatable.swift
//  UICollectionViewTransitions
//
//  Created by Luis Fariña on 30/10/22.
//

import UIKit

public enum KVTransitionType {

    // MARK: Cases

    case present, dismiss
}

public enum KVInteractDismissState {
    case began
    case ended
    case changed
    case cancelled
}

public protocol KVTransitionAnimatable where Self: UIViewController {

    // MARK: Properties
    /// The corner curve of the animated view.
    var cornerCurve: CALayerCornerCurve { get }

    /// The corner radius of the animated view.
    var cornerRadius: CGFloat { get }

    /// The frame of the image view.
    var imageViewFrame: CGRect? { get }
    
    var enableInteractionDismiss: Bool { get }

    // MARK: Methods

    /// Called when the animation of a transition is about to start.
    ///
    /// - Parameters:
    ///   - transitionType: The type of the animated transition
    func animationWillStart(transitionType: KVTransitionType)

    /// Called when the animation of a transition has ended.
    ///
    /// - Parameters:
    ///   - transitionType: The type of the animated transition
    func animationDidEnd(transitionType: KVTransitionType)
    
    /// Called when Drag to dismiss start .
    func interactDismiss(state: KVInteractDismissState)
    
    /// View for drag dismiss
    func interactionViewForismiss() -> UIView?
    
    func heroImage() -> UIImage?
}

public extension KVTransitionAnimatable {
    
    // MARK: Default properties
    
    var cornerCurve: CALayerCornerCurve {
        return .continuous
    }
    
    var cornerRadius: CGFloat {
        return 0
    }
    
    var enableInteractionDismiss: Bool {
        return false
    }

    // MARK: Default methods
    
    func animationWillStart(transitionType: KVTransitionType) {
        // Default empty implementation
    }
    
    func animationDidEnd(transitionType: KVTransitionType) {
        // Default empty implementation
    }
    
    func interactDismiss(state: KVInteractDismissState) {
        
    }

    func interactionViewForismiss() -> UIView? {
        return nil
    }
    
    func heroImage() -> UIImage? {
        return nil
    }
}
