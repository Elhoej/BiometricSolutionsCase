//
//  CameraServiceProtocol.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import UIKit
import AVFoundation

/// Protocol defining camera service capabilities
protocol CameraServiceProtocol {
    /// Captures a photo from the camera
    func capturePhoto() async throws -> UIImage
    
    /// Sets up the camera session
    func setupCamera() async throws
    
    /// Starts the camera session
    func startSession() async
    
    /// Stops the camera session
    func stopSession() async
    
    /// Sets up the session for depth features
    func configureSessionForDepth()
    
    /// Gets the current authorization status
    func authorizationStatus() -> AVAuthorizationStatus
    
    /// Requests camera permission
    func requestPermission() async -> Bool
}
