//
//  KVPinterestDismissAnimationController.swift
//  KVHeroTransition
//
//  Created by Khanh Vu on 2/6/25.
//

import UIKit

final class KVPinterestDismissAnimationController: NSObject {

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

extension KVPinterestDismissAnimationController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        0.5
    }

    // swiftlint:disable function_body_length line_length
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        notifyAnimationStart()
        
        guard let components = validateTransitionComponents(transitionContext) else {
            completeTransition(transitionContext, success: false)
            return
        }
        
        if presentedViewController.heroImage() != nil {
            animateWithHeroImage(using: transitionContext, components: components)
        } else {
            animateWithViewSnapshot(using: transitionContext, components: components)
        }
    }
}


// MARK: - Private Methods

private extension KVPinterestDismissAnimationController {
    
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
        let toSnapshotScaleX = presentedFrame.width / presentingFrame.width
        let toSnapshotScaleY = presentedFrame.height / presentingFrame.height

        return TransitionComponents(
            fromViewController: fromViewController,
            toViewController: toViewController,
            fromSnapshotView: fromSnapshotView,
            toSnapshotView: toSnapshotView,
            presentingFrame: presentingFrame,
            presentedFrame: presentedFrame,
            toSnapshotViewScaleFactorX: toSnapshotScaleX.isNaN ? 1 : toSnapshotScaleX,
            toSnapshotViewScaleFactorY: toSnapshotScaleY.isNaN ? 1 : toSnapshotScaleY
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
        let fromSnapshotViewContainerView = UIImageView()
        fromSnapshotViewContainerView.contentMode = presentingViewController.heroImageContentMode()
        fromSnapshotViewContainerView.image = presentedViewController.heroImage()
        fromSnapshotViewContainerView.clipsToBounds = true
        fromSnapshotViewContainerView.frame = components.presentedFrame
        fromSnapshotViewContainerView.layer.cornerCurve = presentedViewController.cornerCurve
        fromSnapshotViewContainerView.layer.cornerRadius = presentedViewController.cornerRadius
        
        // Scale up the snapshot of the presenting view controller to make it look like the presented view controller is being
        // zoomed out during the animation
        components.toSnapshotView.alpha = 0
        let toSnapshotViewScaleTransform = CGAffineTransform(scaleX: components.toSnapshotViewScaleFactorX, y: components.toSnapshotViewScaleFactorY)
        components.toSnapshotView.frame = components.toSnapshotView.frame.applying(toSnapshotViewScaleTransform)
        let scaledUpImageViewFrame = components.presentingFrame.applying(toSnapshotViewScaleTransform)
        components.toSnapshotView.frame.origin.x -= scaledUpImageViewFrame.origin.x
        components.toSnapshotView.frame.origin.y -= scaledUpImageViewFrame.origin.y
        
        
        // The view of the presented view controller and both snapshots must be added to
        // the `transitionContext.containerView` view for the animation to properly take
        // place
        [components.fromViewController.view,
         components.toSnapshotView,
         fromSnapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        [components.fromViewController, components.toViewController].forEach {
            $0.view.isHidden = true
        }

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            fromSnapshotViewContainerView.frame = components.presentingFrame
            fromSnapshotViewContainerView.layer.cornerRadius = self.presentingViewController.cornerRadius

            components.toSnapshotView.alpha = 1
            components.toSnapshotView.frame = transitionContext.finalFrame(for: components.toViewController)
        } completion: { _ in
            [components.fromViewController, components.toViewController].forEach {
                $0.view.isHidden = false
            }
            [fromSnapshotViewContainerView, components.toSnapshotView].forEach {
                $0.removeFromSuperview()
            }
            self.completeTransition(transitionContext, success: !transitionContext.transitionWasCancelled)
        }
    }
    
    func animateWithViewSnapshot(
        using transitionContext: UIViewControllerContextTransitioning,
        components: TransitionComponents
    ) {
        
        // Create a view to mask the snapshot of the presented view controller so that it will
        // look like the selected cell from the presenting view controller at the end of the
        // animation
        let initialFrame = transitionContext.initialFrame(for: components.fromViewController)
        let fromSnapshotViewContainerView = UIView()
        fromSnapshotViewContainerView.clipsToBounds = true
        fromSnapshotViewContainerView.frame = initialFrame
        fromSnapshotViewContainerView.layer.cornerCurve = presentedViewController.cornerCurve
        fromSnapshotViewContainerView.layer.cornerRadius = presentedViewController.cornerRadius
        fromSnapshotViewContainerView.addSubview(components.fromSnapshotView)

        // Scale up the snapshot of the presenting view controller to make it look like the presented view controller is being
        // zoomed out during the animation
        components.toSnapshotView.alpha = 0
        let toSnapshotViewScaleTransform = CGAffineTransform(scaleX: components.toSnapshotViewScaleFactorX, y: components.toSnapshotViewScaleFactorY)
        components.toSnapshotView.frame = components.toSnapshotView.frame.applying(toSnapshotViewScaleTransform)
        let scaledUpImageViewFrame = components.presentingFrame.applying(toSnapshotViewScaleTransform)
        components.toSnapshotView.frame.origin.x -= scaledUpImageViewFrame.origin.x
        components.toSnapshotView.frame.origin.y -= scaledUpImageViewFrame.origin.y

        // The view of the presented view controller and both snapshots must be added to
        // the `transitionContext.containerView` view for the animation to properly take
        // place
        [components.fromViewController.view,
         components.toSnapshotView,
         fromSnapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        [components.fromViewController, components.toViewController].forEach {
            $0.view.isHidden = true
        }

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            // Set the frame of the presented view controller's snapshot so that the position and size of its image view will be the
            // same as those of the presenting view controller's image view
            let fromSnapshotViewScaleFactorX = 1 / components.toSnapshotViewScaleFactorX
            let fromSnapshotViewScaleFactorY = 1 / components.toSnapshotViewScaleFactorY
            let fromSnapshotViewScaleTransform = CGAffineTransform(scaleX: fromSnapshotViewScaleFactorX, y: fromSnapshotViewScaleFactorY)
            components.fromSnapshotView.frame = initialFrame.applying(fromSnapshotViewScaleTransform)
            components.fromSnapshotView.frame.origin.x -= components.presentedFrame.applying(fromSnapshotViewScaleTransform).origin.x
            components.fromSnapshotView.frame.origin.y -= components.presentedFrame.applying(fromSnapshotViewScaleTransform).origin.y
            fromSnapshotViewContainerView.frame = components.presentingFrame
            fromSnapshotViewContainerView.layer.cornerRadius = self.presentingViewController.cornerRadius

            components.toSnapshotView.alpha = 1
            components.toSnapshotView.frame = transitionContext.finalFrame(for: components.toViewController)
        } completion: { _ in
            [components.fromViewController, components.toViewController].forEach {
                $0.view.isHidden = false
            }
            [fromSnapshotViewContainerView, components.toSnapshotView].forEach {
                $0.removeFromSuperview()
            }
            self.completeTransition(transitionContext, success: !transitionContext.transitionWasCancelled)
        }
    }
}
