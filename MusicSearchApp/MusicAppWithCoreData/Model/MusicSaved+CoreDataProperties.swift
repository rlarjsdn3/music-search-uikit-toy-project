//
//  MusicSaved+CoreDataProperties.swift
//  MusicAppWithCoreData
//
//  Created by 김건우 on 2023/08/17.
//
//

import Foundation
import CoreData

extension MusicSaved {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MusicSaved> {
        return NSFetchRequest<MusicSaved>(entityName: "MusicSaved")
    }

    @NSManaged public var songName: String?
    @NSManaged public var albumName: String?
    @NSManaged public var artistName: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var previewUrl: String?
    @NSManaged public var myMessage: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var savedDate: Date?
    
    var savedDateString: String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = savedDate else { return "" }
        let savedDateString = formatter.string(from: date)
        return savedDateString
    }
    
}

extension MusicSaved : Identifiable {

}
