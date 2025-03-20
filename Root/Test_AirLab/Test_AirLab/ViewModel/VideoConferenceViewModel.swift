//
//  VideoConferenceViewModel.swift
//  Test_AirLab
//
//  Created by Danya Denisiuk on 20.03.2025.
//

import Foundation
import AVFoundation
import AppKit
import Combine
import SwiftUI

final class VideoConferenceViewModel: ObservableObject {
    // DI to CameraManager and VideoCapture
    @Published private var cameraManager: CameraManager = CameraManager()
    @Published private var videoCapture: VideoCapture = VideoCapture()
    
    @Published private(set) var availableDevices: [AVCaptureDevice] = []
    @Published private(set) var filteredImage: NSImage?
    @Published private(set) var showCameraAndFilterPicker: Bool = false
    
    /// Флаг для иммитации начала конференции
    @Published private(set) var startСonference: Bool = false
    @Published var selectedFilter: FilterType = .none
    @Published var selectedDevice: AVCaptureDevice? {
        didSet {
            if let device = selectedDevice {
                videoCapture.startSession(device: device)
                withAnimation {
                    showCameraAndFilterPicker = true
                }
            } else {
                videoCapture.stopSession()
                withAnimation {
                    showCameraAndFilterPicker = false
                }
            }
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        cameraManager.$availableDevices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] devices in
                self?.availableDevices = devices
            }
            .store(in: &cancellables)
        
        videoCapture.$filteredImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filteredImage in
                self?.filteredImage = filteredImage
            }
            .store(in: &cancellables)
        
        // Делаем двухстороннюю связь
        $selectedFilter
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filter in
                self?.videoCapture.selectedFilter = filter
            }
            .store(in: &cancellables)
    }
    
    func startSession() {
        if let device = selectedDevice {
            videoCapture.startSession(device: device)
            withAnimation {
                startСonference = true
            }
        }
    }
    
    func stopSession() {
        videoCapture.stopSession()
        withAnimation {
            startСonference = false
            showCameraAndFilterPicker = false
            selectedDevice = nil
            filteredImage = nil
        }
    }
}
