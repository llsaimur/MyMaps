//
//  NextUpBucketView.swift
//  MyMaps
//
//  Created by Saimur Rashid on 3/23/26.
//

import SwiftUI
import CoreData

struct NextUpBucketView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BucketItem.dateSaved, ascending: false)],
        animation: .default)
    private var bucketItems: FetchedResults<BucketItem>

    var body: some View {
        NavigationStack {
            Group {
                if bucketItems.isEmpty {
                    ContentUnavailableView {
                        Label("Your Bucket is Empty", systemImage: "list.star")
                    } description: {
                        Text("When you see a vibe you like, tap the bookmark to save it here for later.")
                    }
                } else {
                    List {
                        ForEach(bucketItems) { item in
                            WishlistItemRow(item: item)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Next-Up Bucket")
        }
    }
}
