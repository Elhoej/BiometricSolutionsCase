//
//  HairMask.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import UIKit

/// Represents a hair mask extracted from a photo
struct HairMask: Identifiable {
    let id: UUID
    let originalPhoto: CapturedPhoto
    let maskImage: UIImage
    let processedAt: Date
    
    init(
        id: UUID = UUID(),
        originalPhoto: CapturedPhoto,
        maskImage: UIImage,
        processedAt: Date = Date()
    ) {
        self.id = id
        self.originalPhoto = originalPhoto
        self.maskImage = maskImage
        self.processedAt = processedAt
    }
}
