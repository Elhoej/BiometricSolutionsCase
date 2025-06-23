//
//  HairMask.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import UIKit

/// Represents a hair mask extracted from a photo
struct AnalyzedPhoto: Identifiable {
    let id: UUID
    let originalPhoto: CapturedPhoto
    let hairMask: HairMask
    let processedAt: Date
    let eyeDetectionResult: EyeDetectionResult?
    
    init(
        id: UUID = UUID(),
        originalPhoto: CapturedPhoto,
        hairMask: HairMask,
        processedAt: Date = Date(),
        eyeDetectionResult: EyeDetectionResult? = nil
    ) {
        self.id = id
        self.originalPhoto = originalPhoto
        self.hairMask = hairMask
        self.processedAt = processedAt
        self.eyeDetectionResult = eyeDetectionResult
    }
}
