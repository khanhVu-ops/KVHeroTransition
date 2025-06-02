//
//  KVHeroDismissAnimationController.swift
//  KVHeroTransition
//
//  Created by Khanh Vu on 2/6/25.
//
import UIKit

final class KVHeroDismissAnimationController: NSObject {

    // MARK: Properties

    private let presentingViewController: KVTransitionAnimatable
    private let presentedViewController: KVTransitionAnimatable

    // MARK: Initialization

    init(
        presentingViewController: KVTransitionAnimatable,
        presentedViewController: KVTransitionAnimatable
    ) {
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension KVHeroDismissAnimationController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        0.25
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
        
        if presentedViewController.heroImage() != nil  {
            animateWithHeroImage(using: transitionContext, components: components)
        } else {
            animateWithViewSnapshot(using: transitionContext, components: components)
        }
    }
}

// MARK: - Private Methods

private extension KVHeroDismissAnimationController {
    
    struct TransitionComponents {
        let fromViewController: UIViewController
        let snapshotView: UIView
        let presentingFrame: CGRect
        let presentedFrame: CGRect
    }
    
    func validateTransitionComponents(
        _ transitionContext: UIViewControllerContextTransitioning
    ) -> TransitionComponents? {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from),
            let snapshotView = fromViewController.view.snapshotView(afterScreenUpdates: true),
            let presentingFrame = presentingViewController.imageViewFrame,
            let presentedFrame = presentedViewController.imageViewFrame
        else {
            return nil
        }
        
        return TransitionComponents(
            fromViewController: fromViewController,
            snapshotView: snapshotView,
            presentingFrame: presentingFrame,
            presentedFrame: presentedFrame
        )
    }
    
    func notifyAnimationStart() {
        [presentingViewController, presentedViewController].forEach {
            $0.animationWillStart(transitionType: .dismiss)
        }
    }
    
    func completeTransition(_ transitionContext: UIViewControllerContextTransitioning, success: Bool) {
        transitionContext.completeTransition(success)
        
        [presentingViewController, presentedViewController].forEach {
            $0.animationDidEnd(transitionType: success ? .dismiss : .present)
        }
    }
    
    func animateWithHeroImage(
        using transitionContext: UIViewControllerContextTransitioning,
        components: TransitionComponents
    ) {
        let snapshotViewContainerView = UIImageView()
        snapshotViewContainerView.contentMode = .scaleAspectFit
        snapshotViewContainerView.image = presentedViewController.heroImage()
        snapshotViewContainerView.clipsToBounds = true
        snapshotViewContainerView.frame = components.presentedFrame
        snapshotViewContainerView.layer.cornerCurve = presentedViewController.cornerCurve
        snapshotViewContainerView.layer.cornerRadius = presentedViewController.cornerRadius
        // Both the view of the presented view controller and its snapshot must be
        // added to the `transitionContext.containerView` view for the animation to
        // properly take place
        [components.fromViewController.view,
         snapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        components.fromViewController.view.isHidden = true

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            snapshotViewContainerView.frame = components.presentingFrame
            snapshotViewContainerView.layer.cornerRadius = self.presentingViewController.cornerRadius
            snapshotViewContainerView.contentMode = .scaleAspectFill
        } completion: { _ in
            components.fromViewController.view.isHidden = false
            snapshotViewContainerView.removeFromSuperview()
            self.completeTransition(transitionContext, success: !transitionContext.transitionWasCancelled)
        }
    }
    
    func animateWithViewSnapshot(
        using transitionContext: UIViewControllerContextTransitioning,
        components: TransitionComponents
    ) {
        // Create a view to mask the snapshot of the presented view controller so that it
        // will look like the selected cell from the presenting view controller at the end
        // of the animation
        let initialFrame = transitionContext.initialFrame(for: components.fromViewController)
        let snapshotViewContainerView = UIView()
        snapshotViewContainerView.clipsToBounds = true
        snapshotViewContainerView.frame = initialFrame
        snapshotViewContainerView.layer.cornerCurve = presentedViewController.cornerCurve
        snapshotViewContainerView.layer.cornerRadius = presentedViewController.cornerRadius
        snapshotViewContainerView.addSubview(components.snapshotView)
        
        // Both the view of the presented view controller and its snapshot must be
        // added to the `transitionContext.containerView` view for the animation to
        // properly take place
        [components.fromViewController.view,
         snapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        components.fromViewController.view.isHidden = true

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            // Set the frame of the presented view controller's snapshot so that the position and size of its image view
            // will be the same as those of the presenting view controller's image view
            let scaleFactorX = components.presentingFrame.width / components.presentedFrame.width
            let scaleFactorY = components.presentingFrame.height / components.presentedFrame.height
            let scaleTransform = CGAffineTransform(scaleX: scaleFactorX.isNaN ? 1 : scaleFactorX, y: scaleFactorY.isNaN ? 1 : scaleFactorY)
            components.snapshotView.frame = initialFrame.applying(scaleTransform)
            components.snapshotView.frame.origin.y -= components.presentedFrame.applying(scaleTransform).origin.y
            components.snapshotView.frame.origin.x -= components.presentedFrame.applying(scaleTransform).origin.x

            snapshotViewContainerView.frame = components.presentingFrame
            snapshotViewContainerView.layer.cornerRadius = self.presentingViewController.cornerRadius
        } completion: { _ in
            components.fromViewController.view.isHidden = false
            snapshotViewContainerView.removeFromSuperview()
            self.completeTransition(transitionContext, success: !transitionContext.transitionWasCancelled)
        }
    }
}
