//
//  QrCode+CoreDataProperties.swift
//  QrCodeScanner
//
//  Created by Илья on 22.03.2023.
//
//

import Foundation
import CoreData


extension QrCode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QrCode> {
        return NSFetchRequest<QrCode>(entityName: "QrCode")
    }

    @NSManaged public var name: String?
    @NSManaged public var image: Data?
    @NSManaged public var date: String?

}

extension QrCode : Identifiable {

}
