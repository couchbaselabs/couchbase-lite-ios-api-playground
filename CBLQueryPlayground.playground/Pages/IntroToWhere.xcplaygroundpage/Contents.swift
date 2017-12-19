/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 
 ## Examples that show the use of the `where` clause.
 The `where` clause is used for filtering documents returned in the results of the query based on criteria specified by an appropriate  `Expression`
 
 The examples below demonstrate
 - Filtering using simple comparison Expression
 - Filtering using simple Logical Expression
 - Filtering using Property Expression with KeyPaths
 - Filtering using Boolean Expression
 
 */

import UIKit
import CouchbaseLiteSwift
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
 ## Query for all documents filtered on `type` property
 
 - Comparison Options Supported :
     - lessThan
     - notLessThan
     - lessThanOrEqualTo
     - notLessThanOrEqualTo
     - greaterThan
     - notGreaterThan
     - greaterThanOrEqualTo
     - notGreaterThanOrEqualTo
     - equalTo
     - notEqualTo
 
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsOfSpecificTypeFromDB(_ db:Database,limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.all())
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel"))
        .limit(limit)
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.execute() {
            matches.append(row.toDictionary())
        }
    }
    return matches
}


/*:
 ## Query for all documents with where comparisons
 Supported Criteria :
 - lessThan
 - notLessThan
 - lessThanOrEqualTo
 - notLessThanOrEqualTo
 - greaterThan
 - notGreaterThan
 - greaterThanOrEqualTo
 - notGreaterThanOrEqualTo
 - equalTo
 - notEqualTo
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */


/*:
 ## Query for all documents filtered on `type` property and logically combined with other criteria
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsWithLogicalExpressionFilterFromDB(_ db:Database, limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Meta.id))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel")
            .and(Expression.property("country").equalTo("United States")
                .or(Expression.property("country").equalTo("France")))
                .and(Expression.property("vacancy").equalTo(true)))
        .limit(limit)
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.execute() {
            matches.append(row.toDictionary())
        }
    }
    return matches
}

/*:
 ## Query for all documents using keypath in property expression
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryDocumentsByKeyPathFromDB(_ db:Database , limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.property("name")),
                SelectResult.expression(Expression.property("geo.lat")),
                SelectResult.expression(Expression.property("geo.lon")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel"))
        .limit(limit)
    
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.execute() {
            matches.append(row.toDictionary())
        }
    }
    return matches
}


/*:
 ## Query for all documents with bool filtering
 - parameter db : The database to query. Defaults to 10
 - parameter limit: The max number of documents to fetch
 - returns: Documents matching the query
 
 */

func queryForDocumentsWithBoolFilterFromDB(_ db:Database, limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.property("title")),
                SelectResult.expression(Expression.property("email")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel")
            .and(Expression.property("vacancy").equalTo(true)))
        .limit(limit)
    
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
        
        let results1 = try queryForDocumentsOfSpecificTypeFromDB(db, limit: 2)
        print("\n*****\nResponse to queryForDocumentsOfSpecificTypeFromDB :\n\(results1)")
        
        
        let results2 = try queryForDocumentsWithLogicalExpressionFilterFromDB(db)
        print("\n*****\nResponse to queryForDocumentsWithLogicalExpressionFilterFromDB :\n\(results2)")
        
     
        let results3 = try queryDocumentsByKeyPathFromDB(db)
        print("\n*****\nResponse to queryDocumentsByKeyPathFromDB :\n\(results3)")
        
        
        let results4 = try queryForDocumentsWithBoolFilterFromDB(db)
        print("\n*****\nResponse to queryForDocumentsWithBoolFilterFromDB :\n\(results4)")
        
       // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}


