//
//  CapturedPhoto.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import UIKit

/// Represents a photo captured by the camera
struct CapturedPhoto: Identifiable {
    let id: UUID
    let image: UIImage
    let capturedAt: Date
    
    init(id: UUID = UUID(), image: UIImage, capturedAt: Date = Date()) {
        self.id = id
        self.image = image
        self.capturedAt = capturedAt
    }
}
