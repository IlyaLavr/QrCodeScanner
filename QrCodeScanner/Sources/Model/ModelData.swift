//
//  ModelData.swift
//  QrCodeScanner
//
//  Created by Илья on 22.03.2023.
//

import CoreData
import UIKit

class ModelData {
    var codeQr: [QrCode] = []
    
    let context = (UIApplication.shared.delegate as!
                   AppDelegate).persistentContainer.viewContext
 
    func saveContext () {
        if context.hasChanges {
            do {
                print("Save \(context)")
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getAllQrCodes() -> [QrCode] {
        let fetchRequest = NSFetchRequest<QrCode>(entityName: "QrCode")
        let sort = NSSortDescriptor(key: #keyPath(QrCode.date), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            codeQr = try context.fetch(fetchRequest)
        } catch {
            print("Cannot fetch Expenses")
        }
        return codeQr
    }
    
    func addQrCodes(name: String, date: String) {
        let data = QrCode(context: context)
        data.name = name
        data.date = date
        saveContext()
    }
    
    func deleteCode(code: QrCode) {
        context.delete(code)
        saveContext()
    }
}
