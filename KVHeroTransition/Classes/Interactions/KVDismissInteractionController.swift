//
//  KVDismissInteractionController.swift
//  KVHeroTransition
//
//  Created by Khanh Vu on 2/6/25.
//
import UIKit

final class KVDismissInteractionController: UIPercentDrivenInteractiveTransition,
                                          KVInteractionControllerProtocol {

    // MARK: Properties

    private weak var viewController: KVTransitionAnimatable?
    private var panGesture: UIPanGestureRecognizer?

    private(set) var isInProgress = false
    private var shouldFinishTransition = false
    
    // Animation state
    private var originalCenter: CGPoint = .zero
    private var originalTransform: CGAffineTransform = .identity
    
    // Configuration
        private let minScale: CGFloat = 0.8
        private let maxDragDistance: CGFloat = 300
        private let velocityThreshold: CGFloat = 1000
        private let animationDuration: TimeInterval = 0.25
        private let dismissThreshold: CGFloat = 0.3
    
    // MARK: Initialization

    init(viewController: KVTransitionAnimatable) {
        super.init()

        self.viewController = viewController
        setUp()
    }
    
    deinit {
        cleanUp()
    }
}

// MARK: - KVInteractionControllerProtocol

extension KVDismissInteractionController {
    
    var completionThreshold: CGFloat {
        return dismissThreshold
    }
    
    func configureInteraction() {
        completionCurve = .easeOut
        completionSpeed = 1.0
    }
}

// MARK: - Private extension

private extension KVDismissInteractionController {
    
    // MARK: Methods
    
    func setUp() {
        setUpGestureRecognizer()
        configureInteraction()
        saveOriginalState()
    }
    
    func setUpGestureRecognizer() {
        guard let view = viewController?.view else { return }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        panGesture.delegate = self
        
        view.addGestureRecognizer(panGesture)
        self.panGesture = panGesture
    }
    
    func saveOriginalState() {
        guard let interactionView = viewController?.interactionViewForDismiss() else { return }
        originalCenter = interactionView.center
        originalTransform = interactionView.transform
    }
    
    func cleanUp() {
        if let gesture = panGesture {
            viewController?.view.removeGestureRecognizer(gesture)
        }
        panGesture = nil
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let viewController = viewController else { return }
        
        if let interactionView = viewController.interactionViewForDismiss() {
            handleInteractiveGesture(gestureRecognizer, interactionView: interactionView)
        } else {
            handleStandardDismissGesture(gestureRecognizer)
        }
    }
    
    func handleInteractiveGesture(_ gesture: UIPanGestureRecognizer, interactionView: UIView) {
        let translation = gesture.translation(in: gesture.view?.superview)
        let velocity = gesture.velocity(in: gesture.view?.superview)
        
        switch gesture.state {
        case .began:
            beginInteraction()
            
        case .changed:
            updateInteractiveTransition(translation: translation, interactionView: interactionView)
            updateShouldFinish(velocity: velocity, translation: translation)
            
        case .ended:
            endInteraction()
            
        case .cancelled, .failed:
            cancelInteraction(interactionView: interactionView)
            
        default:
            break
        }
    }
    
    func handleStandardDismissGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = viewController?.view else { return }
        
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        let percentComplete = calculatePercentComplete(translation: translation)
        
        switch gesture.state {
        case .began:
            beginStandardDismiss()
            
        case .changed:
            updateStandardDismiss(percentComplete: percentComplete, velocity: velocity)
            
        case .ended:
            endStandardDismiss()
            
        case .cancelled, .failed:
            cancelStandardDismiss()
            
        default:
            break
        }
    }
    
    // MARK: - Interactive Transition Methods
    
    func beginInteraction() {
        isInProgress = true
        shouldFinishTransition = false
        saveOriginalState()
        viewController?.interactDismiss(state: .began)
    }
    
    func updateInteractiveTransition(translation: CGPoint, interactionView: UIView) {
        viewController?.interactDismiss(state: .changed)
        
        // Update position
        let newCenter = CGPoint(
            x: originalCenter.x + translation.x,
            y: originalCenter.y + translation.y
        )
        interactionView.center = newCenter
        
        // Update scale based on distance
        let distance = sqrt(translation.x * translation.x + translation.y * translation.y)
        let scale = calculateScale(for: distance)
        interactionView.transform = originalTransform.scaledBy(x: scale, y: scale)
    }
    
    func updateShouldFinish(velocity: CGPoint, translation: CGPoint) {
        let velocityMagnitude = sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
        let distance = sqrt(translation.x * translation.x + translation.y * translation.y)
        
        shouldFinishTransition = velocityMagnitude > velocityThreshold ||
        distance > maxDragDistance * dismissThreshold
    }
    
    func endInteraction() {
        isInProgress = false
        
        if shouldFinishTransition {
            viewController?.interactDismiss(state: .ended)
            finishDismiss()
        } else {
            viewController?.interactDismiss(state: .cancelled)
            cancelInteraction(interactionView: viewController?.interactionViewForDismiss())
        }
    }
    
    func cancelInteraction(interactionView: UIView?) {
        guard let interactionView = interactionView else { return }
        
        isInProgress = false
        viewController?.interactDismiss(state: .cancelled)
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                interactionView.center = self.originalCenter
                interactionView.transform = self.originalTransform
            }
        )
    }
    
    func finishDismiss() {
        viewController?.dismiss(animated: true)
        finish()
    }
    
    
    // MARK: - Standard Dismiss Methods
    
    func beginStandardDismiss() {
        isInProgress = true
        viewController?.interactDismiss(state: .began)
        viewController?.dismiss(animated: true)
    }
    
    func updateStandardDismiss(percentComplete: CGFloat, velocity: CGPoint) {
        viewController?.interactDismiss(state: .changed)
        shouldFinishTransition = percentComplete > completionThreshold ||
        abs(velocity.y) > velocityThreshold
        update(percentComplete)
    }
    
    func endStandardDismiss() {
        isInProgress = false
        
        if shouldFinishTransition {
            viewController?.interactDismiss(state: .ended)
            finish()
        } else {
            viewController?.interactDismiss(state: .cancelled)
            cancel()
        }
    }
    
    func cancelStandardDismiss() {
        isInProgress = false
        viewController?.interactDismiss(state: .cancelled)
        cancel()
    }
    
    // MARK: - Helper Methods
    
    func calculateScale(for distance: CGFloat) -> CGFloat {
        let normalizedDistance = min(distance / maxDragDistance, 1.0)
        return max(minScale, 1.0 - normalizedDistance * (1.0 - minScale))
    }
    
    func calculatePercentComplete(translation: CGPoint) -> CGFloat {
        let dragDistance = abs(translation.y)
        return min(max(0, dragDistance / 200), 1)
    }
    
    func findScrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        for subview in view.subviews.reversed() {
            if let found = findScrollView(in: subview) {
                return found
            }
        }
        return nil
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
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer,
              let view = viewController?.view else {
            return true
        }
        
        let velocity = panGesture.velocity(in: view)
        
        // Make sure current media isn't zoomed in
        if viewController?.enableInteractionDismiss == false {
            return false
        }
        
        // Get scrollView → Check offset
        if let scrollView = findScrollView(in: view) {
            let isAtTop = scrollView.contentOffset.y <= 0
            let isDraggingDown = velocity.y > 0
            return isAtTop && isDraggingDown
        }
        
        // if scrollView empty, default check
        return velocity.y > abs(velocity.x)
    }
}
