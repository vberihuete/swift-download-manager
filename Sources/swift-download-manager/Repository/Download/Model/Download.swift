//
//  Download.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 16/03/2022.
//

import Foundation

struct Download: Hashable, Codable {
    let identifier: String
    let url: URL
}
