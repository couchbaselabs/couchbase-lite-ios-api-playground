/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 
 ## Example that sorts the results of a query

 
 */

import UIKit
import CouchbaseLiteSwift
import ResourcesWrapper
import Foundation
import PlaygroundSupport

/*:
 ## Definition of a Document object returned by the Couchbase Lite query.
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
 ## Query for documents sorting results in ascending order of a specific property
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsInAscendingOrderFromDB(_ db:Database, limit:Int = 10 ) throws -> [Data]? {

    
    let searchQuery = QueryBuilder
        .select(
            SelectResult.expression(Meta.id),
            SelectResult.expression(Expression.property("title")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string("hotel")))
        .orderBy(Ordering.property("title").ascending())
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
 ## Run the queries defined in the above functions
 */


do {
    // Open or Create Couchbase Lite Database
    if let db:Database = try createOrOpenDatabase() {
        
        let results1 = try queryForDocumentsInAscendingOrderFromDB(db, limit: 5)
        print("\n*****\nResponse to queryForDocumentsInAscendingOrderFromDB :\n\(results1)")
        
       
        // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}






