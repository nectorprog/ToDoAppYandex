import Foundation
import SwiftUI
import CocoaLumberjackSwift

@MainActor
class TodoListViewModel: ObservableObject {
    private let logger = DDLog()
    private let networkingService: NetworkingService
    private let fileCache: FileCache
    
    @Published var todoItems: [TodoItem] = []
    @Published var isDirty: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    init(networkingService: NetworkingService = DefaultNetworkingService()) {
        self.networkingService = networkingService
        self.fileCache = FileCache()
        loadItems()
    }
    
    @MainActor func loadItems() {
        isLoading = true
        error = nil
        
        // Загрузка из локальной базы данных
        todoItems = fileCache.fetch()
        
        // Загрузка с сервера
        networkingService.getItems { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let items):
                    self?.updateLocalItems(with: items)
                    DDLogInfo("Successfully loaded \(items.count) items")
                case .failure(let error):
                    DDLogError("Failed to load items: \(error)")
                    self?.isDirty = true
                    self?.error = "Не удалось загрузить задачи: \(error.localizedDescription)"
                }
            }
        }
    }
    
    @MainActor private func updateLocalItems(with serverItems: [TodoItem]) {
        for serverItem in serverItems {
            if let localItem = todoItems.first(where: { $0.id == serverItem.id }) {
                // Обновляем существующий элемент
                localItem.text = serverItem.text
                localItem.importance = serverItem.importance
                localItem.deadline = serverItem.deadline
                localItem.isReady = serverItem.isReady
                localItem.updatedAt = serverItem.updatedAt
                localItem.color = serverItem.color
                localItem.category = serverItem.category
                localItem.lastUpdatedBy = serverItem.lastUpdatedBy
                fileCache.update(localItem)
            } else {
                // Добавляем новый элемент
                fileCache.insert(serverItem)
                todoItems.append(serverItem)
            }
        }
        
        // Удаляем элементы, которых нет на сервере
        todoItems.forEach { localItem in
            if !serverItems.contains(where: { $0.id == localItem.id }) {
                fileCache.delete(localItem)
                todoItems.removeAll { $0.id == localItem.id }
            }
        }
        
        isDirty = false
    }
    
    func addTodoItem(_ item: TodoItem) {
        isLoading = true
        error = nil
        networkingService.addItem(item) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let newItem):
                    self?.fileCache.insert(newItem)
                    self?.todoItems.append(newItem)
                    self?.isDirty = false
                    DDLogInfo("Added new todo item: \(newItem.text)")
                case .failure(let error):
                    DDLogError("Failed to add item: \(error)")
                    self?.fileCache.insert(item)
                    self?.todoItems.append(item)
                    self?.isDirty = true
                    self?.error = "Не удалось добавить задачу: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func updateTodoItem(_ item: TodoItem) {
        isLoading = true
        error = nil
        networkingService.updateItem(item) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let updatedItem):
                    if let index = self?.todoItems.firstIndex(where: { $0.id == updatedItem.id }) {
                        self?.todoItems[index] = updatedItem
                        self?.fileCache.update(updatedItem)
                    }
                    self?.isDirty = false
                    DDLogInfo("Updated todo item: \(updatedItem.text)")
                case .failure(let error):
                    DDLogError("Failed to update item: \(error)")
                    if let index = self?.todoItems.firstIndex(where: { $0.id == item.id }) {
                        self?.todoItems[index] = item
                        self?.fileCache.update(item)
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
                    self?.fileCache.delete(item)
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
                    self?.updateLocalItems(with: updatedItems)
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
