//
//  InstagramDismissAnimationController.swift
//  UICollectionViewTransitions
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
              let snapshotView = fromViewController.view.snapshotView(afterScreenUpdates: true),
              let presentingViewControllerImageViewFrame = presentingViewController.imageViewFrame,
              let presentedViewControllerImageViewFrame = presentedViewController.imageViewFrame
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        if let heroImage = presentedViewController.heroImage() {
            let snapshotViewContainerView = UIImageView()
            snapshotViewContainerView.contentMode = .scaleAspectFit
            snapshotViewContainerView.image = heroImage
            snapshotViewContainerView.clipsToBounds = true
            snapshotViewContainerView.frame = presentedViewControllerImageViewFrame
            snapshotViewContainerView.layer.cornerCurve = presentedViewController.cornerCurve
            snapshotViewContainerView.layer.cornerRadius = presentedViewController.cornerRadius
            // Both the view of the presented view controller and its snapshot must be
            // added to the `transitionContext.containerView` view for the animation to
            // properly take place
            [fromViewController.view,
             snapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
            fromViewController.view.isHidden = true

            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                options: .curveEaseInOut
            ) {
                snapshotViewContainerView.frame = presentingViewControllerImageViewFrame
                snapshotViewContainerView.layer.cornerRadius = self.presentingViewController.cornerRadius
                snapshotViewContainerView.contentMode = .scaleAspectFill
            } completion: { _ in
                fromViewController.view.isHidden = false
                snapshotViewContainerView.removeFromSuperview()
                completion(!transitionContext.transitionWasCancelled)
            }
        } else {
            // Create a view to mask the snapshot of the presented view controller so that it
            // will look like the selected cell from the presenting view controller at the end
            // of the animation
            let initialFrame = transitionContext.initialFrame(for: fromViewController)
            let snapshotViewContainerView = UIView()
            snapshotViewContainerView.clipsToBounds = true
            snapshotViewContainerView.frame = initialFrame
            snapshotViewContainerView.layer.cornerCurve = presentedViewController.cornerCurve
            snapshotViewContainerView.layer.cornerRadius = presentedViewController.cornerRadius
            snapshotViewContainerView.addSubview(snapshotView)
            
            // Both the view of the presented view controller and its snapshot must be
            // added to the `transitionContext.containerView` view for the animation to
            // properly take place
            [fromViewController.view,
             snapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
            fromViewController.view.isHidden = true

            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                options: .curveEaseInOut
            ) {
                // Set the frame of the presented view controller's snapshot so that the position and size of its image view
                // will be the same as those of the presenting view controller's image view
                let scaleFactorX = presentingViewControllerImageViewFrame.width / presentedViewControllerImageViewFrame.width
                let scaleFactorY = presentingViewControllerImageViewFrame.height / presentedViewControllerImageViewFrame.height
                let scaleTransform = CGAffineTransform(scaleX: scaleFactorX.isNaN ? 1 : scaleFactorX, y: scaleFactorY.isNaN ? 1 : scaleFactorY)
                snapshotView.frame = initialFrame.applying(scaleTransform)
                snapshotView.frame.origin.y -= presentedViewControllerImageViewFrame.applying(scaleTransform).origin.y
                snapshotView.frame.origin.x -= presentedViewControllerImageViewFrame.applying(scaleTransform).origin.x

                snapshotViewContainerView.frame = presentingViewControllerImageViewFrame
                snapshotViewContainerView.layer.cornerRadius = self.presentingViewController.cornerRadius
            } completion: { _ in
                fromViewController.view.isHidden = false
                snapshotViewContainerView.removeFromSuperview()
                completion(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
