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
        case .systemAccount: return "个人钱包"
        case .programAccount: return "应用程序"
        case .mintAccount: return "代币蓝图"
        case .tokenAccount: return "我的代币余额"
        case .pda: return "应用管理数据"
        }
    }

    var description: String {
        switch self {
        case .systemAccount: return "您的数字资产钱包，用于收发 SOL 和其他代币。"
        case .programAccount: return "Solana 上的软件或服务，执行特定功能。"
        case .mintAccount: return "定义了一种特定代币或 NFT 的属性，如名称、符号、总量。"
        case .tokenAccount: return "为特定用户持有的特定代币的账户，显示其余额。"
        case .pda: return "由应用程序自动创建和管理的特殊地址，用于存储该应用相关的数据。"
        }
    }

    var previewInfo: String {
        switch self {
        case .systemAccount: return "SOL 余额, 主要代币"
        case .programAccount: return "Drift V2 Program"
        case .mintAccount: return "代币名称, 符号, 类型 (同质化/NFT)"
        case .tokenAccount: return "代币名称/图片, 余额/NFT ID, 所有者钱包"
        case .pda: return "关联的应用程序 (若可知), 数据摘要 (若适用)"
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
                    Text("账户概览")
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
                            Text("可升级")
                            Spacer()
                            Text("是")
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
                    Text("管理员与所有权")
                        .font(.title2)
                        .bold()
                    HStack {
                        Text("管理员:")
                        Spacer()
                        Link("FdtiepBtP98oU2uPNgAzUoGwggUDdRXwJH2KJo3oUaix", destination: URL(string: "https://solscan.io/account/FdtiepBtP98oU2uPNgAzUoGwggUDdRXwJH2KJo3oUaix")!)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Text("公开名称:")
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
                        Text("是否验证:")
                        Spacer()
                        Link("已验证", destination: URL(string: "https://github.com/drift-labs/protocol-v2")!)
                            .bold()
                            .foregroundColor(.blue)
                    }
                }

                Divider()

                // Features Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("主要功能")
                        .font(.title2)
                        .bold()
                    Text("1、去中心化永续合约交易所 (DEX): Drift Protocol v2 是一个构建在链上的去中心化交易所，专注于永续合约的交易。\n\n2、多种流动性机制: 该协议设计了多种机制来提供和保障流动性。\n\n3、开源软件开发工具包 (SDK) 和 Solana 程序: 仓库提供了 Drift V2 的 Typescript SDK 和相关的 Solana 程序代码，均为开源。这使得开发者可以基于此进行集成和开发。\n\n4、集成与开发支持: 仓库包含了关于如何集成 Drift 的信息，包括 SDK 指南以及针对做市商 (makers)、清算人 (liquidators) 和填充者 (fillers) 的机器人实现示例。\n\n5、本地构建与测试: 提供了在本地构建项目、编译程序以及运行 Rust 和 Javascript 测试的说明。\n\n6、漏洞赏金计划: 仓库包含了关于其漏洞赏金计划 (Bug Bounty program) 的详细信息，鼓励社区发现并报告潜在的安全问题。\n")
                        .font(.body)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("账户详情")
    }
}
