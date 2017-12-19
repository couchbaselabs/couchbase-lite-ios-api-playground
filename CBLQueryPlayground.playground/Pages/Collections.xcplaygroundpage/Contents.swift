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
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("name")),
                SelectResult.expression(Expression.property("public_likes")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel")
            .and( ArrayFunction.contains(Expression.property("public_likes"), value: "Armani Langworth")))
     
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
 ## Query for documents returning the length of nested array object.
 Notice that the computed array length results is returned with key of $1.
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsByReturningArrayLength(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("name")),
    SelectResult.expression(ArrayFunction.length(Expression.property("public_likes"))))
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
 ## Query for documents returning the length of nested array object by aliasing the results
The `as` expression is used to alias the results of evaluating an expression. In query below, the result of `arrayLength` is aliased to "NumLikes"
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsByReturningArrayLengthWithAlias(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let searchQuery = Query
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("name")),
                SelectResult.expression(ArrayFunction.length(Expression.property("public_likes"))).as("NumLikes")
        )
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
 ## Query for documents returning those documents containing an array which `satisfies` a specific criteria
 The `any` expression is used test if the criteria specified in the `satisfies` expression applies to one or more elements in the array object returned by the `in` expression
 The `all` expression (not shown in example) is used test if the criteria specified in the `satisfies` expression applies to _all_ the elements in the array object returned by the `in` expression
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsApplyingSatisfiesCriteriaFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let VAR_LIKEDBY = ArrayExpression.variable("likedby")
    let searchQuery = Query
        .select(SelectResult.expression(Meta.id),
            SelectResult.expression((Expression.property("public_likes"))))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel")
            .and(ArrayExpression.any("likedby").in(Expression.property("public_likes"))
                .satisfies(VAR_LIKEDBY.like("Cor%"))))
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
 ## Query for documents returning those documents containing a nested array which `satisfies` a specific criteria
 The `any` expression is used test if the criteria specified in the `satisfies` expression applies to one or more elements in the array object returned by the `in` expression
 The `all` expression (not shown in example) is used test if the criteria specified in the `satisfies` expression applies to _all_ the elements in the array object returned by the `in` expression
 - parameter db : The database to query
 - parameter limit: The max number of documents to fetch. Defaults to 10
 - returns: Documents matching the query
 
 */

func queryForDocumentsApplyingSatisfiesCriteriaOnNestedArrayFromDB(_ db:Database, limit:Int = 10) throws -> [Data]? {
    
    let VAR_OVERALL = ArrayExpression.variable("review.ratings.Overall")
    let searchQuery = Query
        .select(SelectResult.expression(Meta.id),
                SelectResult.expression(Expression.property("name")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel")
            .and(ArrayExpression.any("review").in(Expression.property("reviews"))
                .satisfies(VAR_OVERALL.greaterThanOrEqualTo(4))))
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
 ## Since Couchbase Lite lacks array expressions to flatten an array, we demonstrate the use of swift language capabilities to
 post process nested arrays to extract relevant data
 
 - parameter db : The database to query
 - returns: Documents matching the query
 
 */

func postProcessingAndFlattenArrayResultsFromDB(_ db:Database) throws  {
    
    // 1. Query for reviews property array for the given hotel
    let searchQuery = Query
        .select(
                SelectResult.expression(Expression.property("reviews")))
        .from(DataSource.database(db))
        .where(Expression.property("type").equalTo("hotel")
            .and(Meta.id.equalTo("hotel_10025")))
   
    
    // 2. Result set if an array of objects, one for each docment that matches the criteria.
    //  In our example, we are querying for one specific document with given id , so we will
    //  get an array with a single object
    //   Each object is a dictionary representing the "reviews" property
    // Ths result would be something like
    /*
     [
     {
     "reviews": [
     {
     "author": "Ozella Sipes",
     "content": "blah",
     "date": "2013-06-22 18:33:50 +0300",
     "ratings": {
     "Cleanliness": 5,
     "Location": 4,
     "Overall": 4,
     "Rooms": 3,
     "Service": 5,
     "Value": 4
     }
     },
     {
     "author": "fuzzy Snipes",
     "content": "blah",
     "date": "2013-06-22 18:33:50 +0300",
     "ratings": {
     "Cleanliness": 2,
     "Location": 3,
     "Overall": 4,
     "Rooms": 3,
     "Service": 5,
     "Value": 4
     }
     }
     ]
     }
     ]

 */
    
   // 3. Iterate over the searchQuery results , extract the value of "reviews" property and
    //   put that into a new array named "matches"
    
    // Result would look something like this
    /*
    
     [
     [
     {
     "author": "Ozella Sipes",
     "content": "blah",
     "date": "2013-06-22 18:33:50 +0300",
     "ratings": {
     "Cleanliness": 5,
     "Location": 4,
     "Overall": 4,
     "Rooms": 3,
     "Service": 5,
     "Value": 4
     }
     },
     {
     "author": "fuzzy Snipes",
     "content": "blah",
     "date": "2013-06-22 18:33:50 +0300",
     "ratings": {
     "Cleanliness": 2,
     "Location": 3,
     "Overall": 4,
     "Rooms": 3,
     "Service": 5,
     "Value": 4
     }
     }
     ]
     
     ]
     
     */
     
    
    var matches:[[Data]] = [[Data]]()
    do {
        for row in try searchQuery.execute() {
            print(row.toDictionary())
            if let reviewData = row.array(forKey: "reviews")?.toArray() as? [Data] {
                matches.append(reviewData)
            }
        }
    }
    
    print("Matches is \(matches)")
      
    // 4.  Use flatmap to unnest the top level
    // 5.  Then use map to get the "Cleanliness" value associated with ratings property
    // 6.   Use flat map to remove teh nils
    // 7.   Use min to compute the min value of all Cleanliness values
    let minCleanlinessValue = matches.flatMap{$0}
        .map{
            return ($0["ratings"] as? [String:Any])?["Cleanliness"] as? Int
        }
        .flatMap{$0}
        .min { (a, b) -> Bool in
                return a < b
            }

    print ("minCleanlinessValue is \(minCleanlinessValue)")
 
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

        let results5 = try queryForDocumentsApplyingSatisfiesCriteriaOnNestedArrayFromDB(db, limit: 5)
        print("\n*****\nResponse to queryForDocumentsApplyingSatisfiesCriteriaOnNestedArrayFromDB : \n \(results5)")

         try postProcessingAndFlattenArrayResultsFromDB(db)
        

        
    }
    
}
catch {
    print ("Exception is \(error.localizedDescription)")
}







