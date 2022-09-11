#!/usr/bin/env swift

import Foundation

// Constants
let fileManager = FileManager.default
let libraryDirectory: URL = try fileManager.url(
  for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

let searchQuery: String = CommandLine.arguments[1].lowercased()
let ignoredPaths: [String] = (ProcessInfo.processInfo.environment["ignored_suffixes"] ?? "")
  .components(separatedBy: "\n")
  .map { libraryDirectory.appendingPathComponent($0).path }

let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey, .isSymbolicLinkKey, .canonicalPathKey])
let directoryEnumerator = fileManager.enumerator(
  at: libraryDirectory, includingPropertiesForKeys: Array(resourceKeys))!

// Main
var sfItems: [[String: Any]] = []

for case let file as URL in directoryEnumerator {
  // Necessary path information
  guard let resourceValues = try? file.resourceValues(forKeys: resourceKeys),
    let isLink = resourceValues.isSymbolicLink,
    let isDirectory = resourceValues.isDirectory,
    let fileName = resourceValues.name,
    let filePath = resourceValues.canonicalPath
  else {
    continue
  }

  // Skip symbolic links
  if isLink { continue }

  // Skip ignored paths
  if isDirectory && ignoredPaths.contains(where: { filePath == $0 }) {
    directoryEnumerator.skipDescendants()
  }

  // Skip non-matching paths
  guard fileName.lowercased().contains(searchQuery) else { continue }

  // Append item data
  sfItems.append([
    "type": "file:skipcheck",
    "title": fileName,
    "subtitle": (filePath as NSString).abbreviatingWithTildeInPath,
    "icon": ["path": filePath, "type": "fileicon"],
    "arg": filePath,
  ])
}

// JSON
if sfItems.isEmpty {
  print("{\"items\":[{\"title\":\"No paths found matching “\(searchQuery)”\",\"valid\":false}]}")
  exit(0)
}

let jsonData: Data = try JSONSerialization.data(withJSONObject: ["items": sfItems])
let jsonString: String = String(data: jsonData, encoding: .utf8)!
print(jsonString)
