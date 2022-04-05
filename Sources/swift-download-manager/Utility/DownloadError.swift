//
//  DownloadError.swift
//  DownloadManager
//
//  Created by Vincent Berihuete on 23/03/2022.
//

import Foundation

enum DownloadError: Error, Equatable {
    case generic
    case invalidUrl
    case invalidResumeData
    case loadEntity
}
