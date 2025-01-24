//
//  DBManager.swift
//  Spatialite_GRDB_Sample
//
//  Created by Vladyslav Shkodych on 23.01.2025.
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
