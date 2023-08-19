//
//  CoreDataManager.swift
//  MusicAppWithCoreData
//
//  Created by 김건우 on 2023/08/17.
//

import UIKit
import CoreData

// MARK: - 코어 데이터 CRUD를 지원하는 클래스 모델

final class CoreDataManager {
    
    // 싱글톤으로 구현
    static let shared = CoreDataManager()
    private init() { }
    
    // 앱 델리게이트 선언
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    // 임시저장소 선언
    lazy var context = appDelegate?.viewContext
    
    typealias DataCompletion = () -> Void
    
    // 엔터티 이름 선언
    let modelName = "MusicSaved"
    
    // MARK: - [READ] 코어 데이터에 저장된 데이터 모두 읽어오기
    func getMusicSavedArrayFromCoreData() -> [MusicSaved] {
        var savedMusicArray: [MusicSaved] = []
        // 임시 저장소가 있는지 확인하기
        if let context = context {
            // 데이터 요청서 정의하기
            let request = NSFetchRequest<NSManagedObject>(entityName: modelName)
            // 요청서에 정렬 순서 정의하기 (저장 날짜를 기준으로 오름차순으로 정렬)
            request.sortDescriptors = [NSSortDescriptor(key: "savedDate", ascending: true)]
            
            do {
                // 임시 저장소에서 데이터 가져오기
                if let fetchedMusicArray = try context.fetch(request) as? [MusicSaved] {
                    savedMusicArray = fetchedMusicArray
                }
            } catch {
                print("Error: 데이터 읽기 실패")
            }
        }
        
        return savedMusicArray
    }
    
    // MARK: - [CREATE] 코어 데이터에 데이터 생성하기
    func saveMusic(with music: Music, message: String?, completionHandler: DataCompletion) {
        // 임시 저장소가 있는지 확인하기
        if let context = context {
            // 임시 저장소에 있는 엔터티(데이터 구조) 파악하기
            if let entity = NSEntityDescription.entity(forEntityName: self.modelName, in: context) {
                // 해당 엔터티로 실제 데이터를 저장할 객체 생성하기
                if let musicSaved = NSManagedObject(entity: entity, insertInto: context) as? MusicSaved {
                    // musicSaved 객체에 실제 데이터 할당하기
                    musicSaved.songName = music.songName
                    musicSaved.artistName = music.artistName
                    musicSaved.albumName = music.albumName
                    musicSaved.imageUrl = music.imageUrl
                    musicSaved.releaseDate = music.releaseDateString
                    musicSaved.savedDate = Date()
                    musicSaved.myMessage = message
                    
                    // 임시 저장소에 변화가 포착되면
                    if context.hasChanges {
                        do {
                            // 영구 저장소에 해당 변화를 저장하기(동기적)
                            try context.save()
                            completionHandler()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - [DELETE] 코어 데이터에서 데이터 삭제하기
    func deleteMusic(with music: MusicSaved, completionHandler: DataCompletion) {
        // 저장 날짜를 옵셔널 바인딩하기
        guard let savedDate = music.savedDate else {
            completionHandler()
            return
        }
        // 임시 저장소가 있는지 확인하기
        if let context = context {
            // 데이터 요청서 정의하기
            let request = NSFetchRequest<NSManagedObject>(entityName: self.modelName)
            // 요청서에 조건 설정하기 (savedDate가 동일한 데이터 찾기)
            request.predicate = NSPredicate(format: "savedDate = %@", savedDate as CVarArg)
            
            do {
                // 임시 저장소에서 해당 조건에 맞는 데이터 가쟈오기
                if let fetchedMusicArray = try context.fetch(request) as? [MusicSaved] {
                    // 삭제하고자 하는 데이터 특정하기
                    if let targetMusic = fetchedMusicArray.first {
                        // 임시 저장소에서 특정 데이터 삭제하기
                        context.delete(targetMusic)
                        
                        // 임시 저장소에 변화가 포착되면
                        if context.hasChanges {
                            do {
                                // 영구 저장소에 해당 변화 저장하기(동기적)
                                try context.save()
                                completionHandler()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            } catch {
                print("Error: 데이터 삭제 실패")
            }
        }
    }
    
    // MARK: - [UPDATE] 코어데이터에서 데이터 수정하기
    func updateMusic(with music: MusicSaved, completionHandler: DataCompletion) {
        // 저장 날짜를 옵셔널 바인딩하기
        guard let savedDate = music.savedDate else {
            completionHandler()
            return
        }
        // 임시 저장소가 있는지 확인하기
        if let context = context {
            // 데이터 요청서 정의하기
            let request = NSFetchRequest<NSManagedObject>(entityName: self.modelName)
            // 요청서에 조건 설정하기 (savedData가 동일한 데이터 찾기)
            request.predicate = NSPredicate(format: "savedDate = %@", savedDate as CVarArg)
            
            do {
                // 임시 저장소에서 해당 조건에 맞는 데이터 가져오기
                if let fetchedMusicArray = try context.fetch(request) as? [MusicSaved] {
                    // 수정하고자 하는 데이터 특정하기
                    if var targetMusic = fetchedMusicArray.first {
                        // 임시 저장소에서 특정 데이터 수정하기
                        targetMusic = music
                        
                        // 임시 저장소에 변화가 포착되면
                        if context.hasChanges {
                            do {
                                try context.save()
                                completionHandler()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            } catch {
                print("Error: 데이터 업데이트 실패")
            }
        }
    }
}
