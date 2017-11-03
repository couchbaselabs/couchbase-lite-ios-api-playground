/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 
 ## Examples that show the use of the `SelectResult`
 A `SelectResult` represents a single return value of the query statement

 - SelectResult.all() : Returns all properties
 - SelectResult(Expression) : Return values based on Expression. An expression can be of many types. *We discuss `Property` type expression here*
 
 The examples below demonstrate
 - Fetching a specific property for all documents
 - Fetching metadata for all documents
 - Fetching metadata and selected properties for documents
 - Fethcing metadata and all properties for documents
 
 */

import UIKit
import CouchbaseLiteSwift
import Foundation
import PlaygroundSupport

/*:
 ## Data
 Definition of a Document object returned by the Couchbase Lite query. Note that in an actual application, you would probably define a native object instead of a generic map type of the kind defined below
 
 */

typealias Data = [String:Any?]

/*:
 ## Opens Couchbase Lite Database.
 The opens the database from prebuilt travel-sample database in `playgroundSharedDataDirectory`. Make sure that you have the "travel-sample.cblite2" folder copied over to the ~/Documents/Shared\ Playground\ Data/ folder 
 - returns: Handle to CBLite database
 - throws exception if failure to create/open database

 */
func createOrOpenDatabase() throws -> Database? {
    let sharedDocumentDirectory = playgroundSharedDataDirectory.resolvingSymlinksInPath()
    let kDBName:String = "travel-sample"
    let fileManager:FileManager = FileManager.default
    
    var options =  DatabaseConfiguration()
    let appSupportFolderPath = sharedDocumentDirectory.path
    options.fileProtection = .noFileProtection
    options.directory = appSupportFolderPath
  
    // Uncomment the line below  if you want details of the SQLite query equivalent
    // Database.setLogLevel(.verbose, domain: .all)
    return try Database(name: kDBName, config: options)
    
}

/*:
 ## Close database
 - parameter db : The database to close
 - throws exception if failure to close
 */

func closeDatabase(_ db:Database) throws  {
    try db.close()
}

/*:
 ## Query for `type` property in documents.
 Note that this query can be extended to include other properties
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryPropertyForDocumentsFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.property("type")))
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
 ## Query for metadata in documents
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryMetadataForDocumentsFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id))
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
 ## Query for metadata and `type` property in documents
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryMetadataAndPropertyForDocumentsFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id),
                SelectResult.expression(Expression.property("type")))
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
 ## Query for metadata and all properties in documents
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryMetadataAndAllPropertiesForDocumentsFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id),
                SelectResult.all())
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
 ## Run the queries defined in the above functions
 */


do {
    // Open or Create Couchbase Lite Database
    if let db:Database = try createOrOpenDatabase() {
        
        let results1 = try queryPropertyForDocumentsFromDB(db, limit: 30000)
        print(results1)
        
        let results2 = try queryMetadataForDocumentsFromDB(db)
        print(results2)
        
        let results3 = try queryMetadataAndPropertyForDocumentsFromDB(db)
        print(results3)
        
        let results4 = try queryMetadataAndAllPropertiesForDocumentsFromDB(db)
        print(results4)
        
        try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}

