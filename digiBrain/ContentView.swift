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
    @State private var isShowingSplash = true
    
    var body: some View {
        ZStack {
            if isShowingSplash {
                VStack {
                    Text("DigiBrain")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                AuthView(modelContext: modelContext)
            }
        }
        .onAppear {
            // Add a slight delay before showing the main content
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    isShowingSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
