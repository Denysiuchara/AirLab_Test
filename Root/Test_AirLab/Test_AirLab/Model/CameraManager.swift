//
//  CameraManager.swift
//  Test_AirLab
//
//  Created by Danya Denisiuk on 20.03.2025.
//

import Foundation
import AVFoundation

final class CameraManager: ObservableObject {
    @Published var availableDevices: [AVCaptureDevice] = []
    
    init() {
        fetchAvailableDevices()
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    private func fetchAvailableDevices() {
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .external],
            mediaType: .video,
            position: .unspecified
        )
        availableDevices = session.devices
    }
    
    // MARK: Setup NotificationCenter
    private func addObservers() {
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(deviceConnected),
                name: AVCaptureDevice.wasConnectedNotification,
                object: nil
            )
        
        NotificationCenter.default
            .addObserver(
                self,
                selector: #selector(devicesDissconnected),
                name: AVCaptureDevice.wasDisconnectedNotification,
                object: nil
            )
    }
    
    @objc
    private func deviceConnected() {
        fetchAvailableDevices()
    }
    
    @objc
    private func devicesDissconnected() {
        fetchAvailableDevices()
    }
    
    private func removeObservers() {
        NotificationCenter.default
            .removeObserver(
                self,
                name: AVCaptureDevice.wasConnectedNotification,
                object: nil
            )
        
        NotificationCenter.default
            .removeObserver(
                self,
                name: AVCaptureDevice.wasDisconnectedNotification,
                object: nil
            )
    }
}
