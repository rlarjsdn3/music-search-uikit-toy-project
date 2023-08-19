//
//  MusicManager.swift
//  MusicAppWithCoreData
//
//  Created by 김건우 on 2023/08/17.
//

import Foundation

// MARK: - 전체 데이터 관리 클래스 모델

final class MusicManager {
    
    // 싱글톤으로 구현
    static let shared = MusicManager()
    private init() {
        // 코어 데이터로부터 저장된 데이터 불러오기
        setupDatasFromCoreData {
            print("코어 데이터로부터 찜한 음악 데이터 불러오기 성공")
        }
    }
    
    typealias MusicCompletion = () -> Void
    
    // 네트워크 매니저 (싱글톤)
    let networkManager = NetworkManager.shared
    
    // 코어 데이터 매니저 (싱글톤)
    let coreDataManager = CoreDataManager.shared
    
    // API로부터 받아온 음악 데이터를 저장하는 배열 선언
    private var musicArrays: [Music] = []
    
    // 코어 데이터로부터 받아온 음악 데이터를 저장하는 배열 선언
    private var musicSavedArrays: [MusicSaved] = []
    
    //  API로부터 받아온 음악 데이터를 반환하는 메서드
    func getMusicArrayFromAPI() -> [Music] {
        return musicArrays
    }
    
    // 코어 데이터로부터 받아온 음악 데이터를 반환하는 메서드
    func getMusicArrayFromCoreData() -> [MusicSaved] {
        return musicSavedArrays
    }
    
    // MARK: - API와 통신 관련 메서드
    
    // 기본 단어로 음악 데이터 요청하기
    func setupDatasFromAPI(completionHandler: @escaping MusicCompletion) {
        getDatasFromAPI(with: "jazz") {
            completionHandler()
        }
    }
    
    // 특정 단어로 검색해 음악 데이터 요청하기
    func fetchDatasFromAPI(with searchTerm: String, completionHandler: @escaping MusicCompletion) {
        getDatasFromAPI(with: searchTerm) {
            completionHandler()
        }
    }
    
    // API에 음악 데이터 요청하기
    private func getDatasFromAPI(with searchTerm: String, completionHandler: @escaping MusicCompletion) {
        networkManager.fetchMusic(searchTerm: searchTerm) { result in
            switch result {
            case .success(let musicDatas):
                self.musicArrays = musicDatas
            case .failure(let error):
                print(error.localizedDescription)
            }
            self.checkWhetherSaved()
            completionHandler()
        }
    }
    
    // MARK: - 코어 데이터 CRUD 관련 메서드
    
    // 코어 데이터에서 음악 데이터를 불러와 셋팅하는 메서드
    private func setupDatasFromCoreData(completionHandler: @escaping MusicCompletion) {
        self.fetchMusicsFromCoreData {
            completionHandler()
        }
    }
    
    // 찜한 음악 데이터 추가하기 (CREATE)
    func saveMusic(with music: Music, message: String?, completionHandler: @escaping MusicCompletion) {
        // 해당 객체를 찝한 도서에 저장하고
        coreDataManager.saveMusic(with: music, message: message) {
            // 변경된 사항을 다시 불러와 musicSavedArrays 변수에 저장
            self.fetchMusicsFromCoreData {
                completionHandler()
            }
        }
    }
    
    // 찜한 음악 데이터 삭제하기 (DELETE) - 도서 검색 탭에서 삭제하기
    func deleteMusicFromCoreData(with music: Music, completionHandler: @escaping MusicCompletion) {
        // 해당 객체가 찜한 도서에 저장되어 있는지 확인하기
        let musicSaved = musicSavedArrays.filter {
            ($0.songName == music.songName) && ($0.artistName == music.artistName)
        }
        
        // 필터링한 배열의 첫 번째 요소 가져오기
        if let targetMusicSaved = musicSaved.first {
            self.deleteMusicFromCoreData(with: targetMusicSaved) {
                completionHandler()
            }
        }
    }
    
    // 찜한 음악 데이터 삭제하기 (DELETE) - 찜한 음악 탭에서 삭제하기
    func deleteMusicFromCoreData(with music: MusicSaved, completionHandler: @escaping MusicCompletion) {
        // 매개변수로 넘겨준 객체를 삭제하고
        coreDataManager.deleteMusic(with: music) {
            // 변경된 사항을 다시 불러와 musicSavedArrays 변수에 저장
            self.fetchMusicsFromCoreData {
                completionHandler()
            }
        }
    }
    
    // 찜한 음악 데이터 수정하기 (UPDATE)
    func updateMusicToCoreData(with music: MusicSaved, completionHandler: @escaping MusicCompletion) {
        // 매개변수로 넘겨준 객체로 데이터를 수정하고
        coreDataManager.updateMusic(with: music) {
            // 변경된 사항을 다시 불러와 musicSavedArrays 변수에 저장
            self.fetchMusicsFromCoreData {
                completionHandler()
            }
        }
    }
    
    // 찜한 음악 데이터 불러오기 (READ)
    private func fetchMusicsFromCoreData(completionHandler: MusicCompletion) {
        self.musicSavedArrays = coreDataManager.getMusicSavedArrayFromCoreData()
        completionHandler()
    }
    
    // 이미 저장된 데이터인지 확인하는 메서드 (찜한 도서에 추가된 데이터인지 확인하기 위해)
    func checkWhetherSaved() {
        musicArrays.forEach { music in
            // 코더 데이터에 저장된 데이터인지 하나씩 순회하며 확인
            if musicSavedArrays.contains(where: {
                ($0.songName == music.songName) && ($0.artistName == music.artistName)
            }) {
                // 찜한 상태라고 설정
                music.isSaved = true
            } else {
                // 찜하지 않은 상태라고 설정
                music.isSaved = false
            }
        }
    }
}
