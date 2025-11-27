//
//  GroceryListView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/22/25.
//


import SwiftUI

struct GroceryListView: View {

    @EnvironmentObject var groceryVM: GroceryViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {

            List {
                
                ForEach(groceryVM.lists, id: \.id) { list in

                    let grouped = Dictionary(grouping: list.items) { $0.category }

                    ForEach(grouped.keys.sorted(), id: \.self) { category in

                        Section(header: Text(category).font(.headline)) {

                            ForEach(grouped[category]!, id: \.id) { item in

                                HStack {

                                    Button {
                                        Task { await groceryVM.toggleItem(in: list, item: item) }
                                    } label: {
                                        Image(systemName: item.isChecked ?
                                              "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isChecked ? .green : .gray)
                                    }
                                    .buttonStyle(.plain)

                                    Text(item.name)
                                        .strikethrough(item.isChecked)
                                        .foregroundColor(item.isChecked ? .gray : .primary)

                                    Spacer()

                                    Button {
                                        Task { await groceryVM.removeItem(item, from: list) }
                                    } label: {
                                        Image(systemName: "trash").foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }

                            }
                            .onDelete { indexSet in
                                Task { await groceryVM.removeItems(at: indexSet, from: list) }
                            }
                        }
                    }

                    .swipeActions {
                        Button(role: .destructive) {
                            Task { await groceryVM.deleteList(list) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Grocery List")
        }
        .onAppear {
            if let uid = authVM.user?.uid {
                groceryVM.listenLists(for: uid)
            }
        }
    }
}
