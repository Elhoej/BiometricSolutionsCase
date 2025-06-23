//
//  BiometricSolutionsCaseApp.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import SwiftUI

@main
struct BiometricSolutionsCaseApp: App {
    
    private let container = DependencyContainer.shared
    
    var body: some Scene {
        WindowGroup {
            CameraView(
                viewModel: container.makeCameraViewModel(),
                cameraService: container.cameraService
            )
            .preferredColorScheme(.dark)
        }
    }
}
