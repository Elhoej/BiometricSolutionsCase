//
//  PermissionManager.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import Foundation
import AVFoundation

/// Manages app permissions
@MainActor
final class PermissionManager: ObservableObject {
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    
    init() {
        Task {
            await checkCameraPermission()
        }
    }
    
    /// Checks the current camera permission status
    func checkCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraPermissionStatus = status
    }
    
    /// Requests camera permission from the user
    func requestCameraPermission() async -> Bool {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        await checkCameraPermission()
        return granted
    }
    
    /// Whether camera permission has been granted
    var isCameraAuthorized: Bool {
        cameraPermissionStatus == .authorized
    }
    
    /// Whether camera permission has been denied
    var isCameraDenied: Bool {
        cameraPermissionStatus == .denied || cameraPermissionStatus == .restricted
    }
}
