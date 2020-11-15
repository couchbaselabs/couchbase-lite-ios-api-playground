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
import ResourcesWrapper
import Foundation
import PlaygroundSupport

/*:
 ## Data
 Definition of a Document object returned by the Couchbase Lite query.
 Note that in an actual application, you would probably define a native object instead of a generic map type of the kind defined below
 
 */

typealias Data = [String:Any?]

/*:
 ## Opens Couchbase Lite Database.
 The opens the database from prebuilt travel-sample database in `playgroundSharedDataDirectory`. The pre-built "travel-sample.cblite2" folder copied over to the ~/Documents/Shared\ Playground\ Data/ folder 
 - returns: Handle to CBLite database
 - throws exception if failure to create/open database

 */
func createOrOpenDatabase() throws -> Database? {
    let kDBName:String = "travel-sample"
 
    let sharedDocumentDirectory = playgroundSharedDataDirectory.resolvingSymlinksInPath()
    let appSupportFolderPath = sharedDocumentDirectory.path
        
    let travelsampleFile = sharedDocumentDirectory.appendingPathComponent("\(kDBName).cblite2", isDirectory: true)
        
    let options =  DatabaseConfiguration()
    options.directory = appSupportFolderPath
    
    let _ = try Database(name: kDBName, config: options)
    
    let fileManager = FileManager.default
 
    // The sample databases are bundled with a separate  resource framework
    // and is copied into documents path
    if let resourcePath = Bundle(for:ResourcesWrapperTest.self).path(forResource: kDBName, ofType: "cblite2")
       {
         do {
            // replace the default one with pre-bundled version
            // replaceItem results in permission issues so doing as two step
 
            try fileManager.removeItem(at: travelsampleFile)
            try fileManager.copyItem(at:  URL(fileURLWithPath: resourcePath), to: travelsampleFile)
        }
        catch {
              print("Error in copying sample database files to playground's shared directory \(error)")
        }
        
    }
    // Uncomment the line below  if you want details of the SQLite query equivalent
  //  Database.setLogLevel(.verbose, domain: .all)
    // reopen the database instance
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
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Expression.property("type")))
        .from(DataSource.database(db))
        .limit(Expression.int(limit))
    
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.execute() {
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
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id))
        .from(DataSource.database(db))
        .limit(Expression.int(limit))
    
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.execute() {
            for row in try searchQuery.execute() {
                if let dict = row.toDictionary() as? [String:Any],
                    let docId  = dict["id"] as? String {
                    // You can now fetch the details of the document using the Id
                    let doc = try db.document(withID:docId)
                }
            }
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
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("type")))
        .from(DataSource.database(db))
        .limit(Expression.int(limit))
    
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.execute() {
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
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.all())
        .from(DataSource.database(db))
        .limit(Expression.int(limit))
    
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.execute() {
            let dict = row.toDictionary()
            let docId = dict["id"]
            if let docDetails = dict["travel-sample"] as? [String:Any] {
                let name = docDetails["icao"]
            }
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
        
        let results1 = try queryPropertyForDocumentsFromDB(db, limit: 30)
        print("\n*****\nResponse to queryPropertyForDocumentsFromDB :\n\(results1)")
        
        let results2  = try queryMetadataForDocumentsFromDB(db,limit: 1)
        print("\n*****\nResponse to queryMetadataForDocumentsFromDB :\n\(results2)")
        
        let results3 = try queryMetadataAndPropertyForDocumentsFromDB(db)
        print("\n*****\nResponse to queryMetadataAndPropertyForDocumentsFromDB :\n\(results3)")
        
        let results4 = try queryMetadataAndAllPropertiesForDocumentsFromDB(db)
        print("\n*****\nResponse to queryMetadataAndAllPropertiesForDocumentsFromDB :\n\(results4)")
        
                
       // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}

