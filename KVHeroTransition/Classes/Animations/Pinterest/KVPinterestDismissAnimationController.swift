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
        let completion: (Bool) -> Void = { transitionDidComplete in
            transitionContext.completeTransition(transitionDidComplete)
            [self.presentingViewController,
             self.presentedViewController].forEach {
                $0.animationDidEnd(transitionType: transitionDidComplete ? .dismiss : .present)
            }
        }

        [presentingViewController, presentedViewController].forEach {
            $0.animationWillStart(transitionType: .dismiss)
        }

        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let toViewController = transitionContext.viewController(forKey: .to),
              let fromSnapshotView = fromViewController.view.snapshotView(afterScreenUpdates: true),
              let toSnapshotView = toViewController.view.snapshotView(afterScreenUpdates: true),
              let presentingViewControllerImageViewFrame = presentingViewController.imageViewFrame,
              let presentedViewControllerImageViewFrame = presentedViewController.imageViewFrame
        else {
            completion(false)
            return
        }

        // Create a view to mask the snapshot of the presented view controller so that it will
        // look like the selected cell from the presenting view controller at the end of the
        // animation
        let initialFrame = transitionContext.initialFrame(for: fromViewController)
        let fromSnapshotViewContainerView = UIView()
        fromSnapshotViewContainerView.clipsToBounds = true
        fromSnapshotViewContainerView.frame = initialFrame
        fromSnapshotViewContainerView.layer.cornerCurve = presentedViewController.cornerCurve
        fromSnapshotViewContainerView.layer.cornerRadius = presentedViewController.cornerRadius
        fromSnapshotViewContainerView.addSubview(fromSnapshotView)

        // Scale up the snapshot of the presenting view controller to make it look like the presented view controller is being
        // zoomed out during the animation
        toSnapshotView.alpha = 0
        let toSnapshotViewScaleFactor = presentedViewControllerImageViewFrame.width / presentingViewControllerImageViewFrame.width
        let toSnapshotViewScaleTransform = CGAffineTransform(scaleX: toSnapshotViewScaleFactor, y: toSnapshotViewScaleFactor)
        toSnapshotView.frame = toSnapshotView.frame.applying(toSnapshotViewScaleTransform)
        let scaledUpImageViewFrame = presentingViewControllerImageViewFrame.applying(toSnapshotViewScaleTransform)
        toSnapshotView.frame.origin.x -= scaledUpImageViewFrame.origin.x
        toSnapshotView.frame.origin.y -= scaledUpImageViewFrame.origin.y

        // The view of the presented view controller and both snapshots must be added to
        // the `transitionContext.containerView` view for the animation to properly take
        // place
        [fromViewController.view,
         toSnapshotView,
         fromSnapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
        [fromViewController, toViewController].forEach {
            $0.view.isHidden = true
        }

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseInOut
        ) {
            // Set the frame of the presented view controller's snapshot so that the position and size of its image view will be the
            // same as those of the presenting view controller's image view
            let fromSnapshotViewScaleFactor = 1 / toSnapshotViewScaleFactor
            let fromSnapshotViewScaleTransform = CGAffineTransform(scaleX: fromSnapshotViewScaleFactor, y: fromSnapshotViewScaleFactor)
            fromSnapshotView.frame = initialFrame.applying(fromSnapshotViewScaleTransform)
            fromSnapshotView.frame.origin.y -= presentedViewControllerImageViewFrame.applying(fromSnapshotViewScaleTransform).origin.y
            fromSnapshotViewContainerView.frame = presentingViewControllerImageViewFrame
            fromSnapshotViewContainerView.layer.cornerRadius = self.presentingViewController.cornerRadius

            toSnapshotView.alpha = 1
            toSnapshotView.frame = transitionContext.finalFrame(for: toViewController)
        } completion: { _ in
            [fromViewController, toViewController].forEach {
                $0.view.isHidden = false
            }
            [fromSnapshotViewContainerView, toSnapshotView].forEach {
                $0.removeFromSuperview()
            }
            completion(!transitionContext.transitionWasCancelled)
        }
    }
    // swiftlint:enable function_body_length line_length
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
        return TransitionComponents(
            fromViewController: fromViewController,
            toViewController: toViewController,
            fromSnapshotView: fromSnapshotView,
            toSnapshotView: toSnapshotView,
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
