//
//  AccountInfoView.swift
//  BlockXplore
//
//  Created by Soso on 2025/5/12.
//

import SwiftUI
import Solana

enum AccountType {
    case systemAccount
    case programAccount
    case mintAccount
    case tokenAccount
    case pda

    var label: String {
        switch self {
        case .systemAccount: return "Personal Wallet"
        case .programAccount: return "Application"
        case .mintAccount: return "Token Blueprint"
        case .tokenAccount: return "My Token Balance"
        case .pda: return "Application Management Data"
        }
    }

    var description: String {
        switch self {
        case .systemAccount: return "Your digital asset wallet for sending and receiving SOL and other tokens."
        case .programAccount: return "Software or services on Solana that perform specific functions."
        case .mintAccount: return "Defines the attributes of a specific token or NFT, such as name, symbol, and total supply."
        case .tokenAccount: return "An account holding a specific token for a specific user, showing its balance."
        case .pda: return "A special address automatically created and managed by applications to store related data."
        }
    }

    var previewInfo: String {
        switch self {
        case .systemAccount: return "SOL balance, primary token"
        case .programAccount: return "Drift V2 Program"
        case .mintAccount: return "Token name, symbol, type (fungible/NFT)"
        case .tokenAccount: return "Token name/image, balance/NFT ID, owner wallet"
        case .pda: return "Associated application (if known), data summary (if applicable)"
        }
    }
}

struct AccountInfoView: View {
    let accountType: AccountType

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Account Summary Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Account Overview")
                        .font(.title2)
                        .bold()
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("SOL Balance:")
                            Spacer()
                            Text("0.001141")
                                .bold()
                        }
                        HStack {
                            Text("Upgradeable")
                            Spacer()
                            Text("Yes")
                                .bold()
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }

                Divider()

                // Admin and Ownership Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Admin and Ownership")
                        .font(.title2)
                        .bold()
                    HStack {
                        Text("Admin:")
                        Spacer()
                        Link("FdtiepBtP98oU2uPNgAzUoGwggUDdRXwJH2KJo3oUaix", destination: URL(string: "https://solscan.io/account/FdtiepBtP98oU2uPNgAzUoGwggUDdRXwJH2KJo3oUaix")!)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Text("Public Name:")
                        Spacer()
                        Text("Drift V2 Program")
                            .bold()
                    }
                    HStack {
                        Text("Owner:")
                        Spacer()
                        Link("BPFLoaderUpgradeab1e", destination: URL(string: "https://solscan.io/account/BPFLoaderUpgradeab1e11111111111111111111111")!)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Text("Verified:")
                        Spacer()
                        Link("Verified", destination: URL(string: "https://github.com/drift-labs/protocol-v2")!)
                            .bold()
                            .foregroundColor(.blue)
                    }
                }

                Divider()

                // Features Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Key Features")
                        .font(.title2)
                        .bold()
                    Text("1. Decentralized Perpetual Contract Exchange (DEX): Drift Protocol v2 is an on-chain decentralized exchange focused on perpetual contract trading.\n\n2. Multiple Liquidity Mechanisms: The protocol is designed with various mechanisms to provide and ensure liquidity.\n\n3. Open-Source Software Development Kit (SDK) and Solana Programs: The repository provides the open-source Typescript SDK and related Solana program code for Drift V2, enabling developers to integrate and build upon it.\n\n4. Integration and Development Support: The repository includes information on integrating Drift, including SDK guides and bot implementation examples for makers, liquidators, and fillers.\n\n5. Local Build and Testing: Instructions are provided for building the project locally, compiling programs, and running Rust and Javascript tests.\n\n6. Bug Bounty Program: The repository includes details about its Bug Bounty program, encouraging the community to discover and report potential security issues.\n")
                        .font(.body)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Account Details")
    }
}
