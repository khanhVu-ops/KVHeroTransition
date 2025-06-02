//
//  KVHeroPresentAnimationController.swift
//  KVHeroTransition
//
//  Created by Khanh Vu on 2/6/25.
//

import UIKit

final class KVHeroPresentAnimationController: NSObject {

    // MARK: Properties

    private let presentingViewController: KVTransitionAnimatable
    private let presentedViewController: KVTransitionAnimatable
    private let animationDuration: TimeInterval

    // MARK: Initialization

    init(
        presentingViewController: KVTransitionAnimatable,
        presentedViewController: KVTransitionAnimatable,
        animationDuration: TimeInterval = 0.25
    ) {
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        self.animationDuration = animationDuration
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension KVHeroPresentAnimationController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        animationDuration
    }

    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        notifyAnimationStart()
        
        // Validate required components
        guard let components = validateTransitionComponents(transitionContext) else {
            completeTransition(transitionContext, success: false)
            return
        }
        
        // Perform animation based on whether hero image is available
        if presentingViewController.heroImage() != nil {
            animateWithHeroImage(using: transitionContext, components: components)
        } else {
            animateWithViewSnapshot(using: transitionContext, components: components)
        }
    }
}

// MARK: - Private Methods

private extension KVHeroPresentAnimationController {
    
    struct TransitionComponents {
        let toViewController: UIViewController
        let snapshotView: UIView
        let presentingFrame: CGRect
        let presentedFrame: CGRect
    }
    
    func validateTransitionComponents(
        _ transitionContext: UIViewControllerContextTransitioning
    ) -> TransitionComponents? {
        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let snapshotView = toViewController.view.snapshotView(afterScreenUpdates: true),
            let presentingFrame = presentingViewController.imageViewFrame,
            let presentedFrame = presentedViewController.imageViewFrame
        else {
            return nil
        }
        
        return TransitionComponents(
            toViewController: toViewController,
            snapshotView: snapshotView,
            presentingFrame: presentingFrame,
            presentedFrame: presentedFrame
        )
    }
    
    func notifyAnimationStart() {
        [presentingViewController, presentedViewController].forEach {
            $0.animationWillStart(transitionType: .present)
        }
    }
    
    func completeTransition(_ transitionContext: UIViewControllerContextTransitioning, success: Bool) {
        transitionContext.completeTransition(success)
        
        [presentingViewController, presentedViewController].forEach {
            $0.animationDidEnd(transitionType: success ? .present : .dismiss)
        }
    }
    
    func animateWithHeroImage(
        using transitionContext: UIViewControllerContextTransitioning,
        components: TransitionComponents
    ) {
        let snapshotViewContainerView = UIImageView()
        snapshotViewContainerView.contentMode = .scaleAspectFill
        snapshotViewContainerView.image = presentingViewController.heroImage()
        snapshotViewContainerView.clipsToBounds = true
        snapshotViewContainerView.frame = components.presentingFrame
        snapshotViewContainerView.layer.cornerCurve = presentingViewController.cornerCurve
        snapshotViewContainerView.layer.cornerRadius = presentingViewController.cornerRadius
        
        [components.toViewController.view,
         snapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        components.toViewController.view.isHidden = true
        transitionContext.containerView.layoutIfNeeded()
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            snapshotViewContainerView.layer.cornerRadius = self.presentedViewController.cornerRadius
            snapshotViewContainerView.frame = components.presentedFrame

        } completion: { _ in
            components.toViewController.view.isHidden = false
            snapshotViewContainerView.removeFromSuperview()
            self.completeTransition(transitionContext, success: !transitionContext.transitionWasCancelled)
        }
    }
    
    func animateWithViewSnapshot(
        using transitionContext: UIViewControllerContextTransitioning,
        components: TransitionComponents
    ) {
        // Implementation for view snapshot animation
        // Set the frame of the presented view controller's snapshot so that the position and size of its image view
        // are the same as those of the presenting view controller's image view
        let finalFrame = transitionContext.finalFrame(for: components.toViewController)
        let scaleFactorX = components.presentingFrame.width / components.presentedFrame.width
        let scaleFactorY = components.presentingFrame.height / components.presentedFrame.height

        let scaleTransform = CGAffineTransform(scaleX: scaleFactorX, y: scaleFactorY)
        components.snapshotView.frame = finalFrame.applying(scaleTransform)
        components.snapshotView.frame.origin.y -= components.presentedFrame.applying(scaleTransform).origin.y
        components.snapshotView.frame.origin.x -= components.presentedFrame.applying(scaleTransform).origin.x

//         Create a view to mask the snapshot of the presented view controller so that it
//         looks like the selected cell from the presenting view controller
        let snapshotViewContainerView = UIView()
        snapshotViewContainerView.clipsToBounds = true
        snapshotViewContainerView.frame = components.presentingFrame
        snapshotViewContainerView.layer.cornerCurve = presentingViewController.cornerCurve
        snapshotViewContainerView.layer.cornerRadius = presentingViewController.cornerRadius
        snapshotViewContainerView.addSubview(components.snapshotView)
        
        

        // Both the view of the presented view controller and its snapshot must be
        // added to the `transitionContext.containerView` view for the animation to
        // properly take place
        [components.toViewController.view,
         snapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        components.toViewController.view.isHidden = true
        transitionContext.containerView.layoutIfNeeded()
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            [components.snapshotView, snapshotViewContainerView].forEach {
                $0.frame = finalFrame
            }
            snapshotViewContainerView.layer.cornerRadius = self.presentedViewController.cornerRadius

        } completion: { _ in
            components.toViewController.view.isHidden = false
            snapshotViewContainerView.removeFromSuperview()
            self.completeTransition(transitionContext, success: !transitionContext.transitionWasCancelled)
        }
    }
}
