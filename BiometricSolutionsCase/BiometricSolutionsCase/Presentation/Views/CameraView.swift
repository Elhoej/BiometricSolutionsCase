//
//  ContentView.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import SwiftUI

/// Main camera view
struct CameraView: View {
    @StateObject private var viewModel: CameraViewModel
    let cameraService: CameraService
    
    init(viewModel: CameraViewModel, cameraService: CameraService) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.cameraService = cameraService
    }
    
    var body: some View {
        ZStack {
            // Camera preview or permission request view
            if viewModel.cameraPermissionStatus == .authorized {
                CameraPreviewView(cameraService: cameraService)
                    .ignoresSafeArea()
            } else {
                PermissionRequestView {
                    await viewModel.requestCameraPermission()
                }
            }
            
            // Camera controls overlay
            if viewModel.cameraPermissionStatus == .authorized {
                VStack {
                    Spacer()
                    
                    // Capture button
                    Button(action: {
                        Task {
                            await viewModel.capturePhoto()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 80, height: 80)
                        }
                    }
                    .disabled(viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.5 : 1.0)
                    .padding(.bottom, 50)
                }
            }
            
            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            
                            Text("Processing...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    )
            }
        }
        .task {
            await viewModel.initializeCamera()
        }
        .onDisappear {
            Task {
                await viewModel.stopCamera()
            }
        }
        .sheet(isPresented: $viewModel.showingResult) {
            if let photo = viewModel.capturedPhoto {
                PhotoResultView(
                    photo: photo,
                    onDismiss: viewModel.dismissResult
                )
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}
