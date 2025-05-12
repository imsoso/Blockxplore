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

    
    public static let mainnetBetaAnkr = RPCEndpoint(
        url: URL(string: "https://mainnet.helius-rpc.com/?api-key=7d9d37dd-ad9b-499c-98f72")!,
        urlWebSocket: URL(string: "https://mainnet.helius-rpc.com/?api-key=7d9d37dd-ad9b-499c-98f7")!,
        network: .mainnetBeta
    )
    
    let endpoint = mainnetBetaAnkr
    let router: NetworkingRouter
    let solana: Solana

    init() {
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
