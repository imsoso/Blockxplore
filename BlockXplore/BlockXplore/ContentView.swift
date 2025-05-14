//
//  ContentView.swift
//  BlockXplore
//
//  Created by Soso on 2025/5/11.
//

import SwiftUI
import Solana

// Assume your Solana SDK (e.g., SolanaSwift) provides PublicKey and AccountInfo structures
// If you are using SolanaSwift, you can import SolanaSwift

// Define constants for program IDs and data lengths for easier maintenance
struct SolanaConstants {
    static let SystemProgramID = "11111111111111111111111111111111"
    static let TokenProgramID = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
    // static let BPFLoaderUpgradeableProgramID = "BPFLoaderUpgradeab1e11111111111111111111111" // Optional, executable flag is more direct

    static let MintAccountDataLength: Int = 82
    static let TokenAccountDataLength: Int = 165
}

struct ContentView: View {
    @State private var address: String = "dRiftyHA39MWEi3m9aunc5MzRF1JYuBsbn6VPcn33UH"
    @State private var selectedNetwork: String = "Mainnet"
    // @State private var accountInfo: BufferInfo<AccountInfo>? = nil // Old, replaced with determinedAccountType
    @State private var determinedAccountType: AccountType? = nil // New: Stores the determined account type
    @State private var showAccountInfoView = false // Renamed variable for clearer distinction

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
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Solana Explore")
                            .font(.headline)
                            .foregroundColor(.white) // Set the title color to white
                    }
                }
                
                VStack {
                    HStack {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundColor(.white) // Set the icon color to white
                        TextField("Paste address here", text: $address)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                    
                    Button(action: {
                        Task {
                            await fetchAndClassifyAccountInfo(for: address)
                        }
                    }) {
                        Label("Check", systemImage: "magnifyingglass")
                            .foregroundColor(.white) // Set the button text and icon color to white

                    }
                    .buttonStyle(.bordered)
                    .tint(.white) // Optional: Set the border color to white
                    .padding()
                    
                    // NavigationLink used to navigate after determinedAccountType is set
                    NavigationLink(
                        destination: Group { // Use Group to allow conditional views
                            if let type = determinedAccountType {
                                AccountInfoView(accountType: type)
                            } else {
                                // If determinedAccountType is nil (should not happen when showAccountInfoView is true)
                                Text("Loading details or error...")
                            }
                        },
                        isActive: $showAccountInfoView
                    ) {
                        EmptyView()
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
                            Text(selectedNetwork)
                        }
                    }
                }
            }
        }
    }
    
    func fetchAndClassifyAccountInfo(for address: String) async {
        self.determinedAccountType = nil // Reset state
        self.showAccountInfoView = false   // Reset navigation trigger

        print("Fetching and classifying account: \(address)")

        guard let publicKey = PublicKey(string: address) else {
            print("Invalid address format: \(address)")
            // TODO: Consider showing an error to the user (e.g., an alert)
            return
        }

        do {
            // 1. Fetch account information
            // Assume AccountInfo structure (obtained via decodedTo: AccountInfo.self) contains the following fields:
            //   owner: String (Base58-encoded public key) or PublicKey
            //   executable: Bool
            //   data: Usually a type containing raw bytes (e.g., Data, [UInt8]) or a structure that can access raw bytes
            //   lamports: UInt64
            //   rentEpoch: UInt64
            //   (For SolanaSwift, the `data` field in `AccountInfo` structure is an `AccountInfoData` enum)

            // To reliably get the raw data length, especially for accounts owned by the Token Program,
            // it is best to fetch the raw base64-encoded data and calculate its byte length.
            // Many Solana SDKs allow you to fetch the raw base64-encoded data array.
            // Here we first try using decodedTo: AccountInfo.self and assume we can get the data length from it.
            // If not, adjust to fetch the raw data first.

            let info: BufferInfo<AccountInfo> = try await solana.api.getAccountInfo(account: address, decodedTo: AccountInfo.self)
            


            let ownerString = info.owner
            let isExecutable = info.executable
            

            var determinedType: AccountType?

            // 2. Determine PDA (Program Derived Address)
            // PublicKey(string: address) was already created as publicKey at the start of the function
  
            // 3. If on the curve, perform other checks
            if isExecutable {
                determinedType = .programAccount
            } else if ownerString == SolanaConstants.TokenProgramID {
                determinedType = .tokenAccount

            } else if ownerString == SolanaConstants.SystemProgramID {
                determinedType = .systemAccount
            } else {
                // On-curve, not executable, not owned by System/Token Program.
                // This may be a custom program's data account.
                // Based on your description of PDA as "application-managed data," such accounts are sometimes broadly considered similar to PDAs.
                // However, strictly speaking, PDA refers to addresses not on the curve.
                // If no better classification exists, you can leave it unclassified or set a default/unknown type.
                print("Account \(address) is on-curve, not executable, not owned by System/Token Program. Owner: \(ownerString). Classification unclear.")
                // Temporarily leave it unclassified, or if it is indeed application-managed data, classify it as .pda (though this does not strictly match the definition)
                // determinedType = .pda // (Optional, if you want to define PDA more loosely)
            }

            if let type = determinedType {
                self.determinedAccountType = type
                self.showAccountInfoView = true // Trigger navigation
                print("Determined Account Type for \(address): \(type.label)")
            } else {
                print("Could not determine account type for \(address)")
                // TODO: Show the user information about the inability to determine the type
            }

        } catch {
            print("Error fetching or classifying account info for \(address): \(error)")
            // TODO: Show the user error information
        }

        // Other asynchronous tasks can remain unchanged if they are used for other parts of the UI or logging
        Task {
            do { try await fetchBalanceTask(for: address) } catch { print("Error in concurrent balance fetch: \(error)") }
        }
        Task {
            do { try await fetchTokenBalanceTask(for: address) } catch { print("Error in concurrent token balance fetch: \(error)") }
        }
    }

    // fetchAccountInfoTask is no longer directly used; its logic has been merged into fetchAndClassifyAccountInfo
    // private func fetchAccountInfoTask(for address: String) async throws { ... }

    private func fetchBalanceTask(for address: String) async throws {
        let balance = try await solana.api.getBalance(account: address)
        print("Balance (SOL): \(Double(balance) / Double(1_000_000_000))")
    }

    private func fetchTokenBalanceTask(for address: String) async throws {
        // Note: getTokenAccountBalance is only valid for TokenAccount. If the address is not a TokenAccount, it will throw an error.
        // It is best to call this after confirming the account is a TokenAccount or handle potential errors.
        do {
            let tokenBalanceResult = try await solana.api.getTokenAccountBalance(pubkey: address, commitment: nil) // commitment is optional
            print("Token Balance (raw amount): \(tokenBalanceResult.uiAmountString ?? "N/A") (decimals: \(tokenBalanceResult.decimals))")
        } catch {
            print("Could not fetch token balance for \(address) (may not be a token account or error occurred): \(error.localizedDescription)")
        }
    }
    
    
}

#Preview {
    ContentView()
}
