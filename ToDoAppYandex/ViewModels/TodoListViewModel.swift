import Foundation
import SwiftUI
import CocoaLumberjackSwift

class TodoListViewModel: ObservableObject {
    private let logger = DDLog()
    private let networkingService: NetworkingService
    
    @Published var todoItems: [TodoItem] = []
    @Published var isDirty: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    init(networkingService: NetworkingService = DefaultNetworkingService()) {
        self.networkingService = networkingService
        loadItems()
    }
    
    func loadItems() {
        isLoading = true
        error = nil
        networkingService.getItems { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.todoItems = items
                    self?.isDirty = false
                    DDLogInfo("Successfully loaded \(items.count) items")
                case .failure(let error):
                    DDLogError("Failed to load items: \(error)")
                    self?.isDirty = true
                    self?.error = "Не удалось загрузить задачи: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func addTodoItem(_ item: TodoItem) {
        isLoading = true
        error = nil
        networkingService.addItem(item) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let newItem):
                    self?.todoItems.append(newItem)
                    self?.isDirty = false
                    DDLogInfo("Added new todo item: \(newItem.text)")
                case .failure(let error):
                    DDLogError("Failed to add item: \(error)")
                    self?.todoItems.append(item)
                    self?.isDirty = true
                    self?.error = "Не удалось добавить задачу: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func updateTodoItem(_ item: TodoItem) {
        guard let index = todoItems.firstIndex(where: { $0.id == item.id }) else {
            DDLogError("Failed to find index for item with id: \(item.id)")
            return
        }
        
        isLoading = true
        error = nil
        networkingService.updateItem(item) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let updatedItem):
                    if let index = self?.todoItems.firstIndex(where: { $0.id == updatedItem.id }) {
                        self?.todoItems[index] = updatedItem
                    }
                    self?.isDirty = false
                    DDLogInfo("Updated todo item: \(updatedItem.text)")
                case .failure(let error):
                    DDLogError("Failed to update item: \(error)")
                    if let index = self?.todoItems.firstIndex(where: { $0.id == item.id }) {
                        self?.todoItems[index] = item
                    }
                    self?.isDirty = true
                    if case let .httpError(statusCode) = error {
                        self?.error = "Ошибка сервера при обновлении: \(statusCode)"
                    } else {
                        self?.error = "Не удалось обновить задачу: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    func deleteTodoItem(_ item: TodoItem) {
        isLoading = true
        error = nil
        networkingService.deleteItem(item.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.todoItems.removeAll { $0.id == item.id }
                    self?.isDirty = false
                    DDLogInfo("Deleted todo item: \(item.text)")
                case .failure(let error):
                    DDLogError("Failed to delete item: \(error)")
                    self?.isDirty = true
                    self?.error = "Не удалось удалить задачу: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func synchronize() {
        guard isDirty else { return }
        
        isLoading = true
        error = nil
        networkingService.patchList(todoItems) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let updatedItems):
                    self?.todoItems = updatedItems
                    self?.isDirty = false
                    DDLogInfo("Successfully synchronized \(updatedItems.count) items")
                case .failure(let error):
                    DDLogError("Failed to synchronize items: \(error)")
                    self?.isDirty = true
                    if case let .httpError(statusCode) = error {
                        self?.error = "Ошибка сервера при синхронизации: \(statusCode)"
                    } else {
                        self?.error = "Не удалось синхронизировать задачи: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}

