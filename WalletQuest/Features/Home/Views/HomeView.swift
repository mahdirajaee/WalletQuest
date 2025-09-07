//
//  ContentView.swift
//  WalletQuest
//
//  Created by mahdi on 07/09/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("WalletQuest Home")
                .font(.title2).bold()
            Text("Scaffolded structure in place. Start building features.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
