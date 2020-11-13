
/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 ## Examples that demonstrate `group` functions
 
Groups are generally used in conjunction with `count` function . The `count` function is returns the number of items that meet specific criteria
 
 The examples below demonstrate
 
 - Basic use of `count` function
 - Use of `group` function with  count
 - limitation of group function
 
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
    
    let travelsampleFile = sharedDocumentDirectory.appendingPathComponent("travel-sample.cblite2", isDirectory: false)
    
     let options =  DatabaseConfiguration()
    options.directory = appSupportFolderPath
    
    // The sample databases are bundled with a separate  resource framework
    // and is copied into documents path
    if let resourcePath = Bundle(for:ResourcesWrapperTest.self).path(forResource: kDBName, ofType: "cblite2")
       {

 
        do {
            let fileManager = FileManager.default
          
            if fileManager.fileExists(atPath: travelsampleFile.path) {
                print("Sample databases already copied to *** \(appSupportFolderPath) ***folder")
                print("Manually delete the sample database and re-run playground")
            }
            else {
                try fileManager.copyItem(at: URL.init(fileURLWithPath: resourcePath), to: travelsampleFile)
            }
        }
        catch {
              print("Error in copying sample database files to playground's shared directory \(error)")
        }
        
    }
    // Uncomment the line below  if you want details of the SQLite query equivalent
  //  Database.setLogLevel(.verbose, domain: .all)
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
 ## Query the number of documents based on specific criteria
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryDocumentCountFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Function.count(Expression.int(0))).as("NumHotels"))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("hotel")))
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
 ## Query for count of all documents of a specific type, grouped by specific criteria
 In this example, the hotels are grouped by country property and the count function is applied to each group.
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryDocumentCountGroupedByPropertyFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Function.count(Expression.int(0))).as("NumHotels"),
                SelectResult.expression(Expression.property("country")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("hotel")))
        .groupBy(Expression.property("country"))
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
 ## Query for documents grouped by specific criteria
 In this example, we expect to see list of documents grouped by `country` property on which the documents are grouped. However, you would see that only the first document in the group is returned.
 This is limitation at this point and hopefully, future iterations of the query interface supports aggregating result sets based on a group criteria
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryDocumentsGroupedByPropertyFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("name")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("hotel")))
        .groupBy(Expression.property("country"))
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
        
        let results1 = try queryDocumentCountFromDB(db, limit: 5)
        print("\n*****\nResponse to queryDocumentCountFromDB : \n \(results1)")
        
        let results2 = try queryDocumentCountGroupedByPropertyFromDB(db, limit: 5)
        print("\n*****\nResponse to queryDocumentCountGroupedByPropertyFromDB : \n \(results2)")
        
        let results3 = try queryDocumentsGroupedByPropertyFromDB(db, limit: 5)
        print("\n*****\nResponse to queryDocumentsGroupedByPropertyFromDB : \n \(results3)")
        
        
        // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}
