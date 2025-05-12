//
//  ContentView.swift
//  BlockXplore
//
//  Created by Soso on 2025/5/11.
//

import SwiftUI
import Solana

struct ContentView: View {
    @State private var address: String = ""
    @State private var selectedNetwork: String = "Mainnet" // Local variable to store the selected network
    @State private var accountInfo: BufferInfo<AccountInfo>? = nil
    @State private var showAccountInfo = false

    let baseURL: String
    let rpcURL: String
    let endpoint: RPCEndpoint
    let router: NetworkingRouter
    let solana: Solana

    init() {
        guard let customRPC = Bundle.main.object(forInfoDictionaryKey: "Helius_RPC") as? String else {
            fatalError("Helius_RPC not found in Configuration.xcconfig")
        }
        
        self.baseURL = "mainnet.helius-rpc.com/?api-key="
        self.rpcURL = baseURL + customRPC
        
        self.endpoint = RPCEndpoint(
            url: URL(string: "https://"+rpcURL)!,
            urlWebSocket: URL(string: "wss://"+rpcURL)!,
            network: .mainnetBeta
        )
        self.router = NetworkingRouter(endpoint: endpoint)
        self.solana = Solana(router: router)
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
                        await fetchAccountInfo(for: address)
                    }
                }) {
                    Label("Check", systemImage: "magnifyingglass")
                }
                .buttonStyle(.bordered)
                .padding()
                if let accountInfo = accountInfo {
                    NavigationLink(
                        destination: AccountInfoView(accountInfo: accountInfo),
                        isActive: $showAccountInfo
                    ) {
                        EmptyView()
                    }
                }
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
    
    
    func fetchAccountInfo(for address: String) async {
        print("address: \(address)")
        var retryCount = 0
        let maxRetries = 3

        while retryCount < maxRetries {
            do {
                let info: BufferInfo<AccountInfo> = try await solana.api.getAccountInfo(account: address, decodedTo: AccountInfo.self)
                print("Account Info: \(info)")
                accountInfo = info
                showAccountInfo = true

                return
            } catch {
//                print("Error during sleep: \(error)")
                retryCount += 1
                print("Error fetching account info (attempt \(retryCount))")
                if retryCount == maxRetries {
                    print("Max retry attempts reached. Please check your network connection.")
                } else {
                    print("Retrying in 2 seconds...")
                    do {
                        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Wait for 2 seconds before retrying
                    } catch {
                        print("Error during sleep: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
