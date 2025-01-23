//
//  DBManager.swift
//  Odysseus
//
//  Created by Vladyslav Shkodych on 11.10.2024.
//  Copyright © 2024 Eurospektras. All rights reserved.
//

protocol DBManager: AnyObject {

    func openDatabase(name: String, password: String?)
    func makeTestRequest()
}

enum DBManagerFactory {

    static func makeGRDBManager() -> DBManager {
        return GRDBManager()
    }
}
