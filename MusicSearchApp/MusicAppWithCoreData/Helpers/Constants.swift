//
//  Constants.swift
//  MusicAppWithCoreData
//
//  Created by 김건우 on 2023/08/17.
//

import Foundation

// MARK: - 네임스페이스 만들기

// 사용하게 될 API 문자열 묶음
public enum MusicApi {
    static let requestUrl = "https://itunes.apple.com/search?"
    static let mdediaParam = "media=musci"
}

// 사용하게 될 Cell 문자열 묶음
public enum Cell {
    static let musicCellIdentifier = "MusicCell"
    static let savedMusicCellIdentifier = "SavedMusicCell"
}
