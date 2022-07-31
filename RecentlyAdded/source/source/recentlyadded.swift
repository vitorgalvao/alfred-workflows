#!/usr/bin/env swift

import Foundation

// Helpers
struct GetEnvVar {
  static let env: [String: String] = ProcessInfo.processInfo.environment

  static func asBool(_ variable: String, preset: Bool) -> Bool {
    return NSString(string: env[variable] ?? String(preset)).boolValue
  }

  static func asString(_ variable: String, preset: String, matchList: Set<String> = []) -> String {
    guard let envVar: String = env[variable] else { return preset }

    if envVar.isEmpty { return preset }
    if matchList.isEmpty { return envVar }
    if matchList.contains(envVar) { return envVar }
    return preset
  }

  static func asFileURL(_ variable: String, preset: String) -> URL {
    func toFileURL(_ path: String) -> URL {
      return URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
    }

    guard let envVar: String = env[variable] else { return toFileURL(preset) }

    if envVar.isEmpty { return toFileURL(preset) }
    return toFileURL(envVar)
  }

  static func asFileURLsFromCommas(_ variable: String, preset: [String]) -> [URL] {
    guard let envVar = env[variable] else { return preset.map { asFileURL("", preset: $0) } }

    if envVar.isEmpty { return preset.map { asFileURL("", preset: $0) } }

    return
      envVar
      .components(separatedBy: ",")
      .map { asFileURL("", preset: $0.trimmingCharacters(in: .whitespacesAndNewlines)) }
  }
}

func fileSort(_ paths: [URL], byKey sortingAttribute: String) -> [URL] {
  let nilDate: Date = Date(timeIntervalSinceReferenceDate: 0)
  let dateFormatter: DateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"

  func fileDate(_ path: URL) -> Date {
    guard let date = NSMetadataItem(url: path)?.value(forAttribute: sortingAttribute) else {
      return nilDate
    }

    return dateFormatter.date(from: String(describing: date)) ?? nilDate
  }

  return
    paths
    .map { ($0, fileDate($0)) }  // Tuple of paths with dates
    .sorted(by: { $0.1.compare($1.1) == .orderedDescending })  // Sorted by date
    .map { $0.0 }  // Paths without dates
}

// Contants
let allFiles: [URL] = {
  do {
    let dirs: [URL] = GetEnvVar.asFileURLsFromCommas("directories", preset: ["~/Downloads", "~/Desktop"])
    let files: [URL] = try dirs.map { try FileManager.default.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) }.flatMap { $0 }

    if files.isEmpty {
      print("{\"items\":[{\"title\":\"No results!\",\"subtitle\":\"Your configured directories are empty\",\"valid\":false}]}")
      exit(1)
    }

    return files
  } catch {
    print("{\"items\":[{\"title\":\"Directory does not exist!\",\"subtitle\":\"Check your configured directories\",\"valid\":false}]}")
    exit(1)
  }
}()

// JSON generator
func scriptFilterJSON(_ files: [URL]) -> String {
  let items: [[String: Any]] = files.map {
    [
      "uid": $0.path,
      "type": "file:skipcheck",
      "title": $0.lastPathComponent,
      "subtitle": ($0.deletingLastPathComponent().path as NSString).abbreviatingWithTildeInPath,
      "icon": ["path": $0.path, "type": "fileicon"],
      "arg": $0.path,
    ]
  }

  let full: [String: Any] = [
    "skipknowledge": true,
    "rerun": 1,
    "items": items,
  ]

  let jsonData: Data = try! JSONSerialization.data(withJSONObject: full)
  let jsonString: String = String(data: jsonData, encoding: .utf8)!
  return jsonString
}

// Output
switch CommandLine.arguments[1] {
case "added":
  print(scriptFilterJSON(fileSort(allFiles, byKey: NSMetadataItemDateAddedKey)))
case "added_reverse":
  print(scriptFilterJSON(fileSort(allFiles, byKey: NSMetadataItemDateAddedKey).reversed()))
case "modified":
  print(scriptFilterJSON(fileSort(allFiles, byKey: NSMetadataItemContentModificationDateKey)))
case "modified_reverse":
  print(scriptFilterJSON(fileSort(allFiles, byKey: NSMetadataItemContentModificationDateKey).reversed()))
default:
  fatalError("Invalid order type. Must be 'added' or 'modified' with optional '_reversed' suffix.")
}
