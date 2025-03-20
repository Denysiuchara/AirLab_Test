//
//  ContentView.swift
//  Test_AirLab
//
//  Created by Danya Denisiuk on 20.03.2025.
//

import SwiftUI
import AVFoundation

struct VideoConferenceView: View {
    @StateObject private var viewModel: VideoConferenceViewModel = VideoConferenceViewModel()
    
    private let startDate: Date = Date()
    
    var body: some View {
        VStack {
            Picker("Select Camera", selection: $viewModel.selectedDevice) {
                ForEach(viewModel.availableDevices, id: \.uniqueID) { device in
                    Text(device.localizedName)
                        .tag(device as AVCaptureDevice?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            if viewModel.showCameraAndFilterPicker {
                Picker("Select Filter", selection: $viewModel.selectedFilter) {
                    ForEach(FilterType.allCases, id: \.self) { filter in
                        Text(filter.rawValue)
                            .tag(filter)
                    }
                }
                .transition(.opacity)
            }
            
            if let image = viewModel.filteredImage,
               viewModel.showCameraAndFilterPicker {
                ZStack(alignment: .bottomTrailing) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                    
                    if viewModel.startСonference {
                        VoiceImitationView()
                            .padding(10)
                    }
                }
            } else {
                Text("There is no video")
                    .shadow(color: .black, radius: 3)
                    .frame(width: 300, height: 300)
                    .background {
                        TimelineView(.animation) { context in
                            Rectangle()
                                .colorEffect(
                                    ShaderLibrary.noise(.float(startDate.timeIntervalSinceNow))
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            }
            
            HStack {
                Button("Start", action: viewModel.startSession)
                
                Button("Stop", action: viewModel.stopSession)
            }
        }
        .padding(20)
    }
}

fileprivate struct VoiceImitationView: View {
    @State private var heights: [CGFloat] = [10, 15, 20]
    @State private var timer: Timer?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(heights.indices, id: \.self) { index in
                VoiceCell(heights[index])
            }
        }
        .frame(width: 35, height: 35)
        .background {
            Circle()
                .fill(.blue)
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    @ViewBuilder
    func VoiceCell(_ height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(.white)
            .frame(width: 5, height: height)
            .frame(maxHeight: 25, alignment: .center)
    }
    
    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                heights = heights.map { _ in .random(in: 5...25) }
            }
        }
    }
}

#Preview {
    VideoConferenceView()
}
