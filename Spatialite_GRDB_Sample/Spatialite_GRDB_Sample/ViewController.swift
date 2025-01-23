//
//  ViewController.swift
//  Spatialite_GRDB_Sample
//
//  Created by Vladyslav Shkodych on 23.01.2025.
//

import UIKit

final class ViewController: UIViewController {

    // MARK: - Properties

    private let dbManager: DBManager

    // MARK: - Initializers

    init(dbManager: DBManager) {
        self.dbManager = dbManager

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        configure()
    }
}

// MARK: - Private methods

private extension ViewController {

    func configure() {
        dbManager.openDatabase(name: "TestDB.db", password: nil)
        dbManager.makeTestRequest()
    }
}
