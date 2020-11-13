
/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 ## An advanced query example demonstrating the use of Parameterized Functions
 
 So far, we have looked at examples of query functions for string manipulation, handling collections etc. In the examples here, we will look at passing parameters to functions. This is a very powerful feature that brings a lot of flexibility to queries
 
 The examples below demonstrate
 
 - Use of parameters with `range` functions
 
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
 ## Query for documents by applying a function that takes in params
 In this example, we are looking for documents where the number of elements in "public_likes" nested array is within a specific range
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsApplyingFunctionsWithParams(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let likesCount = ArrayFunction.length(Expression.property("public_likes"))
    let lowerCount = Expression.parameter("lower")
    let upperCount = Expression.parameter("upper")
  
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("name")),
                SelectResult.expression(likesCount).as("NumLikes")
        )
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("hotel"))
            .and(likesCount.between(lowerCount,and: upperCount)))
        .limit(Expression.int(limit))

    let params = Parameters.init().setInt(5, forName: "lower").setInt(10, forName: "upper")
    searchQuery.parameters = params
    
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
        
        let results1 = try queryForDocumentsApplyingFunctionsWithParams(db, limit: 10)
        print("\n*****\nResponse to queryForDocumentsApplyingFunctionsWithParams : \n \(results1)")
        
        // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}

