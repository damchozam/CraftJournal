import SwiftUI
import CoreData
import UIKit

struct EntryDetailView: View {

    @ObservedObject var entry: CraftEntry

    @State private var showingEditView = false

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 12) {

                if let photoData = entry.photo,
                   let image = UIImage(data: photoData) {

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                }

                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()

                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                if let location = entry.location,
                   !location.isEmpty {

                    Label(location, systemImage: "location")
                }

                if let date = entry.date {
                    Text(date, style: .date)
                }

                Text(entry.notes ?? "")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            ToolbarItem(placement: .topBarTrailing) {

                Button("Edit") {
                    showingEditView = true
                }
            }
        }
        .sheet(isPresented: $showingEditView) {

            EditEntryView(entry: entry)
        }
    }
}
