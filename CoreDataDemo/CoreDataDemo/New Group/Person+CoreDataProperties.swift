//
//  Person+CoreDataProperties.swift
//  CoreDataDemo
//
//  Created by Lucas Cardoso on 21/02/19.
//  Copyright © 2019 Lucas Cardoso. All rights reserved.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var name: String?
    @NSManaged public var owner: [Pokemon]?

}

// MARK: Generated accessors for owner
extension Person {

    @objc(addOwnerObject:)
    @NSManaged public func addToOwner(_ value: Pokemon)

    @objc(removeOwnerObject:)
    @NSManaged public func removeFromOwner(_ value: Pokemon)

    @objc(addOwner:)
    @NSManaged public func addToOwner(_ values: NSSet)

    @objc(removeOwner:)
    @NSManaged public func removeFromOwner(_ values: NSSet)

}
