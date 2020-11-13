/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 
 ## Examples that show pattern matching
 The `like` clause is used for case insensitive matches and you can use `regex` expressions for more elaborate case sensitive matches
 
 The examples below demonstrate
 - Exact case insensitive match using like
 - Wildcard match using like
 - Wildcard character match using like
 - Regex
 
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
 ## Query for all documents using exact match criteria
 
 The sample query returns all documents of specified `type`  where the `name` exactly is an exact match with "engineer"
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 */

func queryForDocumentsMatchingStringFromDB(_ db:Database,limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("country")),
                SelectResult.expression(Expression.property("name")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string("landmark"))
            .and(Function.lower(Expression.property("name")).like(Expression.string("royal engineers museum"))))
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
 ## Query for all documents using wildcard match criteria
 
 The sample query returns all documents of specified `type` where the `name` matches any string that begins with zero or more wildcard characters, followed by the characters "eng", followed by zero or more wildcard characters, followed by character "r" , followed by zero or more wildcard characters
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsMatchingWildcardedStringFromDB(_ db:Database,limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("country")),
                SelectResult.expression(Expression.property("name")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string("landmark"))
            .and( Function.lower(Expression.property("name")).like(Expression.string("%eng%r%"))))
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
 ## Query for all documents using character wildcard match criteria
 
 The sample query returns all documents of specified `type` where the `name` matches any string that begins with zero or more characters, followed by the characters "eng", followed by exactly 4 wildcard characters, followed by character "r"
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsMatchingCharacterWildcardedStringFromDB(_ db:Database,limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("country")),
                SelectResult.expression(Expression.property("name")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string("landmark"))
            .and( Expression.property("name")
                .like(Expression.string("%Eng____r%"))))
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
 ## Query for all documents using regex filter criteria
 
 The sample query returns all documents of specified `type` where the `name` matches any string that begins with the characters "Eng" followed by zero or more wildcard characters , followed by character "r" followed by zero or more wildcard characters. The matches happen on word boundaries
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsMatchingRegexFromDB(_ db:Database,limit:Int = 10 ) throws -> [Data]? {
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("name"))        )
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string("landmark"))
            .and(Function.lower(Expression.property("name")).regex(Expression.string("\\beng.*r.*\\b"))))
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
        
        let results1 = try queryForDocumentsMatchingStringFromDB(db, limit: 10)
        print("\n*****\nResponse to queryForDocumentsMatchingStringFromDB :\n\(results1)")
        
        
        let results2 = try queryForDocumentsMatchingWildcardedStringFromDB(db)
        print("\n*****\nResponse to queryForDocumentsMatchingWildcardedStringFromDB :\n\(results2)")
        
        let results3 = try queryForDocumentsMatchingCharacterWildcardedStringFromDB(db)
        print("\n*****\nResponse to queryForDocumentsMatchingCharacterWildcardedStringFromDB :\n\(results3)")

        
        let results4 = try queryForDocumentsMatchingRegexFromDB(db)
        print("\n*****\nResponse to queryForDocumentsMatchingRegexFromDB :\n\(results4)")
        
        // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}



