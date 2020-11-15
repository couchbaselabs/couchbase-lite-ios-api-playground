
This Swift Playground demonstrates the new Query interface in Couchbase Lite 2.x. 

## Demo
A step-by-step demonstration of using the playground for testing 

[![Alt text](https://i.ytimg.com/vi/9NA2OXdSiqA/1.jpg)](https://youtu.be/9NA2OXdSiqA)

## Overview
While the Xcode playground demonstrates the queries in swift, given the unified nature of the QueryBuilder API across the various Couchbase Lite platforms, barring language specific idioms, you should be able to easily translate the queries to any of the other platform languages supported in Couchbase Lite. 

So, even if you are not a Swift developer, you should be able to leverage the Xcode playground for API exploration. This video makes no assumptions about your familiarity with Swift or iOS Development so even if you are a complete newbie to iOS development, you should be able to follow along. 


## Platform 
- iOS (Swift)
- Xcode 12+ 
- Swift 5.1+

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
    $ carthage update --platform ios --no-build
  ```

## Exploring the Project 

- Open the `CBLQueryTestBed.xcworkspace` using Xcode12

``` bash
  cd /path/to/couchbase-lite-ios-api-playground/
  open CBLQueryTestBed.xcworkspace
```
- You should see a bunch of playground pages in your project explorer. Start with the "ToC" page.

- Check `Render Documentation` checkbox in the Utilities Window to turn on rendering of the playground pages
![](https://raw.githubusercontent.com/couchbaselabs/couchbase-lite-ios-api-playground/master/pages.png?token=AAnYg2SJc85cx_1sesr6VMPyCCvXzEyBks5aCbEgwA%3D%3D)

- From the "ToC" page, you can navigate to any of the other playground pages. Each playground page exercises a set of queries against the "travel-sample.cblite" database


## Build and Run

- Navigate to playground page that you want to run

- Select the "CBLTestBed" scheme with simulator target. This should be the active scheme

- Do a clean of build  using *Cmd-Shift-K*. You will have to do that for every page

- Run the playground. This will automatically build the dependent frameworks. Be patient- this will take a minute or so to build

*TROUBLESHOOTING TIPS*:

  - Supporting third party frameworks within xcode playgrounds is quite glitchy and it could take couple of build attempts to resolve the dependencies. If you see an error about "Couldn't lookup symbols", just re-run the playground


- Select the playground that you want to Execute a playground by clicking on the "Run" button
![](https://raw.githubusercontent.com/couchbaselabs/couchbase-lite-ios-api-playground/master/run_page.gif?token=AAnYg1rpGHsrE3u5F7ZqEPdp8ub1iRd-ks5aCbFVwA%3D%3D)
