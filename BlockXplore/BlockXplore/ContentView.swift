//
//  ContentView.swift
//  BlockXplore
//
//  Created by Soso on 2025/5/11.
//

import SwiftUI

struct ContentView: View {
    @State private var address: String = ""

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                TextField("Paste address here", text: $address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            
            Button(action: {
                checkAddress()
            }) {
                Label("Check", systemImage: "magnifyingglass")
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .padding()
    }
    
    func checkAddress() {
        // todo: Implement the logic to check the address
    }
}

#Preview {
    ContentView()
}
