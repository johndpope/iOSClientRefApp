//
//  CrispResizingImageProcessor.swift
//  iOSReferenceApp
//
//  Created by Fredrik Sjöberg on 2017-10-14.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher


/// Processor for resizing images. Only CG-based images are supported in macOS.
public struct CrispResizingImageProcessor: ImageProcessor {
    
    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
    public let identifier: String
    
    /// The reference size for resizing operation.
    public let referenceSize: CGSize
    
    /// Target content mode of output image should be.
    /// Default to ContentMode.none
    public let targetContentMode: ContentMode
    
    /// Initialize a `CrispResizingImageProcessor`.
    ///
    /// - Parameters:
    ///   - referenceSize: The reference size for resizing operation.
    ///   - mode: Target content mode of output image should be.
    ///
    /// - Note:
    ///   The instance of `CrispResizingImageProcessor` will follow its `mode` property
    ///   and try to resizing the input images to fit or fill the `referenceSize`.
    ///   That means if you are using a `mode` besides of `.none`, you may get an
    ///   image with its size not be the same as the `referenceSize`.
    ///
    ///   **Example**: With input image size: {100, 200},
    ///   `referenceSize`: {100, 100}, `mode`: `.aspectFit`,
    ///   you will get an output image with size of {50, 100}, which "fit"s
    ///   the `referenceSize`.
    ///
    ///   If you need an output image exactly to be a specified size, append or use
    ///   a `CroppingImageProcessor`.
    public init(referenceSize: CGSize, mode: ContentMode = .none) {
        self.referenceSize = referenceSize
        self.targetContentMode = mode
        
        if mode == .none {
            self.identifier = "com.emp.Kingfisher.ResizeImageProcessor(\(referenceSize))"
        } else {
            self.identifier = "com.emp.Kingfisher.ResizeImageProcessor(\(referenceSize), \(mode))"
        }
    }
    
    /// Process an input `ImageProcessItem` item to an image for this processor.
    ///
    /// - parameter item:    Input item which will be processed by `self`
    /// - parameter options: Options when processing the item.
    ///
    /// - returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
    public func process(item: ImageProcessItem, options: KingfisherOptionsInfo) -> UIImage? {
        switch item {
        case .image(let image):
            return resize(image: image, to: referenceSize, for: targetContentMode)
        case .data(_):
            return (DefaultImageProcessor.default >> self).process(item: item, options: options)
        }
    }
    
    private func resize(image: UIImage?, to size: CGSize, for contentMode: ContentMode) -> UIImage? {
        guard let image = image else { return nil }
        switch contentMode {
        case .aspectFit:
            let newSize = aspectFit(base: image.size, size: size)
            return resize(image: image, newSize: newSize)
        case .aspectFill:
            let newSize = aspectFill(base: image.size, size: size)
            return resize(image: image, newSize: newSize)
        default:
            return resize(image: image, newSize: size)
        }
    }
    
    private func resize(image: UIImage?, newSize: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        guard let imageRef = image.cgImage else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        context?.interpolationQuality = .high
        
        image.draw(in: newRect)
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    private func aspectFit(base: CGSize, size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio(for: base) * size.height)
        let aspectHeight = round(size.width / aspectRatio(for: base))
        
        return aspectWidth > size.width ? CGSize(width: size.width, height: aspectHeight) : CGSize(width: aspectWidth, height: size.height)
    }
    
    private func aspectFill(base: CGSize, size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio(for: base) * size.height)
        let aspectHeight = round(size.width / aspectRatio(for: base))
        
        return aspectWidth < size.width ? CGSize(width: size.width, height: aspectHeight) : CGSize(width: aspectWidth, height: size.height)
    }
    
    private func aspectRatio(for size: CGSize) -> CGFloat {
        return size.height == 0.0 ? 1.0 : size.width / size.height
    }
}

