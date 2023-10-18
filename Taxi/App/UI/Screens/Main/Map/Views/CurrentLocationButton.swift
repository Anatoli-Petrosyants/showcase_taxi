//
//  CurrentLocationButton.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 16.10.23.
//

import SwiftUI

struct CurrentLocationButton: View {
    
    @Binding var moving: Bool
    var didTap: () -> ()
    
    var body: some View {
        Button {
            didTap()
        } label: {
            Image(systemName: "location")
                .renderingMode(.template)
                .foregroundColor(Color.black)
                .font(.system(size: 20))
                .padding(12)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black01, radius: 4)
        }
        .opacity(moving ? 0 : 1.0)
        .animation(.linear(duration: 0.1), value: moving)
    }
}
