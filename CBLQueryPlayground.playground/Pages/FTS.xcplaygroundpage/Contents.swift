/*:
 [Table of Contents](ToC) | [Previous](@previous) | [Next](@next)
 ****
 
 ## Examples that show full text search
 The `match` clause is used for case insensitive searches of textual content within JSON Documents
 
 The examples below demonstrate
 - case insensitive search
 - case sensitive search
 - stemming support
 - Search Expressions
 
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
 ## delete all FTS Indexes
 Clears any previously created indexes
 - returns: Handle to CBLite database
 - throws exception if failure to create/open database
 
 */
func deleteAllFTSIndexesOnDatabase(_ db:Database) throws  {
    try db.deleteIndex(forName: "ContentFTSIndex")
    try db.deleteIndex(forName: "ContentFTSIndexNoStemming")
    try db.deleteIndex(forName: "ContentAndNameFTSIndex")
}

/*:
 ## creates appropriate FTS Indexes
 - returns: Handle to CBLite database
 - throws exception if failure to create/open database
 
 */
func createFTSIndexOnDatabase(_ db:Database) throws  {
    let ftsIndex = IndexBuilder.fullTextIndex(items: FullTextIndexItem.property("content"))
    try db.createIndex(ftsIndex,withName: "ContentFTSIndex")
}

/*:
 ## creates appropriate FTS Indexes with no stemming
 - returns: Handle to CBLite database
 - throws exception if failure to create/open database
 /Users/priya.rajagopal/projects/cblite/contacts.sql.txt

 */
func createFTSIndexOnDatabaseWithNoStemming(_ db:Database) throws  {
    
    // Setting locale as "" disables stemming
    let ftsIndex = IndexBuilder.fullTextIndex(items: FullTextIndexItem.property("content")).language(nil)
    try db.createIndex(ftsIndex,withName: "ContentFTSIndexNoStemming")
}

/*:
 ## creates appropriate FTS Indexes with no stemming
 - returns: Handle to CBLite database
 - throws exception if failure to create/open database
 
 */
func createFTSIndexOnDatabaseWithMultipleProperties(_ db:Database) throws  {
    
    let ftsIndex = IndexBuilder.fullTextIndex(items: FullTextIndexItem.property("content"),FullTextIndexItem.property("name"))
    try db.createIndex(ftsIndex,withName: "ContentAndNameFTSIndex")
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
 ## Query for all documents using specific match criteria to search for specific string
 
 The sample query returns all `landmark` documents  where the `content` includes the term "Mechanical" and
 all other variants of that word such as "Mechanism", "mechanic" etc
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 */

func queryForDocumentsContainingSpecificString(_ db:Database,limit:Int = 10 ) throws -> [Data]? {
    let ftsExpression = FullTextExpression.index("ContentFTSIndex")
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("content")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("landmark"))
            .and( ftsExpression.match("Mechanical")))
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
 ## Query for all documents using specific match criteria to search for specific string by disabling stemming
 
 The sample query returns all `landmark` documents  where the `content` includes the term "Mechanical"
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 */

func queryForDocumentsContainingSpecificStringWithNoStemming(_ db:Database,limit:Int = 10 ) throws -> [Data]? {
    let ftsExpression = FullTextExpression.index("ContentFTSIndexNoStemming")
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("content")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("landmark"))
            .and( ftsExpression.match("Mechanical")))
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
 ## Query for all documents using specific match criteria to search for specific string with wildcard match
 
 The sample query returns all `landmark` documents  where the `content` includes the term "walt" followed by zero or
 more characters. This will match strings "walter", "Walthamstow","waltham" and so on ...
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 */

func queryForDocumentsContainingSpecificWildcardString(_ db:Database,limit:Int = 10 ) throws -> [Data]? {
    let ftsExpression = FullTextExpression.index("ContentFTSIndex")
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("content")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("landmark"))
            .and( ftsExpression.match("walt*")))
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
 ## Query for all documents using specific match criteria with logical expression
 
 The sample query returns all `landmark` documents  where the `content` includes only the terms "Mechanical" or "Mechanism"
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 */

