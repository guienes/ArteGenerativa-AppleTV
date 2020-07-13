//
//  Memory+CoreDataProperties.swift
//  TestingAppleTV
//
//  Created by Lia Kassardjian on 13/07/20.
//  Copyright © 2020 Guilherme Enes. All rights reserved.
//
//

import Foundation
import CoreData


extension Memory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Memory> {
        return NSFetchRequest<Memory>(entityName: "Memory")
    }

    @NSManaged public var set: String?
    @NSManaged public var image: Data?

}
