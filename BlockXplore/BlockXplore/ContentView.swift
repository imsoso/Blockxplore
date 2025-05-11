//
//  ContentView.swift
//  BlockXplore
//
//  Created by Soso on 2025/5/11.
//

import SwiftUI
import SolanaSwift

struct ContentView: View {
    @State private var address: String = ""
    @State private var selectedNetwork: String = "Mainnet" // Local variable to store the selected network

    var endpoint: APIEndPoint {
        let ApiAddress = "https://devnet.helius-rpc.com/?api-key=7ad72601-5330-4af0-b238-175e3ed057d1"
        switch selectedNetwork {
        case "Testnet":
            return APIEndPoint(address: ApiAddress, network: .testnet)
        case "Devnet":
            return APIEndPoint(address: ApiAddress, network: .devnet)
        default:
            return APIEndPoint(address: ApiAddress, network: .mainnetBeta)
        }
    }

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
                    Task {
                        await checkAddress()
                    }
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
    
    func checkAddress() async {
        do {
            let apiClient = JSONRPCAPIClient(endpoint: endpoint)
            let result = try await apiClient.getBlockHeight()
            print("Block height: \(result)")
        } catch {
            print("Error fetching block height: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