func queryForDocumentsContainingSpecificLogicalOperatorStringNoStemming(_ db:Database,limit:Int = 10 ) throws -> [Data]? {
    let ftsExpression = FullTextExpression.index("ContentFTSIndexNoStemming")
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("content")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("landmark"))
            .and( ftsExpression.match("Mechanical OR Mechanism")))
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
 ## Query for all documents using specific match criteria applied to the name or content property- multiple property match
 
 The sample query returns all `landmark` documents  where the `content` or `name` includes the term "Mechanical"
 followed by zero or more characters
 Documents will match content with terms "Mechanical","mechanisms","mechanics". Disable stemming for exact match
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 */

func queryForDocumentsContainingSpecificStringInMultipleProperties(_ db:Database,limit:Int = 100 ) throws -> [Data]? {
    let ftsExpression = FullTextExpression.index("ContentAndNameFTSIndex")
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("name")),
                SelectResult.expression(Expression.property("content")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("landmark"))
            .and( ftsExpression.match("Mechanical")))
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
 ## Query for all documents using specific match criteria applied to the name or content property- multiple property match
 
 The sample query returns all `landmark` documents  where the `content` or `name` includes the term "Mechanical"
 followed by zero or more characters and the address property includes the term "sunset"
 Documents will match content with terms "Mechanical","mechanisms","mechanics". Disable stemming for exact match
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 */
/*** DOES NOT WORK

func queryForDocumentsContainingSpecificStringByOverrdingIndex(_ db:Database,limit:Int = 100 ) throws -> [Data]? {
    let ftsExpression = FullTextExpression.index("ContentAndNameFTSIndex")
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("name")),
                SelectResult.expression(Expression.property("content")),
                SelectResult.expression(Expression.property("address")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("landmark"))
            .and( ftsExpression.match("'address:Mason Mechanical'")))
        .limit(Expression.int(limit))
    
    
    var matches:[Data] = [Data]()
    do {
        for row in try searchQuery.execute() {
            matches.append(row.toDictionary())
        }
    }
    return matches
}
****/

/*:
 ## Query for all documents for search string containing stop words
 
 The sample query returns all `landmark` documents  where the `content`  includes the term "on the history" followed by zero or more characters
 Documents will match content with terms "history" as "on" and "the" will be ignored
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 */

func queryForDocumentsContainingSpecificStringWithStopWords(_ db:Database,limit:Int = 5) throws -> [Data]? {
    let ftsExpression = FullTextExpression.index("ContentFTSIndex")
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("content")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("landmark"))
            .and( ftsExpression.match("Winter gardens")))
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
 ## Query for all documents by ignoring stop words
 
 The sample query returns all `landmark` documents  where the `content` or `name` includes the term "blue fin yellow fin"
 Stop words are ignored  by default so you would match documents that include text "blue fin and yellow fin" and so on
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 */

func queryForDocumentsContainingSpecificStringIgnoringStopWords(_ db:Database,limit:Int = 100 ) throws -> [Data]? {
    let ftsExpression = FullTextExpression.index("ContentFTSIndex")
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("content")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("landmark"))
            .and( ftsExpression.match("'blue fin yellow fin'")))
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
 ## Query for all documents for search term with maximum distance between the search tokens specified
 
 The sample query returns all `landmark` documents  where the `content` or `name` includes the term "blue fin yellow fin"
 This would match documents that include text "fish" and "clothing". Stop words are ignored duing search.
  separated by maximum of 2 tokens. This will include stem variants of the terms "fish" and "clothing"
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 */

func queryForDocumentsContainingStringsSeparatedByMaxDistance(_ db:Database,limit:Int = 10 ) throws -> [Data]? {
    let ftsExpression = FullTextExpression.index("ContentFTSIndex")
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("content")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("landmark"))
            .and( ftsExpression.match("fish NEAR/1 clothing")))
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
 ## Query for all documents with phrase words.
 
 The sample query returns all `landmark` documents  where the `content` or `name` includes the term "winter gardens" without any intervening tokens. By default by not including in quotes, it will return documents with winter and gardens in it separated by any number of tokens
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 */

