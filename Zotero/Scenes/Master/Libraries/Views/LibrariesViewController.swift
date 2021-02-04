//
//  LibrariesViewController.swift
//  Zotero
//
//  Created by Michal Rentka on 10/09/2020.
//  Copyright © 2020 Corporation for Digital Scholarship. All rights reserved.
//

import UIKit

import RxSwift

final class LibrariesViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!

    private static let cellId = "LibraryCell"
    private static let customLibrariesSection = 0
    private static let groupLibrariesSection = 1
    private let viewModel: ViewModel<LibrariesActionHandler>
    private let disposeBag: DisposeBag

    weak var coordinatorDelegate: MasterLibrariesCoordinatorDelegate?

    // MARK: - Lifecycle

    init(viewModel: ViewModel<LibrariesActionHandler>) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        super.init(nibName: "LibrariesViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupTableView()

        self.viewModel.process(action: .loadData)

        self.viewModel.stateObservable
                      .observeOn(MainScheduler.instance)
                      .subscribe(onNext: { [weak self] state in
                          self?.update(to: state)
                      })
                      .disposed(by: self.disposeBag)

    }

    // MARK: - UI State

    private func update(to state: LibrariesState) {
        self.tableView.reloadData()

        if let error = state.error {
            self.coordinatorDelegate?.show(error: error)
        }

        if let question = state.deleteGroupQuestion {
            self.coordinatorDelegate?.showDeleteGroupQuestion(id: question.id, name: question.name, viewModel: self.viewModel)
        }
    }

    // MARK: - Setups

    private func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 44
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        self.tableView.register(UINib(nibName: "LibraryCell", bundle: nil), forCellReuseIdentifier: LibrariesViewController.cellId)
        self.tableView.tableFooterView = UIView()
    }

    private func setupNavigationBar() {
        let item = UIBarButtonItem(image: UIImage(systemName: "person.circle"), style: .plain, target: nil, action: nil)
        item.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.coordinatorDelegate?.showSettings()
            })
            .disposed(by: self.disposeBag)
        self.navigationItem.rightBarButtonItem = item
    }
}

extension LibrariesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case LibrariesViewController.customLibrariesSection:
            return self.viewModel.state.customLibraries?.count ?? 0
        case LibrariesViewController.groupLibrariesSection:
            return self.viewModel.state.groupLibraries?.count ?? 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == LibrariesViewController.groupLibrariesSection ? L10n.Libraries.groupLibraries : nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LibrariesViewController.cellId, for: indexPath)

        if let cell = cell as? LibraryCell,
           let (name, state) = self.libraryData(for: indexPath) {
            cell.setup(with: name, libraryState: state)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let library = self.library(for: indexPath) {
            self.coordinatorDelegate?.showCollections(for: library)
        }
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.section == LibrariesViewController.groupLibrariesSection,
              let group = self.viewModel.state.groupLibraries?[indexPath.row],
              group.isLocalOnly else { return nil }

        let groupId = group.identifier
        let groupName = group.name

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ -> UIMenu? in
            return self?.createContextMenu(for: groupId, groupName: groupName)
        }
    }

    private func createContextMenu(for groupId: Int, groupName: String) -> UIMenu {
        let delete = UIAction(title: L10n.delete, image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
            self?.viewModel.process(action: .showDeleteGroupQuestion((groupId, groupName)))
        }
        return UIMenu(title: "", children: [delete])
    }

    private func libraryData(for indexPath: IndexPath) -> (name: String, state: LibraryCell.LibraryState)? {
        switch indexPath.section {
        case LibrariesViewController.customLibrariesSection:
            let library = self.viewModel.state.customLibraries?[indexPath.row]
            return library.flatMap({ ($0.type.libraryName, .normal) })
        case LibrariesViewController.groupLibrariesSection:
            guard let library = self.viewModel.state.groupLibraries?[indexPath.row] else { return nil }
            let state: LibraryCell.LibraryState
            if library.isLocalOnly {
                state = .archived
            } else if !library.canEditMetadata {
                state = .locked
            } else {
                state = .normal
            }
            return (library.name, state)
        default:
            return nil
        }
    }

    private func library(for indexPath: IndexPath) -> Library? {
        switch indexPath.section {
        case LibrariesViewController.customLibrariesSection:
            let library = self.viewModel.state.customLibraries?[indexPath.row]
            return library.flatMap({ Library(customLibrary: $0) })
        case LibrariesViewController.groupLibrariesSection:
            let library = self.viewModel.state.groupLibraries?[indexPath.row]
            return library.flatMap({ Library(group: $0) })
        default:
            return nil
        }
    }
}
