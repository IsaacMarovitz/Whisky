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

    static let libraryFolder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.isaacmarovitz.Whisky")
        .appendingPathComponent("Libraries")

    static func isWineInstalled() -> Bool {
        return FileManager.default.fileExists(atPath: libraryFolder.path)
    }

    static func installWine(from: URL) async {
        do {
            let whiskySupportFolder = FileManager.default.urls(for: .applicationSupportDirectory,
                                                               in: .userDomainMask)[0]
                .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.isaacmarovitz.Whisky")

            if !FileManager.default.fileExists(atPath: whiskySupportFolder.path) {
                try FileManager.default.createDirectory(at: whiskySupportFolder, withIntermediateDirectories: true)
            } else {
                // Recreate it
                try FileManager.default.removeItem(at: whiskySupportFolder)
                try FileManager.default.createDirectory(at: whiskySupportFolder, withIntermediateDirectories: true)
            }

            _ = await Task {
                try Tar.untar(tarBall: from, toURL: whiskySupportFolder)
            }.result

            let tarFile = whiskySupportFolder
                .appendingPathComponent("Libraries")
                .appendingPathExtension("tar")
                .appendingPathExtension("gz")
            _ = await Task {
                try Tar.untar(tarBall: tarFile, toURL: whiskySupportFolder)
                try FileManager.default.removeItem(at: tarFile)
            }.result

            // Write the binary version to the build_version file
            let buildVersionFile = libraryFolder.appendingPathComponent("build_version")
            try String(WineBinaryVersion).write(to: buildVersionFile, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to install Wine: \(error)")
        }
    }

    static func uninstallWine() {
        let libraryFolder = FileManager.default.urls(for: .applicationSupportDirectory,
                                                           in: .userDomainMask)[0]
            .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.isaacmarovitz.Whisky")
            .appendingPathComponent("Libraries")

        do {
            try FileManager.default.removeItem(at: libraryFolder)
        } catch {
            print("Failed to uninstall Wine: \(error)")
        }
    }

    static func shouldUpdateWine() -> Bool {
        // Read the build version from the Wine directory
        let buildVersionFile = WineInstaller.libraryFolder.appendingPathComponent("build_version")
        let currentVersion = try? String(contentsOf: buildVersionFile, encoding: .utf8)

        // If the current version is not the same as the binary version, we need to update by calling install again
        return currentVersion != String(WineBinaryVersion)
    }
}
