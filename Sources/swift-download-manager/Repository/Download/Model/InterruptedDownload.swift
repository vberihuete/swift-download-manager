//
//  InterruptedDownload.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 16/03/2022.
//

import Foundation

struct InterruptedDownload: Equatable, Codable {
    let download: Download
    let resumeData: Data
}
