import Foundation
import ObjectiveC

/* Build script for Swiftgrounds frontend, work in progress */
func deleteFolder(at url: URL) {
    let fileManager = FileManager.default
    
    do {
        try fileManager.removeItem(at: url)
        print("La carpeta \(url.lastPathComponent) ha sido eliminada correctamente.")
    } catch {
        print("Error al eliminar la carpeta: \(error.localizedDescription)")
    }
}

func copyAndRenameFiles(from sourceDirectory: URL, to destinationDirectory: URL) {
    let fileManager = FileManager.default
    
    do {
        let contents = try fileManager.contentsOfDirectory(at: sourceDirectory, includingPropertiesForKeys: nil)
        
        for url in contents {
            
            guard !url.path.contains(".DS_Store") && !url.path.contains(".git") else {
                continue
            }
            
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    let newDestinationURL = destinationDirectory.appendingPathComponent(url.lastPathComponent)
                    try fileManager.createDirectory(at: newDestinationURL, withIntermediateDirectories: true, attributes: nil)
                    copyAndRenameFiles(from: url, to: newDestinationURL)
                } else {
                    let newURL = destinationDirectory.appendingPathComponent(url.lastPathComponent)
                    try fileManager.copyItem(at: url, to: newURL)
                    
                    if url.pathExtension == "swift" {
                        let renamedURL = newURL.deletingPathExtension().appendingPathExtension("md")
                        try fileManager.moveItem(at: newURL, to: renamedURL)
                        print("Renamed \(url.lastPathComponent) to \(renamedURL.lastPathComponent)")
                    } else if url.lastPathComponent == "main.swift" {
                        let renamedURL = newURL.deletingLastPathComponent().appendingPathComponent("index.md")
                        try fileManager.moveItem(at: newURL, to: renamedURL)
                        print("Renamed \(url.lastPathComponent) to \(renamedURL.lastPathComponent)")
                    }                
                }
            }
        }
        
        print("Copy and rename completed successfully!")
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}

let currentDirectoryPath = FileManager.default.currentDirectoryPath
let destinationPath = "/Users/cristian/dev/web/SwiftGrounds/content"

let currentDirectoryURL = URL(string: "file://" + currentDirectoryPath)!
let destURL = URL(string: "file://" + destinationPath)!

deleteFolder(at: destURL)
copyAndRenameFiles(from: currentDirectoryURL, to: destURL)
