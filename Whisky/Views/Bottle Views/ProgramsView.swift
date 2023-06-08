//
//  ProgramsView.swift
//  Whisky
//
//  Created by Isaac Marovitz on 31/03/2023.
//

import SwiftUI

struct ProgramsView: View {
    let bottle: Bottle
    @State var programs: [Program] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("program.title") {
                    List($programs, id: \.self) { $program in
                        NavigationLink {
                            ProgramView(program: $program)
                        } label: {
                            ProgramItemView(program: program)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(String(format: NSLocalizedString("tab.navTitle.programs",
                                                              comment: ""),
                                    bottle.name))
            .onAppear {
                programs = bottle.updateInstalledPrograms()
            }
        }
    }
}

struct ProgramItemView: View {
    let program: Program
    @State var showButtons: Bool = false

    var body: some View {
        HStack {
            Text(program.name)
            Spacer()
            if showButtons {
                Button {
                    Task(priority: .userInitiated) {
                        do {
                            try await Wine.runProgram(program: program)
                        } catch {
                            let alert = NSAlert()
                            alert.messageText = "alert.message"
                            alert.informativeText = "alert.info" + " \(program.name)"
                            alert.alertStyle = .critical
                            alert.addButton(withTitle: "button.ok")
                            alert.runModal()
                        }
                    }
                } label: {
                    Image(systemName: "play.circle.fill")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .onHover { hover in
            showButtons = hover
        }
    }
}

struct ProgramsView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramsView(bottle: Bottle())
    }
}
