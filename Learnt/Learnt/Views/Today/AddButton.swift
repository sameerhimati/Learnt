//
//  AddButton.swift
//  Learnt
//

import SwiftUI

struct AddButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(Color.primaryTextColor)
                .frame(width: 56, height: 56)
                .background(Color.inputBackgroundColor)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.appBackgroundColor
            .ignoresSafeArea()

        VStack {
            Spacer()
            HStack {
                Spacer()
                AddButton(onTap: {})
                    .padding(24)
            }
        }
    }
}
