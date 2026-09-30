import SwiftUI
import CoreData
import UIKit

struct ContentView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CraftEntry.date, ascending: false)],
        animation: .default)
    private var entries: FetchedResults<CraftEntry>

    @State private var showingAddEntry = false
    @State private var searchText = ""
    @State private var newestFirst = true

    private var filteredEntries: [CraftEntry] {

        let filtered: [CraftEntry]

        if searchText.isEmpty {
            filtered = Array(entries)
        } else {
            filtered = entries.filter {
                ($0.title ?? "")
                    .localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered.sorted {
            if newestFirst {
                return ($0.date ?? Date.distantPast) >
                       ($1.date ?? Date.distantPast)
            } else {
                return ($0.date ?? Date.distantPast) <
                       ($1.date ?? Date.distantPast)
            }
        }
    }

    var body: some View {

        NavigationStack {

            List {

                if entries.isEmpty {

                    VStack(spacing: 8) {

                        Text("No craft entries yet.")
                            .font(.headline)

                        Text("Tap + to add your first entry.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                ForEach(filteredEntries) { entry in

                    NavigationLink {

                        EntryDetailView(entry: entry)

                    } label: {

                        EntryRow(entry: entry)
                    }
                }
                .onDelete(perform: deleteEntries)
            }
            .navigationTitle("Craft Journal (\(entries.count))")

            .searchable(
                text: $searchText,
                prompt: "Search entries"
            )

            .toolbar {

                ToolbarItem(placement: .topBarLeading) {

                    Button {

                        newestFirst.toggle()

                    } label: {

                        Label(
                            newestFirst ? "Newest" : "Oldest",
                            systemImage: "arrow.up.arrow.down"
                        )
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {

                    Button {

                        showingAddEntry = true

                    } label: {

                        Label("Add", systemImage: "plus")
                    }
                }
            }

            .sheet(isPresented: $showingAddEntry) {

                AddEntryView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteEntries(offsets: IndexSet) {

        offsets.map { entries[$0] }.forEach(viewContext.delete)

        do {
            try viewContext.save()
        } catch {
            print("Could not delete: \(error)")
        }
    }
}

struct EntryRow: View {

    @ObservedObject var entry: CraftEntry

    var body: some View {

        HStack {

            if let photoData = entry.photo,
               let image = UIImage(data: photoData) {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            }

            VStack(alignment: .leading) {

                Text(entry.title ?? "Untitled")
                    .font(.headline)

                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let location = entry.location,
                   !location.isEmpty {

                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {

    ContentView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
