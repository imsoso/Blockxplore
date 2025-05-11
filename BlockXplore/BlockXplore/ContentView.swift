//
//  ContentView.swift
//  BlockXplore
//
//  Created by Soso on 2025/5/11.
//

import SwiftUI

struct ContentView: View {
    @State private var address: String = ""
    @State private var selectedNetwork: String = "Mainnet" // Default network

    var body: some View {
        NavigationView {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Mainnet") { selectedNetwork = "Mainnet" }
                        Button("Testnet") { selectedNetwork = "Testnet" }
                        Button("Devnet") { selectedNetwork = "Devnet" }
                    } label: {
                        Text(selectedNetwork) // Display only the current network name
                    }
                }
            }
        }
    }
    
    func checkAddress() {
        // todo: Implement the logic to check the address
    }
}

#Preview {
    ContentView()
}
