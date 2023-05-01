//
//  Vector_Phase_PlotterApp.swift
//  Shared
//
//  Created by Alexandru Ariton on 17.06.2021.
//

import SwiftUI

@main
struct Vector_Phase_PlotterApp: App {
    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
                .toolbar(content: {
                    Text("")
                })
                .preferredColorScheme(.dark)
        }
        .windowToolbarStyle(UnifiedWindowToolbarStyle())
        #elseif os(iOS)
        WindowGroup {
            ContentView()
                .toolbar(content: {
                    Text("")
                })
                .preferredColorScheme(.dark)
        }
        
        #endif
    }
}
