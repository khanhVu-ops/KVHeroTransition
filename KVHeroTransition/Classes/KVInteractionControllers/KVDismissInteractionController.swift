//
//  DismissInteractionController.swift
//  UICollectionViewTransitions
//
//  Created by Khanh Vu on 2/6/25.
//

import UIKit

final class KVDismissInteractionController: UIPercentDrivenInteractiveTransition,
                                          KVInteractionControllerProtocol {

    // MARK: Properties

    private weak var viewController: KVTransitionAnimatable?

    private(set) var isInProgress = false
    private var shouldFinishTransition = false
    private var originalCenter: CGPoint = .zero
        private var originalTransform: CGAffineTransform = .identity
    private let minScale: CGFloat = 0.8

    // MARK: Initialization

    init(viewController: KVTransitionAnimatable) {
        super.init()

        self.viewController = viewController
        setUp()
    }
}

// MARK: - Private extension

private extension KVDismissInteractionController {

    // MARK: Methods

    func setUp() {
        setUpGestureRecognizer()
        configureInteractionProperties()
    }

    func setUpGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGestureRecognizer(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        panGesture.delegate = self
        viewController?.view.addGestureRecognizer(panGesture)
        // Save original state
        originalCenter = viewController?.interactionViewForismiss()?.center ?? .zero
        originalTransform = viewController?.interactionViewForismiss()?.transform ?? .identity
    }

    func configureInteractionProperties() {
        completionCurve = .easeOut
        completionSpeed = 1
    }
    
    @objc func handleGestureRecognizer(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        guard let _ = viewController?.interactionViewForismiss() else {
            handleDragGesture(gestureRecognizer)
            return
        }
        handleGesture(gestureRecognizer)
    }

    @objc
    func handleGesture(
        _ gestureRecognizer: UIScreenEdgePanGestureRecognizer
    ) {
        guard let viewForDismiss = viewController?.interactionViewForismiss() else {
            return
        }
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view?.superview)
        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view?.superview)
        
        switch gestureRecognizer.state {
        case .began:
            isInProgress = true
            viewController?.interactDismiss(state: .began)
            // Save original state
            originalCenter = viewForDismiss.center
            originalTransform = viewForDismiss.transform
            //            viewController?.dismiss(animated: true)
        case .changed:
            viewController?.interactDismiss(state: .changed)
            let newCenter = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y + translation.y)
            viewForDismiss.center = newCenter
            
            // Calculate distance from original point
            let dx = translation.x
            let dy = translation.y
            let distance = sqrt(dx * dx + dy * dy)
            
            // Define max distance for scaling (you can adjust this)
            let maxDistance: CGFloat = 300
            
            // Calculate scale (between 1.0 and 0.8)
            let scale = max(minScale, 1.0 - (distance / maxDistance) * (1.0 - minScale))
            viewForDismiss.transform = originalTransform.scaledBy(x: scale, y: scale)
            
            shouldFinishTransition = abs(velocity.x) > 100 || abs(velocity.y) > 100
        case .cancelled:
            isInProgress = false
            viewController?.interactDismiss(state: .cancelled)
            cancelDrag(viewForDismiss)
        case .ended:
            isInProgress = false
            if shouldFinishTransition {
                viewController?.interactDismiss(state: .ended)
                finishDrag()
            } else {
                viewController?.interactDismiss(state: .cancelled)
                cancelDrag(viewForDismiss)
            }
        default:
            break
        }
        
        // Cancel Drag
        func cancelDrag(_ viewForDismiss: UIView) {
            // Animate back to original position and size
            UIView.animate(withDuration: 0.3) {
                viewForDismiss.center = self.originalCenter
                viewForDismiss.transform = self.originalTransform
            }
        }
        
        // Finish Drag
        func finishDrag() {
            viewController?.dismiss(animated: true)
            finish()
        }
    }
    
    @objc private func handleDragGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = viewController?.view else {
            return
        }
        let translation = gesture.translation(in: view)
        let percentComplete = min(max(0, abs(translation.y) / 200), 1)
        switch gesture.state {
        case .began:
            isInProgress = true
            viewController?.interactDismiss(state: .began)
            viewController?.dismiss(animated: true)
        case .changed:
            viewController?.interactDismiss(state: .changed)
            shouldFinishTransition = percentComplete > 0.5
            update(percentComplete)
        case .ended, .cancelled:
            isInProgress = false
            if shouldFinishTransition {
                viewController?.interactDismiss(state: .ended)
                finish()
            } else {
                viewController?.interactDismiss(state: .cancelled)
                cancel()
            }
        default:
            break
        }
    }
}

// MARK: - Gesture Recognizer Delegate
extension KVDismissInteractionController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow simultaneous gesture recognition with image/video zooming gestures
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: viewController?.view)
            // Only allow simultaneous recognition if primarily vertical movement
            return abs(velocity.y) > abs(velocity.x)
        }
        return false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Only begin if it's a pan gesture with primarily vertical movement
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: viewController?.view)
            
            // Make sure current media isn't zoomed in
            if viewController?.enableInteractionDismiss == false {
                return false
            }
            
            // Only allow vertical dragging
            return abs(velocity.y) > abs(velocity.x)
        }
        return true
    }
}
