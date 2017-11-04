/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 
 ## Example that tests if a property is null or missing
 
 */

import UIKit
import CouchbaseLiteSwift
import Foundation
import PlaygroundSupport

/*:
 ## Definition of a Document object returned by the Couchbase Lite query. Note that in an actual application, you would probably define a native object instead of a generic map type of the kind defined below
 
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
 ## Query for documents where a specific property is missing or null
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryMissingOrNullPropertyForDocumentsFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id),
                SelectResult.expression(Expression.property("email")))
        .from(DataSource.database(db))
        .where(Expression.property("email").isNullOrMissing())
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
 ## Query for documents where a specific property is NOT missing or null
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryNotMissingOrNullPropertyForDocumentsFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id),
                SelectResult.expression(Expression.property("email")))
        .from(DataSource.database(db))
        .where(Expression.property("email").notNullOrMissing())
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
        
        let results1 = try queryMissingOrNullPropertyForDocumentsFromDB(db, limit: 5)
        print("\n*****\nResponse to queryMissingOrNullPropertyForDocumentsFromDB :\n\(results1)")
        
        
        let results2 = try queryNotMissingOrNullPropertyForDocumentsFromDB(db, limit: 5)
        print("\n*****\nResponse to queryNotMissingOrNullPropertyForDocumentsFromDB :\n\(results2)")
      
        // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}





