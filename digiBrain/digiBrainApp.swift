//
//  digiBrainApp.swift
//  digiBrain
//
//  Created by Areeb Abbasi on 12/17/24.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth

@main
struct digiBrainApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            AuthState.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        FirebaseApp.configure()
        print("Firebase has been configured")
        
        // Check if the user is already signed in
        if let user = Auth.auth().currentUser {
            print("User is signed in with uid: \(user.uid)")
        } else {
            print("No user is signed in.")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

