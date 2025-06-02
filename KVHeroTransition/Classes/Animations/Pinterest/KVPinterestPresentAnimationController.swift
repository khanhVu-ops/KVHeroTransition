//
//  KVPinterestPresentAnimationController.swift
//  KVHeroTransition
//
//  Created by Khanh Vu on 2/6/25.
//

import UIKit

final class KVPinterestPresentAnimationController: NSObject {

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

extension KVPinterestPresentAnimationController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        0.5
    }

    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        notifyAnimationStart()

        guard let components = validateTransitionComponents(transitionContext) else {
            completeTransition(transitionContext, success: false)
            return
        }
//        animateWithViewSnapshot(using: transitionContext, components: components)
        if presentingViewController.heroImage() != nil {
            animateWithHeroImage(using: transitionContext, components: components)
        } else {
            animateWithViewSnapshot(using: transitionContext, components: components)
        }
    }
}

// MARK: - Private Methods

private extension KVPinterestPresentAnimationController {
    
    struct TransitionComponents {
        let fromViewController: UIViewController
        let toViewController: UIViewController
        let fromSnapshotView: UIView
        let toSnapshotView: UIView
        let presentingFrame: CGRect
        let presentedFrame: CGRect
        let toSnapshotViewScaleFactorX: CGFloat
        let toSnapshotViewScaleFactorY: CGFloat
    }
    
