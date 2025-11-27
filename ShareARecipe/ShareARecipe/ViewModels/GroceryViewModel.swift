//
//  GroceryViewModel.swift
//  ShareARecipe
//
//  Created by user286005 on 11/22/25.
//


import Foundation
import FirebaseFirestore

@MainActor
final class GroceryViewModel: ObservableObject {

    @Published var lists: [GroceryList] = []

    private let db = FirebaseManager.shared.db
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    func listenLists(for userID: String) {
        listener?.remove()
        
        listener = db.collection("groceryLists")
            .whereField("userID", isEqualTo: userID)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err { print("Error:", err.localizedDescription); return }

                guard let docs = snap?.documents else { return }

                let loaded = docs.compactMap { doc -> GroceryList? in
                    let d = doc.data()

                    let itemsArray = d["items"] as? [[String: Any]] ?? []
                    let items: [GroceryItem] = itemsArray.compactMap { item in
                        GroceryItem(
                            id: item["id"] as? String ?? UUID().uuidString,
                            name: item["name"] as? String ?? "",
                            isChecked: item["isChecked"] as? Bool ?? false,
                            category: item["category"] as? String ?? "Other"
                        )
                    }

                    return GroceryList(
                        id: d["id"] as? String ?? doc.documentID,
                        userID: d["userID"] as? String ?? "",
                        title: "",
                        items: items,
                        createdAt: (d["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }

                self.lists = loaded
            }
    }

    private func detectCategory(for name: String) -> String {
        let lower = name.lowercased()

        let vegetables = ["onion","tomato","carrot","potato","spinach","broccoli","lettuce","cabbage"]
        if vegetables.contains(where: lower.contains) { return "Vegetables" }

        let fruits = ["apple","banana","orange","mango","grape","berries"]
        if fruits.contains(where: lower.contains) { return "Fruits" }

        let meats = ["chicken","beef","pork","fish","salmon","shrimp"]
        if meats.contains(where: lower.contains) { return "Meat & Fish" }

        let dairy = ["milk","cheese","butter","yogurt","egg","cream"]
        if dairy.contains(where: lower.contains) { return "Dairy & Eggs" }

        let grains = ["rice","pasta","flour","bread","noodles","oats"]
        if grains.contains(where: lower.contains) { return "Grains & Pasta" }

        let spices = ["cumin","turmeric","salt","pepper","masala","oregano","basil"]
        if spices.contains(where: lower.contains) { return "Spices & Herbs" }

        let condiments = ["ketchup","sauce","vinegar","mustard","soy"]
        if condiments.contains(where: lower.contains) { return "Condiments & Sauces" }

        let baking = ["sugar","yeast","baking","chocolate"]
        if baking.contains(where: lower.contains) { return "Baking" }

        return "Other"
    }

    func createListFromRecipe(recipe: Recipe, userID: String) async {

        let parts = parseIngredients(from: recipe.ingredients)

        let items: [GroceryItem] = parts.map { name in
            GroceryItem(
                name: name,
                isChecked: false,
                category: detectCategory(for: name)
            )
        }

        let listID = UUID().uuidString

        let itemsData = items.map { item in
            [
                "id": item.id,
                "name": item.name,
                "isChecked": item.isChecked,
                "category": item.category
            ]
        }

        let data: [String: Any] = [
            "id": listID,
            "userID": userID,
            "title": "",
            "createdAt": Timestamp(date: Date()),
            "items": itemsData
        ]

        do {
            try await db.collection("groceryLists").document(listID).setData(data)
        } catch {
            print("Error saving list:", error.localizedDescription)
        }
    }

    func toggleItem(in list: GroceryList, item: GroceryItem) async {
        var updated = list.items
        guard let i = updated.firstIndex(where: { $0.id == item.id }) else { return }
        updated[i].isChecked.toggle()
        saveItems(updated, in: list)
    }

    func clearCheckedItems(in list: GroceryList) async {
        let updated = list.items.filter { !$0.isChecked }
        saveItems(updated, in: list)
    }

    func removeItem(_ item: GroceryItem, from list: GroceryList) async {
        let updated = list.items.filter { $0.id != item.id }
        saveItems(updated, in: list)
    }

    func removeItems(at offsets: IndexSet, from list: GroceryList) async {
        var updated = list.items
        updated.remove(atOffsets: offsets)
        saveItems(updated, in: list)
    }

    func deleteList(_ list: GroceryList) async {
        try? await db.collection("groceryLists").document(list.id).delete()
    }

    private func saveItems(_ items: [GroceryItem], in list: GroceryList) {
        let data = items.map {
            [
                "id": $0.id,
                "name": $0.name,
                "isChecked": $0.isChecked,
                "category": $0.category
            ]
        }

        Task {
            try? await db.collection("groceryLists")
                .document(list.id)
                .updateData(["items": data])
        }
    }

    private func parseIngredients(from text: String) -> [String] {
        text.components(separatedBy: CharacterSet(charactersIn: "\n,;"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
