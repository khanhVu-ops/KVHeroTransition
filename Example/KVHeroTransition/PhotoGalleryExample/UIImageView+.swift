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

        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height

        // Chọn tỉ lệ nhỏ hơn để giữ nguyên tỷ lệ khung hình
        let scale = min(scaleWidth, scaleHeight)

        // Tính lại kích thước ảnh sau khi scale
        let displaySize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)

        // Tính origin (canh giữa ảnh trong imageView)
        let imageOrigin = CGPoint(
            x: (imageViewSize.width - displaySize.width) / 2.0,
            y: (imageViewSize.height - displaySize.height) / 2.0
        )

        return CGRect(origin: imageOrigin, size: displaySize)
    }
}
