//
//  BottleCreationView.swift
//  Whisky
//
//  Created by Isaac Marovitz on 24/03/2023.
//

import SwiftUI

struct BottleCreationView: View {
    @State var newBottleName: String = ""
    @State var newBottleVersion: WinVersion = .win10
    @State var newBottleURL: URL = BottleVM.bottleDir
    @State var bottlePath: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Text("create.title")
                    .bold()
                Spacer()
            }
            Divider()
            HStack(alignment: .top) {
                Text("create.name")
                Spacer()
                TextField("", text: $newBottleName)
                .frame(width: 180)
            }
            HStack {
                Text("create.win")
                Spacer()
                Picker("", selection: $newBottleVersion) {
                    ForEach(WinVersion.allCases.reversed(), id: \.self) {
                        Text($0.pretty())
                    }
                }
                .labelsHidden()
                .frame(width: 180)
            }
            HStack {
                Text("create.path")
                Spacer()
                Text(bottlePath)
                    .truncationMode(.middle)
                Button("create.browse") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = false
                    panel.canChooseDirectories = true
                    panel.allowsMultipleSelection = false
                    panel.canCreateDirectories = true
                    panel.directoryURL = BottleVM.containerDir
                    panel.begin { result in
                        if result == .OK {
                            if let url = panel.urls.first {
                                newBottleURL = url
                            }
                        }
                    }
                }
            }
            Spacer()
            HStack {
                Spacer()
                Button("create.cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                Button("create.create") {
                    BottleVM.shared.createNewBottle(bottleName: newBottleName,
                                                    winVersion: newBottleVersion,
                                                    bottleURL: newBottleURL)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .onChange(of: newBottleURL) { _ in
            bottlePath = newBottleURL.prettyPath()
        }
        .onAppear {
            bottlePath = newBottleURL.prettyPath()
        }
        .frame(width: 400, height: 180)
    }
}

struct BottleCreationView_Previews: PreviewProvider {
    static var previews: some View {
        BottleCreationView()
    }
}
