import SwiftUI

struct CalendarViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var viewModel: TodoListViewModel
    
    func makeUIViewController(context: Context) -> CalendarViewController {
        return CalendarViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
        uiViewController.loadData()
    }
}
