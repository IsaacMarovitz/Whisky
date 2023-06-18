//
//  Installer.swift
//  Whisky
//
//  Created by Isaac Marovitz on 14/06/2023.
//

import Foundation

class WineInstaller {
    // Grab the WineBinaryVersion int from Info.plist
    static let WineBinaryVersion = Bundle.main.infoDictionary?["WineBinaryVersion"] as? Int ?? 0

    static let libraryArchive: URL = (Bundle.main.resourceURL ?? URL(fileURLWithPath: ""))
        .appendingPathComponent("Libraries")
        .appendingPathExtension("tar")
        .appendingPathExtension("gz")

    static let libraryFolder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Whisky")
        .appendingPathComponent("Libraries")

    static func isWineInstalled() -> Bool {
        return FileManager.default.fileExists(atPath: libraryFolder.path)
    }

    static func installWine() {
        do {
            let whiskySupportFolder = FileManager.default.urls(for: .applicationSupportDirectory,
                                                               in: .userDomainMask)[0]
                .appendingPathComponent("Whisky")

            if !FileManager.default.fileExists(atPath: whiskySupportFolder.path) {
                try FileManager.default.createDirectory(at: whiskySupportFolder, withIntermediateDirectories: true)
            } else {
                // Recreate it
                try FileManager.default.removeItem(at: whiskySupportFolder)
                try FileManager.default.createDirectory(at: whiskySupportFolder, withIntermediateDirectories: true)
            }

            try Tar.untar(tarBall: libraryArchive, toURL: whiskySupportFolder)

            // Write the binary version to the build_version file
            let buildVersionFile = libraryFolder.appendingPathComponent("build_version")
            try String(WineBinaryVersion).write(to: buildVersionFile, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to install Wine: \(error)")
        }
    }

    static func updateWine() {
        // Read the build version from the Wine directory
        let buildVersionFile = WineInstaller.libraryFolder.appendingPathComponent("build_version")
        let currentVersion = try? String(contentsOf: buildVersionFile, encoding: .utf8)

        // If the current version is not the same as the binary version, we need to update by calling install again
        if currentVersion != String(WineBinaryVersion) {
            installWine()
        }
    }
}
