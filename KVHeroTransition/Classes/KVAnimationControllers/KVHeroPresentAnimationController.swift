//
//  InstagramPresentAnimationController.swift
//  UICollectionViewTransitions
//
//  Created by Khanh Vu on 2/6/25.
//

import UIKit

final class KVHeroPresentAnimationController: NSObject {

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

extension KVHeroPresentAnimationController: UIViewControllerAnimatedTransitioning {

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
                $0.animationDidEnd(transitionType: transitionDidComplete ? .present : .dismiss)
            }
        }

        [presentingViewController, presentedViewController].forEach {
            $0.animationWillStart(transitionType: .present)
        }

        guard let toViewController = transitionContext.viewController(forKey: .to),
              let snapshotView = toViewController.view.snapshotView(afterScreenUpdates: true),
              let presentingViewControllerImageViewFrame = presentingViewController.imageViewFrame,
              let presentedViewControllerImageViewFrame = presentedViewController.imageViewFrame
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        if let heroImage = presentingViewController.heroImage() {
            let snapshotViewContainerView = UIImageView()
            snapshotViewContainerView.contentMode = .scaleAspectFill
            snapshotViewContainerView.image = presentingViewController.heroImage()
            snapshotViewContainerView.clipsToBounds = true
            snapshotViewContainerView.frame = presentingViewControllerImageViewFrame
            snapshotViewContainerView.layer.cornerCurve = presentingViewController.cornerCurve
            snapshotViewContainerView.layer.cornerRadius = presentingViewController.cornerRadius
            
            [toViewController.view,
             snapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
            toViewController.view.isHidden = true
            transitionContext.containerView.layoutIfNeeded()
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                options: .curveEaseInOut
            ) {
                snapshotViewContainerView.layer.cornerRadius = self.presentedViewController.cornerRadius
                snapshotViewContainerView.frame = presentedViewControllerImageViewFrame

            } completion: { _ in
                toViewController.view.isHidden = false
                snapshotViewContainerView.removeFromSuperview()
                completion(!transitionContext.transitionWasCancelled)
            }
        } else {
            // Set the frame of the presented view controller's snapshot so that the position and size of its image view
            // are the same as those of the presenting view controller's image view
            let finalFrame = transitionContext.finalFrame(for: toViewController)
            let scaleFactorX = presentingViewControllerImageViewFrame.width / presentedViewControllerImageViewFrame.width
            let scaleFactorY = presentingViewControllerImageViewFrame.height / presentedViewControllerImageViewFrame.height

            let scaleTransform = CGAffineTransform(scaleX: scaleFactorX, y: scaleFactorY)
            snapshotView.frame = finalFrame.applying(scaleTransform)
            snapshotView.frame.origin.y -= presentedViewControllerImageViewFrame.applying(scaleTransform).origin.y
            snapshotView.frame.origin.x -= presentedViewControllerImageViewFrame.applying(scaleTransform).origin.x

    //         Create a view to mask the snapshot of the presented view controller so that it
    //         looks like the selected cell from the presenting view controller
            let snapshotViewContainerView = UIView()
            snapshotViewContainerView.clipsToBounds = true
            snapshotViewContainerView.frame = presentingViewControllerImageViewFrame
            snapshotViewContainerView.layer.cornerCurve = presentingViewController.cornerCurve
            snapshotViewContainerView.layer.cornerRadius = presentingViewController.cornerRadius
            snapshotViewContainerView.addSubview(snapshotView)
            
            

            // Both the view of the presented view controller and its snapshot must be
            // added to the `transitionContext.containerView` view for the animation to
            // properly take place
            [toViewController.view,
             snapshotViewContainerView].forEach(transitionContext.containerView.addSubview)
            toViewController.view.isHidden = true
            transitionContext.containerView.layoutIfNeeded()
            UIView.animate(
                withDuration: transitionDuration(using: transitionContext),
                delay: 0,
                options: .curveEaseInOut
            ) {
                [snapshotView, snapshotViewContainerView].forEach {
                    $0.frame = finalFrame
                }
                snapshotViewContainerView.layer.cornerRadius = self.presentedViewController.cornerRadius

            } completion: { _ in
                toViewController.view.isHidden = false
                snapshotViewContainerView.removeFromSuperview()
                completion(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
