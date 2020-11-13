
/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 ## Examples that show queries using string manipulation functions
 
The examples discussed here describe some simple string manipulation operations that can be performed using the `Function` expressions

 The examples below demonstrate
 
 - Substring operation
 - Collation
 
 
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
    
    print(appSupportFolderPath)
    
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
 ## Query for documents using `substring` filter criteria.
 The example below discusses one particular string manipulation function.
 - String Manipulation Functions include :
     - Function.lower(prop);
     - Function.ltrim(prop);
     - Function.rtrim(prop);
     - Function.trim(prop);
     - Function.upper(prop);
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsUsingSubstringFilteringFromDB(_ db:Database, limit:Int = 30000) throws -> [Data]? {
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("email")),
                SelectResult.expression(Expression.property("name")))
        .from(DataSource.database(db))
        .where(Function.contains(Expression.property("email"), substring: Expression.string (".uk")))
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
 ## Query for documents by applying collation function to a string
 In this example, we ignore the case when doing string comparison
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsApplyingStringCollation(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let ignoreCase = Collation.unicode()
        .ignoreCase(true)
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("name")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string("hotel"))
            .and(Expression.property("name").collate(ignoreCase).equalTo(Expression.string ("the robins"))))
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
        
        let results1 = try queryForDocumentsUsingSubstringFilteringFromDB(db, limit: 5)
        print("\n*****\nResponse to queryForDocumentsUsingSubstringFilteringFromDB : \n \(results1)")
        
        let results2 = try queryForDocumentsApplyingStringCollation(db, limit: 5)
        print("\n*****\nResponse to  queryForDocumentsApplyingStringCollation : \n \(results2)")
        
        
        // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}







