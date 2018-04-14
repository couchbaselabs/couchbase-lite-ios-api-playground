This Swift Playground demonstrates the new Query interface in Couchbase Lite 2.0. 

## Demo
A step-by-step demonstration of using the playground for testing 

[![Alt text](https://i.ytimg.com/vi/9NA2OXdSiqA/1.jpg)](https://youtu.be/9NA2OXdSiqA)

## Overview
While the Xcode playground demonstrates the queries in swift, given the unified nature of the QueryBuilder API across the various Couchbase Lite platforms, barring language specific idioms, you should be able to easily translate the queries to any of the other platform languages supported in Couchbase Lite. 

So, even if you are not a Swift developer, you should be able to leverage the Xcode playground for API exploration. This video makes no assumptions about your familiarity with Swift or iOS Development so even if you are a complete newbie to iOS development, you should be able to follow along. 


## Platform 
- iOS (Swift)
- Xcode 9.0 + 
- Swift 4.0+

## Installation
- Clone the repo from GitHub by running the following command from the terminal
  ``` bash
    $ git clone https://github.com/couchbaselabs/couchbase-lite-ios-api-playground   
  ```

-  We will use [Carthage](https://github.com/Carthage/Carthage) to download and install CouchbaseLite. If you do not have Carthage, please follow instructions [here](https://github.com/Carthage/Carthage#installing-carthage) to install Carthage on your MacOS

- Switch to folder containing the CartFile
  ``` bash
    $ cd /path/to/couchbase-lite-ios-api-playground/carthage 
  ```

- Download Couchbase Lite using Carthage . The version of Couchbase Lite used is specified in the `Cartfile`
  ``` bash
    $ carthage update --platform ios
  ```

## Setup
- Create a folder named "Shared Playground Data" within your "Documents" folder on your Mac
  ``` bash
    $ mkdir ~/Documents/Shared\ Playground\ Data/
  ```

- Copy the "travel-sample.cblite2" folder that is bundled with the repo into the "Shared Playground Data". This prebuilt database will be used for trying out the queries. Note that all the APIs will be exercised locally.

  ``` bash
    $ cd /path/to/couchbase-lite-ios-api-playground/
    $ cp  -r travel-sample.cblite2 ~/Documents/Shared\ Playground\ Data/
  ```

- Copy the "joindb.cblite2" folder that is bundled with the repo into the "Shared Playground Data". This prebuilt database will be used for trying out the queries related to JOINs. Note that all the APIs will be exercised locally.

  ``` bash
    $ cd /path/to/couchbase-lite-ios-api-playground/
    $ cp  -r joindb.cblite2 ~/Documents/Shared\ Playground\ Data/
  ```
## Exploring the Project 

- Open the `CBLTestBed.xcodeproj` using Xcode 8.3 or above
- You should see a bunch of playground pages in your project explorer. Start with the "ToC" page.

- Check `Render Documentation` checkbox in the Utilities Window to turn on rendering of the playground pages
![](https://raw.githubusercontent.com/couchbaselabs/couchbase-lite-ios-api-playground/master/pages.png?token=AAnYg2SJc85cx_1sesr6VMPyCCvXzEyBks5aCbEgwA%3D%3D)

- From the "ToC" page, you can navigate to any of the other playground pages. Each playground page exercises a set of queries against the "travel-sample.cblite" database


## Build and Run
- The very first time, you will need to build `CouchbaseLiteSwift.framework`. For this, select the "CBL Swift" scheme and build it using *Cmd-B* as shown below. You will not be required to build CBLite Swift framework unless you update to a different version of Couchbase Lite.

![](https://raw.githubusercontent.com/couchbaselabs/couchbase-lite-ios-api-playground/master/build.png?token=AAnYgwn3F982pAEPUSUx8y7JIfzLpg-Kks5aCbMYwA%3D%3D)

- Select the playground that you want to Execute a playground by clicking on the "Run" button
![](https://raw.githubusercontent.com/couchbaselabs/couchbase-lite-ios-api-playground/master/run_page.gif?token=AAnYg1rpGHsrE3u5F7ZqEPdp8ub1iRd-ks5aCbFVwA%3D%3D)