func queryForDocumentsContainingSpecificPhrase(_ db:Database,limit:Int = 5 ) throws -> [Data]? {
    let ftsExpression = FullTextExpression.index("ContentFTSIndex")
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("content")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("landmark"))
            .and( ftsExpression.match("'\"Winter gardens\"'")))
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
 ## Query for all documents for search string sorted by rank order
 
 The sample query returns all `landmark` documents  where the `content`  includes the term " attract".
 Results are ranked according to relevance so documents with more occurrences of attract appear higher
 
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 5
 - returns: Documents matching the query
 */

func queryForDocumentsContainingSpecificStringWithRankOrder(_ db:Database,limit:Int = 10) throws -> [Data]? {
    let ftsExpression = FullTextExpression.index("ContentFTSIndexNoStemming")
    let searchQuery = QueryBuilder
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("content")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo(Expression.string ("landmark"))
            .and( ftsExpression.match("attract")))
        .orderBy(Ordering.expression(FullTextFunction.rank("ContentFTSIndexNoStemming")).descending())
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
        // If you not create indexes, you will get an exception "Exception is 'match' test requires a full-text index"
        print(db.indexes)
        
        let _ = try deleteAllFTSIndexesOnDatabase(db)
        
        let _ = try createFTSIndexOnDatabase(db)

        let _ = try createFTSIndexOnDatabaseWithNoStemming(db)

        let _ = try createFTSIndexOnDatabaseWithMultipleProperties(db)

        let results1 = try queryForDocumentsContainingSpecificString(db)
        print("\n*****\nResponse to queryForDocumentsContainingSpecificString :\n\(results1)")

        let results2 = try queryForDocumentsContainingSpecificStringWithNoStemming(db)
        print("\n*****\nResponse to queryForDocumentsContainingSpecificStringWithNoStemming :\n\(results2)")

        let results3 = try queryForDocumentsContainingSpecificLogicalOperatorStringNoStemming(db)
        print("\n*****\nResponse to queryForDocumentsContainingSpecificLogicalOperatorStringNoStemming :\n\(results3)")

        let results4 = try queryForDocumentsContainingSpecificWildcardString(db)
        print("\n*****\nResponse to queryForDocumentsContainingSpecificWildcardString :\n\(results4)")

        let results5 = try queryForDocumentsContainingSpecificStringInMultipleProperties(db)
        print("\n*****\nResponse to queryForDocumentsContainingSpecificStringInMultipleProperties :\n\(results5)")

        let results6 = try queryForDocumentsContainingSpecificStringWithStopWords(db)
        print("\n*****\nResponse to queryForDocumentsContainingSpecificStringWithStopWords :\n\(results6)")

        let results7 = try queryForDocumentsContainingSpecificPhrase(db)
        print("\n*****\nResponse to queryForDocumentsContainingSpecificPhrase :\n\(results7)")

        let results8 = try queryForDocumentsContainingSpecificStringIgnoringStopWords(db)
        print("\n*****\nResponse to queryForDocumentsContainingSpecificStringIgnoringStopWords :\n\(results8)")

        let results9 = try queryForDocumentsContainingStringsSeparatedByMaxDistance(db)
        print("\n*****\nResponse to queryForDocumentsContainingStringsSeparatedByMaxDistance :\n\(results9)")

        let results10 = try queryForDocumentsContainingSpecificStringWithRankOrder(db)
        print("\n*****\nResponse to queryForDocumentsContainingSpecificStringWithRankOrder :\n\(results10)")

//        let results11 = try queryForDocumentsContainingSpecificStringByOverrdingIndex(db)
//        print("\n*****\nResponse to queryForDocumentsContainingSpecificStringByOverrdingIndex :\n\(results11)")

        // try closeDatabase(db)
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}




