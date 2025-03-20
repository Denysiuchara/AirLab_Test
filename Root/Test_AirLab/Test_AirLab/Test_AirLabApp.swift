//
//  Test_AirLabApp.swift
//  Test_AirLab
//
//  Created by Danya Denisiuk on 20.03.2025.
//

import SwiftUI

@main
struct Test_AirLabApp: App {
    var body: some Scene {
        WindowGroup {
            VideoConferenceView()
                .frame(width: 700, height: 450)
                .preferredColorScheme(.dark)
        }
        .windowResizability(.contentSize)
    }
}
