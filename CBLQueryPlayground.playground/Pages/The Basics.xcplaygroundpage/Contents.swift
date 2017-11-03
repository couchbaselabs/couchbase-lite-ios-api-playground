/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 
 Example that shows the structure of basic query  */

import UIKit
import CouchbaseLiteSwift
import Foundation
import PlaygroundSupport

/*:
 ## Definition of a Document object returned by the Couchbase Lite query. Note that in an actual application, you would probably define a native object instead of a generic map type of the kind defined below
 
 */

typealias Data = [String:Any?]

/*:
 ## Create/ Open Couchbase Lite Database
 - returns: Handle to CBLite database
 
 Loads database from prebuilt store of universities
 */
func createOrOpenDatabase() throws -> Database? {
    let sharedDocumentDirectory = playgroundSharedDataDirectory.resolvingSymlinksInPath()
    let kDBName:String = "travel-sample"
    let fileManager:FileManager = FileManager.default
    
    var options =  DatabaseConfiguration()
    let appSupportFolderPath = sharedDocumentDirectory.path
    options.fileProtection = .noFileProtection
    options.directory = appSupportFolderPath
    
    
    // Load Prebuilt database
    
    if Database.exists(kDBName, inDirectory: appSupportFolderPath) == false {
        
        if let prebuiltPath = Bundle.main.path(forResource: kDBName, ofType: "cblite2") {
            print("prebuiltPath is created /opened at \(prebuiltPath)")
            
            // Copy database from prebuiltPath to application support
            let destinationDBPath = appSupportFolderPath.appending("/\(kDBName).cblite2")
            do {
                try Database.copy(fromPath: prebuiltPath, toDatabase: "/\(kDBName)", config: options)
            }
            catch {
                print ("copy DB exception \(error.localizedDescription)")
            }
            //try fileManager.copyItem(atPath: prebuiltPath, toPath: destinationDBPath)
        }
    }
    Database.setLogLevel(.verbose, domain: .all)
    return try Database(name: kDBName, config: options)
    
}

func closeDatabase(_ db:Database) throws  {
    try db.close()
}



/*:
 ## Query for "limit" number of documents. All properties of the document are returned.
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10.
 - returns: Documents matching the query
 
 */

func queryForAllDocumentsFromDB(_ db:Database, limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.all())
        .from(DataSource.database(db))
        .limit(limit)
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.run() {
            matches.append(row.toDictionary())
        }
    }
    return matches
}

/*:
 ## Query for "limit" number of documents from specified offset . All properties of the document are returned.
 - parameter db : The database to query
 - parameter offset: The max number of documents to fetch. Defaults to 0.
 - parameter limit: The max number of documents to fetch. Defaults to 10.
 - returns: Documents matching the query
 
 */

func queryForAllDocumentsFromSpecifiedOffsetFromDB(_ db:Database, offset:Int = 0,limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.all())
        .from(DataSource.database(db))
        .limit(limit,offset: offset)
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.run() {
            matches.append(row.toDictionary())
        }
    }
    return matches
}



/*:
 ## Exercise the queries defined in the above functions
 */


do {
    // Open or Create Couchbase Lite Database
    if let db:Database = try createOrOpenDatabase() {
        
        // Query for documents of specific type limiting the return results
        let results1 = try queryForAllDocumentsFromDB(db, limit: 5)
        print(results1)
        
        // Query for documents of specific type limiting the return results
        let results2 = try queryForAllDocumentsFromSpecifiedOffsetFromDB(db,offset: 2,limit: 3)
        print(results2)
        
        try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}




