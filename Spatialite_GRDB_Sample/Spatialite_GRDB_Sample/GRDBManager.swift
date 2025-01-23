//
//  GRDBManager.swift
//  Spatialite_GRDB_Sample
//
//  Created by Vladyslav Shkodych on 23.01.2025.
//

import GRDB

final class GRDBManager: NSObject, DBManager {

    // MARK: - Properties

    private var dbQueue: DatabaseQueue?
    private var lastPassword: String?

    // MARK: - Methods

    func openDatabase(name dbName: String, password: String?) {
        guard var dbPath: URL = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return }
        dbPath = dbPath.appendingPathComponent(dbName)
        guard !FileManager.default.fileExists(atPath: dbPath.path) else {
            var configuration: Configuration = Configuration()
            if let password {
                configuration.prepareDatabase { db in
                    try? db.usePassphrase(password)
                }
            }
            dbQueue = try? DatabaseQueue(path: dbPath.path, configuration: configuration)
            lastPassword = nil

            return
        }
        self.lastPassword = password
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.delegate = self
        UIApplication.shared.rootViewController?.present(documentPicker, animated: true, completion: nil)
    }

    func makeTestRequest() {
        do {
            try dbQueue?.inDatabase { db in
                var sqlQuery: String = ""
                // Create the locations table with a geometry column
                sqlQuery = """
                    CREATE TABLE IF NOT EXISTS locations (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL
                    );
                    """
                try db.execute(sql: sqlQuery)
                // Initialize SpatiaLite in the DB by calling InitSpatialMetadata
                sqlQuery = "SELECT InitSpatialMetaData(1)"
                try db.execute(sql: sqlQuery)
                // Add the geometry column to the locations table
                sqlQuery = "SELECT AddGeometryColumn('locations', 'geometry', 4326, 'POINT', 'XY');"
                try db.execute(sql: sqlQuery)
                // Create a spatial index to speed up spatial queries
                sqlQuery = "SELECT CreateSpatialIndex('locations', 'geometry');"
                try db.execute(sql: sqlQuery)
                sqlQuery = """
                    INSERT INTO locations (name, geometry)
                    VALUES ('My Point', ST_GeomFromText('POINT(125.6 10.1)', 4326));
                    INSERT INTO locations (name, geometry)
                    VALUES ('My Point2', ST_GeomFromText('POINT(125.9 10.2)', 4326));
                    INSERT INTO locations (name, geometry)
                    VALUES ('My Point3', ST_GeomFromText('POINT(150.9 90.2)', 4326));
                    """
                try db.execute(sql: sqlQuery)
                // Query: Find all points within a polygon (bounding box)
                sqlQuery = """
                    SELECT name, AsText(geometry)
                    FROM locations
                    WHERE ST_Within(geometry, ST_GeomFromText('POLYGON((125.0 9.5, 126.0 9.5, 126.0 10.5, 125.0 10.5, 125.0 9.5))', 4326))==1;
                    """
                let rows = try Row.fetchAll(db, sql: sqlQuery)
                for row in rows {
                    let name: String = row["name"]
                    let geometry: String = row["AsText(geometry)"]
                    print("Found location: \(name) with geometry: \(geometry)")
                }
                print("----------------------------------------------------------------------")
            }
        } catch {
            print(error)
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension GRDBManager: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL: URL = urls.first,
              let fileUrl: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        else { return }
        do {
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                try FileManager.default.removeItem(at: fileUrl)
            }
            try FileManager.default.createDirectory(at: fileUrl, withIntermediateDirectories: true)
            let destinationURL: URL = fileUrl.appendingPathComponent(selectedFileURL.lastPathComponent)
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: selectedFileURL, to: destinationURL)
        } catch {
            print(error)
        }

        openDatabase(name: selectedFileURL.lastPathComponent, password: lastPassword)
        makeTestRequest()
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
}
