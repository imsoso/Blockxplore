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

        async let accountInfoResult: Void = fetchAccountInfoTask(for: address)
        async let balanceResult: Void = fetchBalanceTask(for: address)
        async let tokenBalanceResult: Void = fetchTokenBalanceTask(for: address)

        do {
            try await accountInfoResult
        } catch {
            print("Error fetching account info: \(error)")
        }

        do {
            try await balanceResult
        } catch {
            print("Error fetching balance: \(error)")
        }

        do {
            try await tokenBalanceResult
        } catch {
            print("Error fetching token balance: \(error)")
        }
    }

    private func fetchAccountInfoTask(for address: String) async throws {
        let info: BufferInfo<AccountInfo> = try await solana.api.getAccountInfo(account: address, decodedTo: AccountInfo.self)
        print("Account Info: \(info)")
        accountInfo = info
        showAccountInfo = true
    }

    private func fetchBalanceTask(for address: String) async throws {
        let balance = try await solana.api.getBalance(account: address)
        print("Balance: \(balance / 1_000_000_000)")
    }

    private func fetchTokenBalanceTask(for address: String) async throws {
        let tokenBalance = try await solana.api.getTokenAccountBalance(pubkey: address).amount
        print("Token Balance: \(tokenBalance)")
    }
}

#Preview {
    ContentView()
}
