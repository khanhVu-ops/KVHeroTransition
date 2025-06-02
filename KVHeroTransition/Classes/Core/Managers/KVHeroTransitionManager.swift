//
//  KVHeroTransitionManager.swift
//  KVHeroTransition
//
//  Created by Khanh Vu on 2/6/25.
//

import UIKit

public final class KVHeroTransitionManager: NSObject {

    // MARK: Properties

    private weak var presentingViewController: KVTransitionAnimatable?
    private weak var presentedViewController: KVTransitionAnimatable?

    private let interactionControllerForDismissal: KVInteractionControllerProtocol

    // MARK: Initialization

    public init(
        presentingViewController: KVTransitionAnimatable,
        presentedViewController: KVTransitionAnimatable
    ) {
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController

        interactionControllerForDismissal = KVDismissInteractionController(
            viewController: presentedViewController
        )
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension KVHeroTransitionManager: UIViewControllerTransitioningDelegate {

    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let presentingViewController,
              let presentedViewController
        else {
            return nil
        }

        return KVHeroPresentAnimationController(
            presentingViewController: presentingViewController,
            presentedViewController: presentedViewController
        )
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let presentingViewController,
              let presentedViewController
        else {
            return nil
        }
        
        return KVHeroDismissAnimationController(
            presentingViewController: presentingViewController,
            presentedViewController: presentedViewController
        )
    }

    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        // If the interaction is in progress that means the view
        // controller has been dismissed by swiping from the edge
        // of the screen, so we return the corresponding interaction
        // controller.
        // If the interaction is not in progress then the view
        // controller has been dismissed by tapping the dismiss
        // button, so we return `nil` since the animation is not
        // interactive.
        guard interactionControllerForDismissal.isInProgress else {
            return nil
        }

        return interactionControllerForDismissal
    }
}
