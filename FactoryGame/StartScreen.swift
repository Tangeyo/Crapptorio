//
//  StartScreen.swift
//  FactoryGame
//
//  Created by Ava Albert on 12/12/24.
//

import SwiftUI

struct StartScreen: View {
    @Binding var isGameStarted: Bool

    var body: some View {
        VStack {
            Text("Welcome to Crapptorio!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("In this game, you manage a factory system and direct resources using conveyors and your wits!")
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                isGameStarted = true
            }) {
                Text("Start Game")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }
}
