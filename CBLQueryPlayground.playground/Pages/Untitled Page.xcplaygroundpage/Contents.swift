//: Playground - noun: a place where people can play

import UIKit
import CouchbaseLiteSwift
import Foundation
import PlaygroundSupport


/*:
 ## Common consts
 
*/

typealias Data = [String:Any?]

/*:
 ## Create/ Open Couchbase Lite Database
  - returns: Handle to CBLite database
 
 Loads database from prebuilt store of universities
 */
func createOrOpenDatabase() throws -> Database? {
    let sharedDocumentDirectory = playgroundSharedDataDirectory.resolvingSymlinksInPath()
    let kDBName:String = "travel-sample"
    let fileManager:FileManager = FileManager.default
   
    var options =  DatabaseConfiguration()
    let appSupportFolderPath = sharedDocumentDirectory.path
    options.fileProtection = .noFileProtection
    options.directory = appSupportFolderPath
    
    
    // Load Prebuilt database
    
    if Database.exists(kDBName, inDirectory: appSupportFolderPath) == false {
        
        if let prebuiltPath = Bundle.main.path(forResource: kDBName, ofType: "cblite2") {
            print("prebuiltPath is created /opened at \(prebuiltPath)")
           
            // Copy database from prebuiltPath to application support
            let destinationDBPath = appSupportFolderPath.appending("/\(kDBName).cblite2")
            do {
                try Database.copy(fromPath: prebuiltPath, toDatabase: "/\(kDBName)", config: options)
            }
            catch {
                print ("copy DB exception \(error.localizedDescription)")
            }
            //try fileManager.copyItem(atPath: prebuiltPath, toPath: destinationDBPath)
        }
    }
    print("DB is created /opened at \(appSupportFolderPath)")
    return try Database(name: kDBName, config: options)
    
}

func insertTestDocsInDatabase(_ db:Database) throws {
    let prop1 = [
        "type": "test",
        "title" : "doc_101"
    ]
    
    let doc1 = Document(dictionary: prop1)
   
    doc1.setDate(Date(), forKey: "date")
    try? db.save(doc1)
    
    let prop2 = [
        "type": "test",
        "title" : "doc_102",
        "date" : "2017-21-10’T’05:09:03"
    ]
    
    let doc2 = Document(dictionary: prop2)
    doc2.setDate(Date(), forKey: "date")
    try? db.save(doc2)
    
    let prop3 = [
        "type": "test",
        "title" : "doc_103",
        "date" : "2018-21-10’T’05:09:03"
    ]
    
    let doc3 = Document(dictionary: prop3)
     doc3.setDate(Date(), forKey: "date")
    try? db.save(doc3)

    
    
    
}

func deleteTestDocsInDatabase(_ db:Database) throws {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("test"))
    
    
    for row in try searchQuery.run() {
        if let id = row.toDictionary()["id"] as? String {
            if let doc = db.getDocument(id) {
                try db.delete(doc)
            }
        }
        
        
    }
    
}



/*:
 ## Query for "limit" number of documents . All properties of the document are returned.
  - parameter db : The database to query
  - parameter limit: The max number of documents to fetch. Defaults to 10.
  - returns: Documents matching the query
 
 */

func queryForAllDocumentsFromDB(_ db:Database, limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.all())
        .from(DataSource.database(db))
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
 ## Query for "limit" number of documents from specified offset . All properties of the document are returned.
 - parameter db : The database to query
 - parameter offset: The max number of documents to fetch. Defaults to 0.
 - parameter limit: The max number of documents to fetch. Defaults to 10.
 - returns: Documents matching the query
 
 */

func queryForAllDocumentsFromSpecifiedOffsetFromDB(_ db:Database, offset:Int = 0,limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.all())
        .from(DataSource.database(db))
        .limit(limit,offset: offset)
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.run() {
            matches.append(row.toDictionary())
        }
    }
    return matches
}




/*:
 ## Query for all documents of a specific type. All properties of the document are returned.
 - parameter db : The database to query
 - parameter type: The type of the document to fetch
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsOfSpecificTypeFromDB(_ db:Database, ofType type:String ,limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.all())
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(type))
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
 ## Query for all documents of a specific type. Only specified properties of document are returned.
 - parameter db : The database to query
 - parameter type: The type of the document to fetch
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsWithSubsetOfPropertiesFromDB(_ db:Database, ofType type:String ,limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.property("title")),
                SelectResult.expression(Expression.property("city")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(type))
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
 ## Query for all documents of a specific type with results sorted in ascending order
 - parameter db : The database to query
 - parameter type: The type of the document to fetch
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsInAscendingOrderFromDB(_ db:Database, ofType type:String , limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(
            SelectResult.expression(Expression.meta().id),
                SelectResult.expression(Expression.property("url")),
                SelectResult.expression(Expression.property("city")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(type))
        .orderBy(Ordering.property("title").ascending())
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
 ## Query for all documents of a specific type
 - parameter db : The database to query
 - parameter type: The type of the document to fetch
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsInAscendingOrderFromDBV2(_ db:Database, ofType type:String , limit:Int = 10 ) throws -> [Data]? {

    let searchQuery = Query
        .select(
            SelectResult.expression(Expression.property("email")),
            SelectResult.expression(Expression.property("city")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(type))
        .orderBy(Ordering.property("title").ascending())
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

func queryForDocumentsWithWhereComparisonFilterFromDB(_ db:Database, limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.property("title")),
                SelectResult.expression(Expression.property("city")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel")
                .and(Expression.property("country").equalTo("United States")
                .or(Expression.property("country").equalTo("France"))))
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
 ## Query for all documents with bool filtering
 - parameter db : The database to query. Defaults to 10
 - parameter limit: The max number of documents to fetch
 - returns: Documents matching the query
 
 */

