//
//  AccountInfoView.swift
//  BlockXplore
//
//  Created by Soso on 2025/5/12.
//

import SwiftUI
import Solana

struct AccountInfoView: View {
    let accountInfo: BufferInfo<AccountInfo>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Account Info")
                .font(.headline)
            Text("Lamports: \(accountInfo.lamports)")
            Text("Owner: \(accountInfo.owner)")
            Text("Executable: \(accountInfo.executable ? "Yes" : "No")")
            Text("Rent Epoch: \(accountInfo.rentEpoch)")
        }
        .padding()
        .navigationTitle("Account Info")
    }
}

