import UIKit
import SwiftUI
import CocoaLumberjackSwift

class CalendarViewController: UIViewController {
    private let viewModel: TodoListViewModel
    private let collectionView: UICollectionView
    private let tableView: UITableView
    
    private var dates: [Date?] = []
    private var todoItems: [TodoItem] = []
    private var groupedTodoItems: [Date?: [TodoItem]] = [:]
    private var selectedDateIndex: Int = 0
    
    init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.tableView = UITableView(frame: .zero, style: .grouped)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let plusImage = UIImage(systemName: "plus", withConfiguration: config)
        button.setImage(plusImage, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .cBlue
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogDebug("CalendarViewController loaded")
        setupViews()
        setupConstraints()
        loadData()
    }
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .sSeparator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func setupViews() {
        view.backgroundColor = .bPrimary
        
        collectionView.register(DateCollectionViewCell.self, forCellWithReuseIdentifier: "DateCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .bPrimary
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        view.addSubview(collectionView)
        
        view.addSubview(separatorLine)
        
        tableView.register(RoundedTableViewCell.self, forCellReuseIdentifier: "TodoCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .bPrimary
        tableView.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        view.addSubview(tableView)
        view.addSubview(addButton)
    }
    
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 90),
            
            separatorLine.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1), // Толщина линии
            
            tableView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func addButtonTapped() {
        let todoItemView = TodoItemView(isPresented: .constant(true),
                                        viewModel: viewModel,
                                        isNewTask: true,
                                        onDismiss: { [weak self] in
                                            self?.loadData()
                                            self?.dismiss(animated: true, completion: nil)
                                        })
        let hostingController = UIHostingController(rootView: todoItemView)
        present(hostingController, animated: true, completion: nil)
    }
    
    func loadData() {
        todoItems = viewModel.todoItems
        
        groupedTodoItems = Dictionary(grouping: todoItems) { item in
            if let deadline = item.deadline {
                return Calendar.current.startOfDay(for: deadline)
            } else {
                return nil
            }
        }
        
        dates = groupedTodoItems.keys.compactMap { $0 }.sorted()
        
        if groupedTodoItems[nil] != nil {
            dates.append(nil)
        }
        
        collectionView.reloadData()
        tableView.reloadData()
        
        if !dates.isEmpty {
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
            scrollToSelectedDate()
        }
    }
    
    private func scrollToSelectedDate() {
        guard selectedDateIndex < dates.count else { return }
        
        let indexPath = IndexPath(row: 0, section: selectedDateIndex)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let date = dates[indexPath.section]
        let items = groupedTodoItems[date] ?? []
        let item = items[indexPath.row]
        
        presentEditTodoItemView(for: item)
    }

    private func presentEditTodoItemView(for item: TodoItem) {
        let todoItemView = TodoItemView(isPresented: .constant(true),
                                        viewModel: viewModel,
                                        isNewTask: false,
                                        editingItem: item) { [weak self] in
            self?.loadData()
            self?.dismiss(animated: true, completion: nil)
        }
        let hostingController = UIHostingController(rootView: todoItemView)
        present(hostingController, animated: true, completion: nil)
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCollectionViewCell
        let date = dates[indexPath.item]
        cell.configure(with: date)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDateIndex = indexPath.item
        scrollToSelectedDate()
    }
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = dates[section]
        return (groupedTodoItems[date] ?? []).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = dates[section]
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM"
            formatter.locale = Locale(identifier: "ru_RU")
            return formatter.string(from: date)
        } else {
            return "Другое"
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let date = dates[indexPath.section]
        let items = groupedTodoItems[date] ?? []
        let item = items[indexPath.row]
        
        // Обновляем текст и стиль ячейки
        if item.isReady {
            let attributeString = NSMutableAttributedString(string: item.text)
            attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributeString.length))
            cell.textLabel?.attributedText = attributeString
            cell.textLabel?.textColor = .lTertiary
        } else {
            cell.textLabel?.text = item.text
            cell.textLabel?.textColor = .lPrimary
        }
        
        cell.contentView.subviews.first(where: { $0.tag == 100 })?.removeFromSuperview()
        
        // Добавляем круглый индикатор категории, если категория не "Другое"
        if item.category != .other {
            let categoryIndicator = UIView(frame: CGRect(x: cell.contentView.bounds.width - 20, y: (cell.contentView.bounds.height - 8) / 2, width: 8, height: 8))
            categoryIndicator.backgroundColor = UIColor(item.category.color)
            categoryIndicator.layer.cornerRadius = 4
            categoryIndicator.tag = 100 // Устанавливаем тег для легкого поиска и удаления
            cell.contentView.addSubview(categoryIndicator)
        }
        
        cell.backgroundColor = .bPrimary
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let date = dates[indexPath.section]
        let items = groupedTodoItems[date] ?? []
        let item = items[indexPath.row]
        
        // Не показываем действие для уже выполненных задач
        guard !item.isReady else { return nil }
        
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completion) in
            self?.toggleTaskCompletion(for: indexPath)
            completion(true)
        }
        
        action.backgroundColor = .cGreen
        
        // Создаем изображение белого кружка с зеленой галочкой
        let image = createCheckmarkImage(checkmarkColor: .cGreen, backgroundColor: .white)
        action.image = image
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // Новый метод для свайпа справа налево (возврат задачи в активное состояние)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let date = dates[indexPath.section]
        let items = groupedTodoItems[date] ?? []
        let item = items[indexPath.row]
        
        // Показываем действие только для выполненных задач
        guard item.isReady else { return nil }
        
        let action = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completion) in
            self?.toggleTaskCompletion(for: indexPath)
            completion(true)
        }
        
        action.backgroundColor = .cGray
        
        // Создаем изображение серого кружка с белым крестиком
        let image = createCheckmarkImage(checkmarkColor: .white, backgroundColor: .cGray, systemName: "xmark")
        action.image = image
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .lSecondary
            headerView.contentView.backgroundColor = .bPrimary
        }
    }
    
    private func toggleTaskCompletion(for indexPath: IndexPath) {
        let date = dates[indexPath.section]
        var items = groupedTodoItems[date] ?? []
        var item = items[indexPath.row]
        item.isReady.toggle()
        items[indexPath.row] = item
        groupedTodoItems[date] = items
        viewModel.updateTodoItem(item)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // Вспомогательный метод для создания изображения
    private func createCheckmarkImage(checkmarkColor: UIColor, backgroundColor: UIColor, systemName: String = "checkmark") -> UIImage? {
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(backgroundColor.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        let symbolSize = size.width * 0.6
        let symbolRect = CGRect(x: (size.width - symbolSize) / 2,
                                y: (size.height - symbolSize) / 2,
                                width: symbolSize,
                                height: symbolSize)
        let symbolImage = UIImage(systemName: systemName)?.withTintColor(checkmarkColor, renderingMode: .alwaysOriginal)
        symbolImage?.draw(in: symbolRect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