func queryForDocumentsWithBoolFilterFromDB(_ db:Database, limit:Int = 10 ) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.property("title")),
                SelectResult.expression(Expression.property("vacancy")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel").and(Expression.property("vacancy").equalTo(true)))
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
 ## Query for all documents of a specific type grouped by a specified property
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryDocumentsByKeyPathFromDB(_ db:Database , limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.property("reviews")),
                SelectResult.expression(Expression.property("title")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel").and("reviews.author").equalTo("Isabel Denesik"))
        .limit(limit)
    
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.run() {
            matches.append(row.toDictionary())
        }
    }
    return matches
}



// Functions
// Query Keypath
// like
// match
// group
// join
// collate
// is / 
// math
// regex
// in 
// params
// aliases

/*:
 ## Query for meta information related to a document
 - parameter db : The database to query
 - parameter type: The type of the document to fetch
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryMetadataForDocumentsFromDB(_ db:Database,ofType type:String, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(type))
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
 ## Query for documents by applying a specific function
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsApplyingFunctionsFromDBV1(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id),
                SelectResult.expression(Expression.property("name")))
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
 ## Query for documents by applying a specific function, array operation
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsApplyingFunctionsFromDBV2(_ db:Database, limit:Int = 10) throws -> [Data]? {
    /*
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id),
                SelectResult.expression(Expression.property("name")),
                SelectResult.expression(Function.arrayLength(Expression.property("public_likes"))))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel"))
        .limit(limit)
 */
    let searchQuery = Query
        .select(
            SelectResult.expression(Expression.property("name")))
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
 ## Query for documents by applying a specific function, aliasing some results
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsApplyingFunctionsWithAliasFromDBV3(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Expression.meta().id),
                SelectResult.expression(Expression.property("name")),
                SelectResult.expression(Function.arrayLength(Expression.property("public_likes"))).as("#Likes")
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
 ## Query for documents by applying a specific function to results
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */
func queryForDocumentsApplyingFunctionsFromDBV4(_ db:Database, limit:Int = 10) throws -> [Data]? {
    /*
     let searchQuery = Query
     .select(SelectResult.expression(Expression.meta().id),
     SelectResult.expression(Expression.property("name")),
     SelectResult.expression(Function.arrayLength(Expression.property("public_likes"))))
     .from(DataSource.database(db))
     .where(Expression.property("type").equalTo("hotel"))
     .limit(limit)
     */
    let searchQuery = Query
        .select(
            SelectResult.expression(Expression.property("name")))
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
 ## Query for all documents of a specific type grouped by a specified property
 - parameter db : The database to query
 - parameter type: The type of the document to fetch
 - parameter groupBy: The property to group documents by
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryGroupingDocumentsFromDB(_ db:Database,ofType type:String, groupedBy groupBy:String, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Function.count(groupBy)), SelectResult.expression(Expression.property(groupBy)))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(type))
        .groupBy(Expression.property(groupBy))
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
 ## Couchbase Lite Test App
 */


do {
    // Open or Create Couchbase Lite Database
    if let db:Database = try createOrOpenDatabase() {
        
     //  try insertTestDocsInDatabase(db)
        
       try deleteTestDocsInDatabase(db)
        
    
        // Query for documents of specific type limiting the return results
//        let results1 = try queryForAllDocumentsFromDB(db, limit: 5)
//        print(results1)
//        
//        // Query for documents of specific type limiting the return results
//        let results2 = try queryForAllDocumentsFromSpecifiedOffsetFromDB(db,offset: 2,limit: 3)
//        print(results2)
//        
//        
        // Query for documents of specific type limiting the return results
         let results4 = try queryForDocumentsOfSpecificTypeFromDB(db, ofType: "hotel", limit: 1)
         print(results4)

//        // Query for documents of specific type limiting the return results
      //  let results3 = try queryForDocumentsWithBoolFilterFromDB(db, limit: 50)
      //  print(results3)
//
        // Query for documents of specific type limiting the return results
//        let results4 = try queryDocumentsByKeyPathFromDB(db, limit: 10000)
//        print(results4)
        
      //  let results2 = try queryForDocumentsWithSubsetOfPropertiesFromDB(db, ofType: "hotel", limit: 10)
      //  print(results2)
        
       // let results3 = try queryForDocumentsWithWhereComparisonFilterFromDB(db,  limit: 10)
       // print(results3)
        
        // Query for documents of specific type grouping based on certain criteria
//      let results3 = try queryGroupingDocumentsFromDB(db, ofType: "airline", groupedBy: "country", limit: 100)
//       print(results3)
        
        // Query for documents of specific type grouping based on certain criteria
      //let results9 = try queryForDocumentsInAscendingOrderFromDB(db, ofType: "hotel", limit: 1)
      //print(results9)
        
       
      //  let results5 = try queryMetadataForDocumentsFromDB(db, ofType: "hotel", limit: 10)
      //  print(results5)
        
        
      //  let results6 = try queryMissingOrNullPropertyForDocumentsFromDB(db,limit: 100)
      //  print(results6)
      
        //let results7 = try queryForDocumentsApplyingFunctionsFromDBV1(db,limit: 1000)
        //print(results7)
        
     //   let results8 = try queryForDocumentsApplyingFunctionsFromDBV2(db,limit: 50)
     //   print(results8)
        
    //    let results10 = try queryForDocumentsApplyingFunctionsWithAliasFromDBV3(db, limit: 10)
    //    print(results10)

        
       // let results5 = try queryForDocumentsWithAdvancedFilterFromDB(db, limit: 100)
       // print(results5)
        
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}



