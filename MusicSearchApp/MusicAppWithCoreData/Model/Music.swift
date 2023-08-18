//
//  Music.swift
//  MusicAppWithCoreData
//
//  Created by 김건우 on 2023/08/17.
//

import UIKit

// MARK: - 데이터 모델

// 실제 API에서 받게 되는 정보

struct MusicData: Codable {
    let resultCount: Int
    let results: [Music]
}

// 실제 우리가 사용하게 될 음악(Music) 모델 클래스
// (저장 여부를 지속적으로 관리해야되기에 클래스로 만듦)

final class Music: Codable {
    let songName: String?
    let artistName: String?
    let albumName: String?
    let previewUrl: String?
    let imageUrl: String?
    private let releaseDate: String?
    var isSaved: Bool = false
    
    // API에서 넘겨주는 키값을 케이스 명으로 변경
    enum CodingKeys: String, CodingKey {
        case songName = "trackName"
        case artistName
        case albumName = "collectionName"
        case previewUrl
        case imageUrl = "artworkUrl100"
        case releaseDate
    }
    
    // ISO8601 포맷의 츨시 일자를 일반적인 포맷으로 변경
    var releaseDateString: String? {
        guard let isoDate = ISO8601DateFormatter().date(from: releaseDate ?? "") else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let releaseDateString = formatter.string(from: isoDate)
        return releaseDateString
    }
}
