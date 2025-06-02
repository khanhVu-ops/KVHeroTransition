//
//  KVInteractionControllerProtocol.swift
//  KVHeroTransition
//
//  Created by Khanh Vu on 2/6/25.
//

import UIKit

protocol KVInteractionControllerProtocol: UIPercentDrivenInteractiveTransition {
    
    // MARK: Properties
    /// Whether the interaction is currently in progress
    var isInProgress: Bool { get }
    
    /// The minimum threshold for completing the transition
    var completionThreshold: CGFloat { get }
    
    /// Configure interaction parameters
    func configureInteraction()
}

extension KVInteractionControllerProtocol {
    
    var completionThreshold: CGFloat {
        return 0.5
    }
    
    func configureInteraction() {
        completionCurve = .easeOut
        completionSpeed = 1.0
    }
}
