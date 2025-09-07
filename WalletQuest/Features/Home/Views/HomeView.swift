//
//  ContentView.swift
//  WalletQuest
//
//  Created by mahdi on 07/09/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "creditcard")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("WalletQuest Home")
                    .font(.title2).bold()
                Text("Scaffolded structure in place. Start building features.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                NavigationLink(destination: TransactionsListView()) {
                    Label("View Transactions", systemImage: "list.bullet")
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 16)

                NavigationLink(destination: CategoriesListView()) {
                    Label("Manage Categories", systemImage: "tag")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview { HomeView() }
