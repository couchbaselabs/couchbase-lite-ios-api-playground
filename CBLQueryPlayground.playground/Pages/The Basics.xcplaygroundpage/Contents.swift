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
 The opens the database from prebuilt travel-sample database in `playgroundSharedDataDirectory`.
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
    
    // Create a database with an empty file
    let _ = try Database(name: kDBName, config: options)
    
  
    // The sample databases are bundled with a separate  resource framework
    // and is copied into documents path
    if let resourcePath = Bundle(for:ResourcesWrapperTest.self).path(forResource: kDBName, ofType: "cblite2")
       {
         do {
          
            // replace the default one with pre-bundled version
            // replaceItem results in permission issues so doing as two step
            let fileManager = FileManager.default
            try fileManager.removeItem(at: travelsampleFile)
            try fileManager.copyItem(at:  URL(fileURLWithPath: resourcePath), to: travelsampleFile)
        }
        catch {
              print("Error in copying sample database files to playground's shared directory \(error)")
        }
        
    }
    // Uncomment the line below  if you want details of the SQLite query equivalent
  //  Database.setLogLevel(.verbose, domain: .all)
    // reopen the database instance with copied sample
    return try Database(name: kDBName, config: options)

}

/**
func createOrOpenDatabase() throws -> Database? {
    let kDBName:String = "travel-sample"
  //  let fileURL = URL.init(fileURLWithPath: "~/Documents/Shared Playground Data")
   // let filePath = fileURL?.appendingPathComponent("travel-sample.cblite2")
 //   let fileURL = URL.init(fileURLWithPath: "/Users/priya.rajagopal/Documents/Shared Playground Data")
    
//    let resourceURL = Bundle.main.resourceURL
//
//›
//    let joindbFileAtSource = fileURL.appendingPathComponent("joindb.cblite2",isDirectory: true)
//    let travelsampleFileAtSource = fileURL.appendingPathComponent("travel-sample.cblite2", isDirectory: true)
    
    let sharedDocumentDirectory = playgroundSharedDataDirectory.resolvingSymlinksInPath()
    
   // print( playgroundSharedDataDirectory)
   // print(sharedDocumentDirectory)
    
  //  print( playgroundSharedDataDirectory.resolvingSymlinksInPath())
    let appSupportFolderPath = sharedDocumentDirectory.path
    
       
    let joindbFile = sharedDocumentDirectory.appendingPathComponent("joindb.cblite2", isDirectory: true)
    let travelsampleFile = sharedDocumentDirectory.appendingPathComponent("travel-sample.cblite2", isDirectory: false)
    
    let fileManager = FileManager.default
    let options =  DatabaseConfiguration()
    print(Bundle(for: Database.self).path(forResource: kDBName, ofType: "cblite2"))
    
    
    
  //  let filePath = fileURL.appendingPathComponent("travel-sample.cblite2")

    if let documentsURL = Bundle.main.resourceURL,
       let resourcePath1 = Bundle.main.path(forResource: kDBName, ofType: "cblite2"), let resourcePath = Bundle(for:ResourcesWrapperTest.self).path(forResource: kDBName, ofType: "cblite2")
       {
        print(resourcePath)
        
        options.directory = appSupportFolderPath
        print(options.directory)
      

      //  try Database.copy(fromPath: resourcePath, toDatabase: "\(kDBName)", withConfig: options)
        print(resourcePath)

        do {

            if fileManager.fileExists(atPath: travelsampleFile.path) {
                print("Already copied")
            }
            else {
                //Copy from temporary location to custom location.
               // try fileManager.copyItem(atPath: resourcePath, toPath: travelsampleFile.path)
                try fileManager.copyItem(at: URL.init(fileURLWithPath: resourcePath), to: travelsampleFile)
                print("*****")
                print("SOURCE:\(resourcePath)")
                print("DEST:\(travelsampleFile.path)")
                print("*****")
              //  try fileManager.replaceItemAt( travelsampleFile, withItemAt:URL.init(fileURLWithPath: resourcePath) )

            }
        }
        catch {
        print("Error in copying sample database files to playground's shared directory \(error)")
        }
   
        
    }
        


   

  
    
    // Uncomment the line below  if you want details of the SQLite query equivalent
     Database.setLogLevel(.verbose, domain: .all)
    do {
        let db  = try Database(name: kDBName, config: options)
        return db
    }
    catch {
        print(error)
        return nil
    }

}
 
 */

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
    
    let searchQuery = QueryBuilder
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
    
    let searchQuery = QueryBuilder
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