    func validateTransitionComponents(
        _ transitionContext: UIViewControllerContextTransitioning
    ) -> TransitionComponents? {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let fromSnapshotView = fromViewController.view.snapshotView(afterScreenUpdates: true),
              let toSnapshotView = toViewController.view.snapshotView(afterScreenUpdates: true),
              let presentingFrame = presentingViewController.imageViewFrame,
              let presentedFrame = presentedViewController.imageViewFrame
        else {
            return nil
        }
        let tempScaleX = presentingFrame.width / presentedFrame.width
        let toSnapshotViewScaleFactorX = tempScaleX.isNaN ? 1.0 : tempScaleX
        let tempScaleY = presentingFrame.height / presentedFrame.height
        let toSnapshotViewScaleFactorY = tempScaleY.isNaN ? 1 : tempScaleY
        
        return TransitionComponents(
            fromViewController: fromViewController,
            toViewController: toViewController,
            fromSnapshotView: fromSnapshotView,
            toSnapshotView: toSnapshotView,
            presentingFrame: presentingFrame,
            presentedFrame: presentedFrame,
            toSnapshotViewScaleFactorX: toSnapshotViewScaleFactorX,
            toSnapshotViewScaleFactorY: toSnapshotViewScaleFactorY
            
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
    
    func transformFromSnapshotView(using transitionContext: UIViewControllerContextTransitioning, components: TransitionComponents) {
        
        // Scale up the snapshot of the presenting view controller to make it look like the presented view controller is being
        // zoomed in
        components.fromSnapshotView.alpha = 0
        let fromSnapshotViewScaleFactorX = 1 / components.toSnapshotViewScaleFactorX
        let fromSnapshotViewScaleFactorY = 1 / components.toSnapshotViewScaleFactorY

        let fromSnapshotViewScaleTransform = CGAffineTransform(scaleX: fromSnapshotViewScaleFactorX, y: fromSnapshotViewScaleFactorY)
        components.fromSnapshotView.frame = components.fromSnapshotView.frame.applying(fromSnapshotViewScaleTransform)
        let scaledUpImageViewFrame = components.presentingFrame.applying(fromSnapshotViewScaleTransform)
        components.fromSnapshotView.frame.origin.x -= scaledUpImageViewFrame.origin.x
        components.fromSnapshotView.frame.origin.y -= scaledUpImageViewFrame.origin.y
    }
    
    func animateWithHeroImage(
        using transitionContext: UIViewControllerContextTransitioning,
        components: TransitionComponents
    ) {
        let toSnapshotViewContainerView = UIImageView()
        toSnapshotViewContainerView.contentMode = .scaleAspectFill
        toSnapshotViewContainerView.image = presentingViewController.heroImage()
        toSnapshotViewContainerView.clipsToBounds = true
        toSnapshotViewContainerView.frame = components.presentingFrame
        toSnapshotViewContainerView.layer.cornerCurve = presentingViewController.cornerCurve
        toSnapshotViewContainerView.layer.cornerRadius = presentingViewController.cornerRadius
        // Both the view of the presented view controller and its snapshot must be
        // added to the `transitionContext.containerView` view for the animation to
        // properly take place
        [components.toViewController.view,
         toSnapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        components.toViewController.view.isHidden = true

        
        // The snapshot of the presenting view controller must be
        // added to the `transitionContext.containerView` view as well
        transitionContext.containerView.insertSubview(
            components.fromSnapshotView,
            belowSubview: toSnapshotViewContainerView
        )
        components.fromViewController.view.isHidden = true

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            // Scale up the snapshot of the presenting view controller to make it look like the presented view controller is being
            // zoomed in
            self.transformFromSnapshotView(using: transitionContext, components: components)
            
            toSnapshotViewContainerView.layer.cornerRadius = self.presentedViewController.cornerRadius
            toSnapshotViewContainerView.frame = components.presentedFrame
            
        } completion: { _ in
            [components.fromViewController, components.toViewController].forEach {
                $0.view.isHidden = false
            }
            toSnapshotViewContainerView.removeFromSuperview()
            self.completeTransition(transitionContext, success: !transitionContext.transitionWasCancelled)
        }
    }
    
    func animateWithViewSnapshot(
        using transitionContext: UIViewControllerContextTransitioning,
        components: TransitionComponents
    ) {
        // Set the frame of the presented view controller's snapshot so that the position and size of its image view will be the
        // same as those of the presenting view controller's image view
        let finalFrame = transitionContext.finalFrame(for: components.toViewController)
        let toSnapshotViewScaleTransform = CGAffineTransform(scaleX: components.toSnapshotViewScaleFactorX, y: components.toSnapshotViewScaleFactorY)
        components.toSnapshotView.frame = finalFrame.applying(toSnapshotViewScaleTransform)
        components.toSnapshotView.frame.origin.y -= components.presentedFrame.applying(toSnapshotViewScaleTransform).origin.y
        components.toSnapshotView.frame.origin.x -= components.presentedFrame.applying(toSnapshotViewScaleTransform).origin.x

        // Create a view to mask the snapshot of the presented view controller so that it
        // looks like the selected cell from the presenting view controller
        let toSnapshotViewContainerView = UIView()
        toSnapshotViewContainerView.clipsToBounds = true
        toSnapshotViewContainerView.frame = components.presentingFrame
        toSnapshotViewContainerView.layer.cornerCurve = presentingViewController.cornerCurve
        toSnapshotViewContainerView.layer.cornerRadius = presentingViewController.cornerRadius
        toSnapshotViewContainerView.addSubview(components.toSnapshotView)
        
        // Both the view of the presented view controller and its snapshot must be
        // added to the `transitionContext.containerView` view for the animation to
        // properly take place
        [components.toViewController.view,
         toSnapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        components.toViewController.view.isHidden = true

        
        // The snapshot of the presenting view controller must be
        // added to the `transitionContext.containerView` view as well
        transitionContext.containerView.insertSubview(
            components.fromSnapshotView,
            belowSubview: toSnapshotViewContainerView
        )
        components.fromViewController.view.isHidden = true

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            // Scale up the snapshot of the presenting view controller to make it look like the presented view controller is being
            // zoomed in
            self.transformFromSnapshotView(using: transitionContext, components: components)
            
            [components.toSnapshotView, toSnapshotViewContainerView].forEach {
                $0.frame = finalFrame
            }
            toSnapshotViewContainerView.layer.cornerRadius = self.presentedViewController.cornerRadius
        } completion: { _ in
            [components.fromViewController, components.toViewController].forEach {
                $0.view.isHidden = false
            }
            [components.fromSnapshotView, toSnapshotViewContainerView].forEach {
                $0.removeFromSuperview()
            }
            self.completeTransition(transitionContext, success: !transitionContext.transitionWasCancelled)
        }
    }
}
