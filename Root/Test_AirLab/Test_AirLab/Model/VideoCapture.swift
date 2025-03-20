//
//  VideoCapture.swift
//  Test_AirLab
//
//  Created by Danya Denisiuk on 20.03.2025.
//

import Foundation
import AVFoundation
import CoreImage
import AppKit

enum FilterType: String, CaseIterable {
    case none = "None"
    case mono = "CIPhotoEffectMono"
    case sepia = "CISepiaTone"
    case noir = "CIPhotoEffectNoir"
    case bloom = "CIBloom"
    case comic = "CIComicEffect"
    case crystallize = "CICrystallize"
    case vignette = "CIVignette"
    
    func apply(to image: CIImage) -> CIImage? {
        guard self != .none else { return image }
        let filter = CIFilter(name: self.rawValue)
            filter?.setValue(image, forKey: kCIInputImageKey)
        
        if self == .sepia {
            filter?.setValue(0.8, forKey: kCIInputIntensityKey)
        }
        
        return filter?.outputImage
    }
}

final class VideoCapture: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var filteredImage: NSImage?
    @Published var selectedFilter: FilterType = .none
    
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let context = CIContext()
    
    func startSession(device: AVCaptureDevice) {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        guard
            let input = try? AVCaptureDeviceInput(device: device)
        else {
            return
        }
        
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.Test_AirLab.VideoQueue"))
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    func stopSession() {
        captureSession.stopRunning()
        filteredImage = nil
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        if let filteredCIImage = selectedFilter.apply(to: ciImage),
           let cgImage = context.createCGImage(filteredCIImage, from: filteredCIImage.extent) {
            DispatchQueue.main.async {
                self.filteredImage = NSImage(
                    cgImage: cgImage,
                    size: NSSize(
                        width: filteredCIImage.extent.width,
                        height: filteredCIImage.extent.height
                    )
                )
            }
        }
    }
}
