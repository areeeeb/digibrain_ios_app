//
//  ContentView.swift
//  digiBrain
//
//  Created by Areeb Abbasi on 12/17/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        AuthView(modelContext: modelContext)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
