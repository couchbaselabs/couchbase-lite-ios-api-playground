This Swift Playground demonostrates the new Query interface in Couchbase Lite 2.0. 

## Platform 
- iOS (Swift)
- Xcode 8.3+
- Swift 3.1+

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

## Exploring the Project 

- Open the `CBLTestBed.xcodeproj` using Xcode 8.3 or above
- You should see a bunch of playground pages in your project explorer. Start with the "ToC" page.

- Check `Render Documentation` checkbox in the Utilities Window to turn on rendering of the playground pages
![](https://raw.githubusercontent.com/couchbaselabs/couchbase-lite-ios-api-playground/master/pages.png?token=AAnYg2SJc85cx_1sesr6VMPyCCvXzEyBks5aCbEgwA%3D%3D)

- From the "ToC" page, you can navigate to any of the other playground pages. Each playground page execises a set of queries against the "travel-sample.cblite" database


## Build and Run
- The very first time, you will need to build `CouchbaseLiteSwift.framework`. For this, select the "CBL Swift" scheme and build it using *Cmd-B* as shown below. You will not be required to build CBLite Swift framework unless you update to a different version of Couchbase Lite. 
- Select the playground that you want to Execute a playground by clicking on the "Run" button
![](https://raw.githubusercontent.com/couchbaselabs/couchbase-lite-ios-api-playground/master/run_page.gif?token=AAnYg1rpGHsrE3u5F7ZqEPdp8ub1iRd-ks5aCbFVwA%3D%3D)
