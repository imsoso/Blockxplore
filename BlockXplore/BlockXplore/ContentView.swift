//
//  ContentView.swift
//  BlockXplore
//
//  Created by Soso on 2025/5/11.
//

import SwiftUI
import Solana

// 假设您的 Solana SDK (如 SolanaSwift) 提供了 PublicKey 和 AccountInfo 结构
// 如果您使用的是 SolanaSwift，可以 import SolanaSwift

// 定义程序 ID 和数据长度常量，方便维护
struct SolanaConstants {
    static let SystemProgramID = "11111111111111111111111111111111"
    static let TokenProgramID = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"
    // static let BPFLoaderUpgradeableProgramID = "BPFLoaderUpgradeab1e11111111111111111111111" // 可选，executable 标志更直接

    static let MintAccountDataLength: Int = 82
    static let TokenAccountDataLength: Int = 165
}

struct ContentView: View {
    @State private var address: String = "dRiftyHA39MWEi3m9aunc5MzRF1JYuBsbn6VPcn33UH"
    @State private var selectedNetwork: String = "Mainnet"
    // @State private var accountInfo: BufferInfo<AccountInfo>? = nil // 旧的，我们将用 determinedAccountType
    @State private var determinedAccountType: AccountType? = nil // 新增：存储判断出的账户类型
    @State private var showAccountInfoView = false // 修改变量名以更清晰区分

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
                // 背景渐变
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
                            .foregroundColor(.white) // 设置图标颜色为白色
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
                            .foregroundColor(.white) // 设置按钮文字和图标颜色为白色

                    }
                    .buttonStyle(.bordered)
                    .tint(.white) // Optional: Set the border color to white
                    .padding()
                    
                    // NavigationLink 用于在 determinedAccountType 设置后导航
                    NavigationLink(
                        destination: Group { // 使用 Group 允许条件视图
                            if let type = determinedAccountType {
                                AccountInfoView(accountType: type)
                            } else {
                                // 如果 determinedAccountType 为 nil (不应在 showAccountInfoView 为 true 时发生)
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
        self.determinedAccountType = nil // 重置状态
        self.showAccountInfoView = false   // 重置导航触发器

        print("Fetching and classifying account: \(address)")

        guard let publicKey = PublicKey(string: address) else {
            print("Invalid address format: \(address)")
            // TODO: Consider showing an error to the user (e.g., an alert)
            return
        }

        do {
            // 1. 获取账户信息
            // 假设 AccountInfo 结构体 (通过 decodedTo: AccountInfo.self 获取) 包含以下字段:
            //   owner: String (Base58编码的公钥) 或 PublicKey
            //   executable: Bool
            //   data: 通常是一个包含原始字节的类型 (如 Data, [UInt8]) 或一个可以获取原始字节的结构
            //   lamports: UInt64
            //   rentEpoch: UInt64
            //   (对于SolanaSwift, `AccountInfo` 结构内的 `data` 字段是 `AccountInfoData` 枚举)

            // 为了更可靠地获取原始数据长度，特别是对于 Token Program 拥有的账户，
            // 最好是获取原始的 base64 编码数据，然后计算其字节长度。
            // 很多 Solana SDK 允许你获取原始的 base64 编码的 data 数组。
            // 这里我们先尝试直接用 decodedTo: AccountInfo.self，并假设可以从中获取数据长度。
            // 如果不行，则需要调整为先获取原始数据。

            let info: BufferInfo<AccountInfo> = try await solana.api.getAccountInfo(account: address, decodedTo: AccountInfo.self)
            


            let ownerString = info.owner
            let isExecutable = info.executable
            

            var determinedType: AccountType?

            // 2. 判断 PDA (Program Derived Address)
            // PublicKey(string: address) 已在函数开头创建为 publicKey
  
            // 3. 如果在曲线上，进行其他判断
            if isExecutable {
                determinedType = .programAccount
            } else if ownerString == SolanaConstants.TokenProgramID {
                determinedType = .tokenAccount

            } else if ownerString == SolanaConstants.SystemProgramID {
                determinedType = .systemAccount
            } else {
                // 在曲线上，不可执行，非TokenProgram或SystemProgram拥有。
                // 这可能是自定义程序的数据账户。
                // 根据您对 PDA 的描述 "应用管理数据"，这类账户有时也广义地被视为类似 PDA 的角色。
                // 但严格来说 PDA 是指地址不在曲线上的。
                // 如果没有更合适的分类，可以暂时不分类或设定一个默认/未知类型。
                print("Account \(address) is on-curve, not executable, not owned by System/Token Program. Owner: \(ownerString). Classification unclear.")
                // 暂时不将其归类，或者您可以根据需求，如果它确实是应用管理的数据，也归为 .pda (但这不符合严格定义)
                // determinedType = .pda // (可选，如果想更宽松地定义 PDA)
            }

            if let type = determinedType {
                self.determinedAccountType = type
                self.showAccountInfoView = true // 触发导航
                print("Determined Account Type for \(address): \(type.label)")
            } else {
                print("Could not determine account type for \(address)")
                // TODO: 向用户显示无法确定类型的信息
            }

        } catch {
            print("Error fetching or classifying account info for \(address): \(error)")
            // TODO: 向用户显示错误信息
        }

        // 其他异步任务可以保持不变，如果它们用于UI的其他部分或日志记录
        Task {
            do { try await fetchBalanceTask(for: address) } catch { print("Error in concurrent balance fetch: \(error)") }
        }
        Task {
            do { try await fetchTokenBalanceTask(for: address) } catch { print("Error in concurrent token balance fetch: \(error)") }
        }
    }

    // fetchAccountInfoTask 不再直接使用，其逻辑已合并到 fetchAndClassifyAccountInfo
    // private func fetchAccountInfoTask(for address: String) async throws { ... }

    private func fetchBalanceTask(for address: String) async throws {
        let balance = try await solana.api.getBalance(account: address)
        print("Balance (SOL): \(Double(balance) / Double(1_000_000_000))")
    }

    private func fetchTokenBalanceTask(for address: String) async throws {
        // 注意: getTokenAccountBalance 只对 TokenAccount 有效。如果地址不是TokenAccount，会报错。
        // 最好在确定账户是 TokenAccount 后再调用，或处理潜在的错误。
        do {
            let tokenBalanceResult = try await solana.api.getTokenAccountBalance(pubkey: address, commitment: nil) // commitment 可选
            print("Token Balance (raw amount): \(tokenBalanceResult.uiAmountString ?? "N/A") (decimals: \(tokenBalanceResult.decimals))")
        } catch {
            print("Could not fetch token balance for \(address) (may not be a token account or error occurred): \(error.localizedDescription)")
        }
    }
    
    
}

#Preview {
    ContentView()
}
