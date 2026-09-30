import SwiftUI
import CoreData

struct EditEntryView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var entry: CraftEntry

    @State private var title = ""
    @State private var craftType = ""
    @State private var notes = ""
    @State private var location = ""

    var body: some View {

        NavigationStack {

            Form {

                TextField("Title", text: $title)

                TextField("Notes", text: $notes, axis: .vertical)

                TextField("Location", text: $location)

                Picker("Craft", selection: $craftType) {
                    ForEach(crafts, id: \.self) { craft in
                        Text(craft)
                    }
                }
            }
            .navigationTitle("Edit Entry")
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
            .onAppear {
                title = entry.title ?? ""
                craftType = entry.craftType ?? crafts[0]
                notes = entry.notes ?? ""
                location = entry.location ?? ""
            }
        }
    }

    private func saveChanges() {

        entry.title = title
        entry.craftType = craftType
        entry.notes = notes
        entry.location = location

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not save changes: \(error)")
        }
    }
}
