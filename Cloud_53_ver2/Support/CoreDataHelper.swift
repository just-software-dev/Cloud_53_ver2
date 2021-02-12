//
//  CryptoHelper.swift
//  Cloud 53
//
//  Created by Андрей on 06.08.2020.
//  Copyright © 2020 oak. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper: ObservableObject {
    
    @Published private(set) var promoUpdate: Int = 0
    
    private let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private func add<SomeItem: MyEntityItem>(_ item: SomeItem, id: Int) {
        DataMonitoring.shareInstance.downloadImage(path: item.image) { data, error in
            DispatchQueue.main.async {
                self.deleteData(entity: SomeItem.entityName, id: id)
                if let error = error {
                    print("Image download error: \(error.localizedDescription)")
                } else if let data = data {
                    item.insert(context: self.context, id: id, image: data)
                    if SomeItem.self == PromoItem.self {
                        self.promoUpdate += 1
                    }
                }
            }
        }
    }
    
    func update<SomeItem: MyEntityItem>(_ list: [SomeItem]) {
        var lst = list
        lst.sort {
            $0.order < $1.order
        }
        let len = lst.count
        for i in 0 ..< len {
            add(lst[i], id: i)
        }
        deleteData(entity: SomeItem.entityName, id: len - 1, lastID: true)
    }
    
    func deleteData(entity: String, id: Int? = nil, lastID: Bool = false) {
        let managedContext = self.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        if let id = id {
            let condition = lastID ? "id > %d" : "id == %d"
            fetchRequest.predicate = NSPredicate(format: condition, Int16(id))
        }
        do {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Deleting data in \(entity)\nError: \(error) \(error.userInfo)")
        }
    }
    
    func getPromoList() -> [Promo]? {
        do {
            let results = try context.fetch(Promo.getAllItems())
            return results
        } catch {
            return nil
        }
    }
}

protocol MyEntityItem {
    var order: Int16 { get set }
    var image: String { get set }
    static var entityName: String { get }
    
    func insert(context: NSManagedObjectContext, id: Int, image: Data)
}

protocol MyEntity: NSManagedObject, Identifiable {
    
    associatedtype MyItem: MyEntityItem
    
    func set(_ item: MyItem, id: Int, image: Data)
    static func dictToItems(menu: [String: [String: Any]]) -> [MyItem]
}

struct MenuItem: MyEntityItem {
    
    func insert(context: NSManagedObjectContext, id: Int, image: Data) {
        let m = Menu(context: context)
        m.set(self, id: id, image: image)
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static let entityName = "Menu"
    
    var title: String
    var order: Int16
    var image: String
}

public class Menu: NSManagedObject, Identifiable, MyEntity {
    @NSManaged public var id: Int16
    @NSManaged public var title: String
    @NSManaged public var order: Int16
    @NSManaged public var image: Data
    
    func set(_ item: MenuItem, id: Int, image: Data) {
        self.id = Int16(id)
        self.title = item.title
        self.order = item.order
        self.image = image
    }
    
    static func getAllItems() -> NSFetchRequest<Menu> {
        let request: NSFetchRequest<Menu> = Menu.fetchRequest() as! NSFetchRequest<Menu>
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    static func dictToItems(menu: [String: [String: Any]]) -> [MenuItem] {
        var elements: [MenuItem] = []
        for (name, properties) in menu {
            guard let order = properties["order"] as? Int16, let imageName =
            properties["image"] as? String else {continue}
            elements.append(MenuItem(title: name, order: order, image: imageName))
        }
        return elements
    }
}

struct PromoItem: MyEntityItem {
    
    func insert(context: NSManagedObjectContext, id: Int, image: Data) {
        let p = Promo(context: context)
        p.set(self, id: id, image: image)
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static let entityName = "Promo"
    
    var title: String
    var order: Int16
    var image: String
    var text: String
    var big: Bool
}

public class Promo: NSManagedObject, Identifiable, MyEntity {
    
    @NSManaged public var id: Int16
    @NSManaged public var title: String
    @NSManaged public var order: Int16
    @NSManaged public var image: Data
    @NSManaged public var text: String
    @NSManaged public var big: Bool
    
    func set(_ item: PromoItem, id: Int, image: Data) {
        self.id = Int16(id)
        self.title = item.title
        self.order = item.order
        self.text = item.text
        self.big = item.big
        self.image = image
    }
    
    static func getAllItems() -> NSFetchRequest<Promo> {
        let request: NSFetchRequest<Promo> = Promo.fetchRequest() as! NSFetchRequest<Promo>
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    
    static func dictToItems(menu: [String: [String: Any]]) -> [PromoItem] {
        var elements: [PromoItem] = []
        for (name, properties) in menu {
            guard let order = properties["order"] as? Int16,
                let imageName = properties["image"] as? String,
                let text = properties["description"] as? String
            else {continue}
            let big: Bool = (properties["big"] as? Bool) ?? false
            elements.append(PromoItem(title: name, order: order, image: imageName, text: text, big: big))
        }
        return elements
    }
}
