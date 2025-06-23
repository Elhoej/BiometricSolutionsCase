//
//  PhotoResultView.swift
//  BiometricSolutionsCase
//
//  Created by Simon Elhøj Steinmejer on 23/06/2025.
//

import SwiftUI

/// View displaying the captured photo with hair mask overlay
struct PhotoResultView: View {
    let photo: CapturedPhoto
    let onDismiss: () -> Void
    
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
                            Image(uiImage: photo.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
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
