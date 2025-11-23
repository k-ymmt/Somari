//
//  SomariApp.swift
//  Somari
//
//  Created by Kazuki Yamamoto on 2025/11/11.
//

import SwiftUI

@main
struct SomariApp: App {
    @State private var launched = false
    @State private var isDebugMenuPresented = false

    var body: some Scene {
        WindowGroup {
            if launched {
                FeedSourcesView()
                    .environment(PageRouter())
#if DEBUG
                    .onShake {
                        isDebugMenuPresented = true
                    }
                    .sheet(isPresented: $isDebugMenuPresented) {
                        DebugMenuView()
                    }
#endif
            } else {
                LaunchView {
                    launched = true
                }
            }
        }
    }
}
