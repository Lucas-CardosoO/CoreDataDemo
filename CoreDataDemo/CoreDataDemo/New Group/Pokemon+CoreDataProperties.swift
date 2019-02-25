//
//  Pokemon+CoreDataProperties.swift
//  CoreDataDemo
//
//  Created by Lucas Cardoso on 21/02/19.
//  Copyright © 2019 Lucas Cardoso. All rights reserved.
//
//

import Foundation
import CoreData


extension Pokemon {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pokemon> {
        return NSFetchRequest<Pokemon>(entityName: "Pokemon")
    }

    @NSManaged public var name: String?
    @NSManaged public var owned: Person?

}
