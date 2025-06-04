//
//  UIImageView+.swift
//  KVHeroTransition
//
//  Created by Khánh Vũ on 2/6/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit

extension UIImageView {
    var imageContentFrame: CGRect? {
        guard let image = self.image else { return nil }

        let imageViewSize = self.bounds.size
        let imageSize = image.size

        guard imageViewSize.width > 0, imageViewSize.height > 0 else { return nil }

        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height

        var resultSize = CGSize.zero
        var origin = CGPoint.zero

        switch self.contentMode {
        case .scaleAspectFit:
            let scale = min(scaleWidth, scaleHeight)
            resultSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
            origin = CGPoint(
                x: (imageViewSize.width - resultSize.width) / 2.0,
                y: (imageViewSize.height - resultSize.height) / 2.0
            )

        case .scaleAspectFill:
            resultSize = imageViewSize
            origin = .zero

        case .scaleToFill, .redraw:
            resultSize = imageViewSize
            origin = .zero

        case .center:
            resultSize = imageSize
            origin = CGPoint(
                x: (imageViewSize.width - imageSize.width) / 2.0,
                y: (imageViewSize.height - imageSize.height) / 2.0
            )

        case .top:
            resultSize = imageSize
            origin = CGPoint(
                x: (imageViewSize.width - imageSize.width) / 2.0,
                y: 0
            )

        case .bottom:
            resultSize = imageSize
            origin = CGPoint(
                x: (imageViewSize.width - imageSize.width) / 2.0,
                y: imageViewSize.height - imageSize.height
            )

        case .left:
            resultSize = imageSize
            origin = CGPoint(
                x: 0,
                y: (imageViewSize.height - imageSize.height) / 2.0
            )

        case .right:
            resultSize = imageSize
            origin = CGPoint(
                x: imageViewSize.width - imageSize.width,
                y: (imageViewSize.height - imageSize.height) / 2.0
            )

        case .topLeft:
            resultSize = imageSize
            origin = .zero

        case .topRight:
            resultSize = imageSize
            origin = CGPoint(x: imageViewSize.width - imageSize.width, y: 0)

        case .bottomLeft:
            resultSize = imageSize
            origin = CGPoint(x: 0, y: imageViewSize.height - imageSize.height)

        case .bottomRight:
            resultSize = imageSize
            origin = CGPoint(
                x: imageViewSize.width - imageSize.width,
                y: imageViewSize.height - imageSize.height
            )

        @unknown default:
            return nil
        }

        return CGRect(origin: origin, size: resultSize)
    }
}
