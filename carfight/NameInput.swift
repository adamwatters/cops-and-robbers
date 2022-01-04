//
//  UsernameInput.swift
//  carfight
//
//  Created by Adam Watters on 1/4/22.
//

import SwiftUI

protocol NameInputDelegate: NSObjectProtocol {
    func handleSubmit(_ name: String)
}

struct NameInput: View {
    weak var delegate: NameInputDelegate?
    @State private var username: String = ""
    var body: some View {
        VStack {
            HStack {
                Text("pick a name").foregroundColor(Color.gray)
                Spacer()
            }
            TextField(
                "username",
                text: $username
            ).foregroundColor(Color.black).padding()
            .disableAutocorrection(true)
            .background(Color.white)
            .border(Color.black)
            Button(action: {
                delegate?.handleSubmit(username)
            }) {
                Text("Join Game").foregroundColor(Color.white).padding()
            }.background(Color("PrimaryGreen")).cornerRadius(10).shadow(color: Color("Shadow"), radius: 4, x: 0, y: 0)
        }.frame(width: 300).padding().background(Color("PrimaryGray")).cornerRadius(20).shadow(color: Color("Shadow"), radius: 4, x: 0, y: 0)
    }
}

