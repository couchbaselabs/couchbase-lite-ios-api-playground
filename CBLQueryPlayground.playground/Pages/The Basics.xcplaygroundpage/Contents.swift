/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 
 Examples that show the structure of basic query
 Note that you can speed up query processing by creating appropriate indexes. The examples below deal with a small dataset so we will not be creating any indexes.
 
 - Fetching all documents from DB
 - Fetching documents with Pagination
 
 */

import UIKit
import CouchbaseLiteSwift
import Foundation
import PlaygroundSupport

/*:
 ## Definition of a Document object returned by the Couchbase Lite query.
 Note that in an actual application, you would probably define a native object instead of a generic map type of the kind defined below
 
 */

typealias Data = [String:Any?]
/*:
 ## Opens Couchbase Lite Database.
 The opens the database from prebuilt travel-sample database in `playgroundSharedDataDirectory`. Make sure that you have the "travel-sample.cblite2" folder copied over to the ~/Documents/Shared\ Playground\ Data/ folder
 - returns: Handle to CBLite database
 - throws exception if failure to create/open database
 
 */
func createOrOpenDatabase() throws -> Database? {
    let kDBName:String = "travel-sample"
    let sharedDocumentDirectory = playgroundSharedDataDirectory.resolvingSymlinksInPath()
    let appSupportFolderPath = sharedDocumentDirectory.path
    
    let options =  DatabaseConfiguration.Builder()
        .setDirectory(appSupportFolderPath)
        .setFileProtection(.noFileProtection)
        .build()
    
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
 ## Query for "limit" number of documents.
 All properties of the document are returned.
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10.
 - returns: Documents matching the query
 
 */

func queryForAllDocumentsFromDB(_ db:Database, limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.all())
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
 ## Query for "limit" number of documents from specified offset
 All properties of the document are returned.
 - parameter db : The database to query
 - parameter offset: The max number of documents to fetch. Defaults to 0.
 - parameter limit: The max number of documents to fetch. Defaults to 10.
 - returns: Documents matching the query
 
 */

func queryForAllDocumentsFromSpecifiedOffsetFromDB(_ db:Database, offset:Int = 0,limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.all())
        .from(DataSource.database(db))
        .limit(Expression.int(limit),offset: Expression.int(offset))
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.execute() {
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
        
        let results1 = try queryForAllDocumentsFromDB(db, limit: 5)
        print("\n*****\nResponse to queryForAllDocumentsFromDB :\n\(results1)")
        
        let results2 = try queryForAllDocumentsFromSpecifiedOffsetFromDB(db,offset: 2,limit: 3)
        print("\n*****\nResponse to queryForAllDocumentsFromSpecifiedOffsetFromDB :\n\(results2)")
        
        
       // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}




