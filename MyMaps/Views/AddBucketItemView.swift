//
//  AddBucketItemView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/28/26.
//


import SwiftUI
import CoreData
import FirebaseFirestore
import FirebaseAuth

struct AddBucketItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    let name: String
    let address: String
    
    @State private var vibeTag = "General"
    let vibes = ["General", "Coffee", "Food", "Date Night", "Study", "Chill"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Location Details") {
                    LabeledContent("Name", value: name)
                    LabeledContent("Address", value: address)
                }
                
                Section("Vibe Tag") {
                    Picker("Select a vibe", selection: $vibeTag) {
                        ForEach(vibes, id: \.self) { vibe in
                            Text(vibe).tag(vibe)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Add to Bucket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveToBucket()
                    }
                }
            }
        }
    }

    private func saveToBucket() {
        let itemId = UUID()
        let savedDate = Date()

        let newItem = BucketItem(context: viewContext)
        newItem.placeName = name
        newItem.address = address
        newItem.vibeTag = vibeTag
        newItem.dateSaved = savedDate
        newItem.id = itemId

        do {
            try viewContext.save()
            mirrorToFirestore(id: itemId, date: savedDate)
            dismiss()
        } catch {
            print("DEBUG: Failed to save place: \(error.localizedDescription)")
        }
    }

    private func mirrorToFirestore(id: UUID, date: Date) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let data: [String: Any] = [
            "placeName": name,
            "address": address,
            "vibeTag": vibeTag,
            "dateSaved": date.timeIntervalSince1970
        ]
        Firestore.firestore()
            .collection("users").document(uid)
            .collection("wishlist").document(id.uuidString)
            .setData(data) { error in
                if let error = error {
                    print("DEBUG: Firestore wishlist sync failed: \(error.localizedDescription)")
                }
            }
    }
}
