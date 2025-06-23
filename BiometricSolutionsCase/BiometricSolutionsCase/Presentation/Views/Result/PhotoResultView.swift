//
//  PhotoResultView.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import SwiftUI

/// View displaying the captured photo with hair mask overlay
struct PhotoResultView: View {
    let analyzedPhoto: AnalyzedPhoto
    let onDismiss: () -> Void
    
    @State private var showMask = true
    @State private var maskOpacity: Double = 0.8
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Photo with mask overlay
                    GeometryReader { geometry in
                        ZStack {
                            // Original photo
                            Image(uiImage: analyzedPhoto.originalPhoto.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                            
                            // Hair mask overlay
                            if showMask {
                                Image(uiImage: analyzedPhoto.hairMask.maskImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                                    .blendMode(.screen)
                                    .opacity(maskOpacity)
                                    .colorMultiply(.cyan)
                            }
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                    
                    // Controls
                    VStack(spacing: 20) {
                        // Mask toggle
                        Toggle("Show Hair Mask", isOn: $showMask)
                            .toggleStyle(SwitchToggleStyle(tint: .cyan))
                            .padding(.horizontal)
                        
                        // Opacity slider
                        if showMask {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mask Opacity")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "circle.lefthalf.fill")
                                        .foregroundColor(.gray)
                                    
                                    Slider(value: $maskOpacity, in: 0...1)
                                        .accentColor(.cyan)
                                    
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Eye detection results
                        if let eyeDetection = analyzedPhoto.eyeDetectionResult {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Eye Detection")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Image(systemName: eyeDetection.status == .bothEyesDetected ? "eye.fill" :
                                                     eyeDetection.status == .oneEyeDetected ? "eye.slash" : "eye.slash.fill")
                                        .foregroundColor(eyeDetection.status == .bothEyesDetected ? .green : .orange)
                                    
                                    Text(eyeDetection.statusMessage)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                                
                                if let distance = eyeDetection.formattedDistance {
                                    HStack {
                                        Image(systemName: "ruler")
                                            .foregroundColor(.cyan)
                                        Text("Eye distance: \(distance)")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    .background(Color.black.opacity(0.8))
                }
            }
            .navigationTitle("Analyzed Photo Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
    }
}
