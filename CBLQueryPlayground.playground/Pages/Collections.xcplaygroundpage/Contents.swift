/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 ## Examples that show query functions on arrays 
 
A JSON object contain a nested array object. The examples discussed here describe queries that can be performed on arrays using appropriate array `Function` expressions
 The examples below demonstrate

 - Checking if an array contains a specific member
 - Querying for length of an array
 - Querying for length of an array with aliases
 - Using `satisfies` / `in` clause to check if members of array satisfy a criteria defined by the query expression
 
 
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
 ## Query for documents which contain a nested array object that contains a specific element
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsByTestingArrayContainment(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id),
                SelectResult.expression(Expression.property("name")),
                SelectResult.expression(Expression.property("public_likes")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel")
            .and( Function.arrayContains(Expression.property("public_likes"), value: "Armani Langworth")))
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
 ## Query for documents returning the length of nested array object.
 Notice that the computed array length results is returned with key of $1.
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsByReturningArrayLength(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id),
                SelectResult.expression(Expression.property("name")),
                SelectResult.expression(Function.arrayLength(Expression.property("public_likes"))))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel"))
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
 ## Query for documents returning the length of nested array object by aliasing the results
The `as` expression is used to alias the results of evaluating an expression. In query below, the result of `arrayLength` is aliased to "NumLikes"
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsByReturningArrayLengthWithAlias(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id),
                SelectResult.expression(Expression.property("name")),
                SelectResult.expression(Function.arrayLength(Expression.property("public_likes"))).as("NumLikes")
        )
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel"))
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
 ## Query for documents returning those documents containing an array which `satisfies` a specific criteria
 The `any` expression is used test if the criteria specified in the `satisfies` expression applies to one or more elements in the array object returned by the `in` expression
 The `all` expression (not shown in example) is used test if the criteria specified in the `satisfies` expression applies to _all_ the elements in the array object returned by the `in` expression
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsApplyingSatisfiesCriteriaFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let NAME = Expression.variable("reviewer")
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id),
            SelectResult.expression((Expression.property("public_likes"))))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel")
            .and(Expression.any("reviewer").in(Expression.property("public_likes"))
                .satisfies(NAME.like("Cor%"))))
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
        
        let results1 = try queryForDocumentsByTestingArrayContainment(db, limit: 5)
        print("\n*****\nResponse to queryForDocumentsByTestingArrayContainment : \n \(results1)")
        
        let results2 = try queryForDocumentsByReturningArrayLength(db, limit: 5)
        print("\n*****\nResponse to  queryForDocumentsByReturningArrayLength : \n \(results2)")
        
        let results3 = try queryForDocumentsByReturningArrayLengthWithAlias(db, limit: 5)
        print("\n*****\nResponse to queryForDocumentsByReturningArrayLengthWithAlias : \n \(results3)")
        
        let results4 = try queryForDocumentsApplyingSatisfiesCriteriaFromDB(db, limit: 5)
        print("\n*****\nResponse to queryForDocumentsApplyingSatisfiesCriteriaFromDB : \n \(results4)")
        
        // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}







