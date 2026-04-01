//
//  WishlistService.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/31/26.
//

import CoreData
import FirebaseFirestore

class WishlistService: ObservableObject {
    private let db = Firestore.firestore()


    func checkIfSaved(placeName: String, context: NSManagedObjectContext) -> Bool {
        let request: NSFetchRequest<BucketItem> = BucketItem.fetchRequest()
        request.predicate = NSPredicate(format: "placeName == %@", placeName)
        return (try? context.count(for: request) ?? 0) ?? 0 > 0
    }


    func add(
        placeName: String,
        address: String,
        vibeRawValue: String,
        currentUserId: String,
        context: NSManagedObjectContext
    ) {
        let itemId   = UUID()
        let savedDate = Date()

        // CoreData
        let newItem       = BucketItem(context: context)
        newItem.id        = itemId
        newItem.placeName = placeName
        newItem.address   = address
        newItem.vibeTag   = vibeRawValue
        newItem.dateSaved = savedDate
        saveContext(context)

        let data: [String: Any] = [
            "placeName": placeName,
            "address":   address,
            "vibeTag":   vibeRawValue,
            "dateSaved": savedDate.timeIntervalSince1970
        ]
        db.collection("users").document(currentUserId)
            .collection("wishlist").document(itemId.uuidString)
            .setData(data)
    }


    func remove(
        item: BucketItem,
        currentUserId: String,
        context: NSManagedObjectContext
    ) {
        // Firestore
        if let id = item.id?.uuidString {
            db.collection("users").document(currentUserId)
                .collection("wishlist").document(id)
                .delete()
        }

        // CoreData
        context.delete(item)
        saveContext(context)
    }


    func removeByPlaceName(
        placeName: String,
        currentUserId: String,
        context: NSManagedObjectContext
    ) {
        let request: NSFetchRequest<BucketItem> = BucketItem.fetchRequest()
        request.predicate = NSPredicate(format: "placeName == %@", placeName)
        guard let results = try? context.fetch(request) else { return }
        for item in results {
            if let id = item.id?.uuidString {
                db.collection("users").document(currentUserId)
                    .collection("wishlist").document(id)
                    .delete()
            }
            context.delete(item)
        }
        saveContext(context)
    }


    private func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        try? context.save()
    }
}
