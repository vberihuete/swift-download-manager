//
//  CompletedDownload.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 17/03/2022.
//

import Foundation

struct CompletedDownload: Equatable, Codable {
    let download: Download
    let localPath: String
}
