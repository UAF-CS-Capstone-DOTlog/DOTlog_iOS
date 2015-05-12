# **Section 1 - DOTlog iOS Description**

## 1.1 DOTlog iOS

DOTlog iOS is the Apple iOS application component of DOTlog

## 1.2 Description

DOTlog iOS provides a mechanism for DOTlog event creation. Users login to the app and sync their airports and categories from the DOTlog server. Once initially synced, DOTlog users can enter events without network connectivity to the DOTlog server, syncing back events at a later date.

## 1.3 Revision History


| **Date**          | **Comment**         | **Author**         |
|-------------------|---------------------|--------------------|
| 2015-05-04        | Initial Version     | William Showalter  |
| 2015-05-11        | Updated error codes | William Showalter  |
|                   |                     |                    |


**Table of Contents**

- [Section 1 - DOTlog iOS Description](#section-1---dotlog-ios-description)
 - [1.1 DOTlog iOS](#11-dotlog-ios)
 - [1.2 Description](#12-description)
 - [1.3 Revision History](#13-revision-history)
- [Section 2 - Overview](#section-2---overview)
 - [2.1 Purpose](#21-purpose)
 - [2.2 Scope](#22-scope)
 - [2.3 Requirements](#23-requirements)
- [Section 3 - System Architecture](#section-3---system-architecture)
- [Section 4 - Core Data Model](#section-4---core-data-model)
- [Section 5 - Software Design](#section-5---software-design)
 - [5.1 iOS Storyboard and Views](#51-ios-storyboard-and-views)
 - [5.2 API Handling Components](#52-api-handling-components)
- [Section 6 – Components to customize in final environment](#section-6--components-to-customize-in-final-environment)
 - [6.1 Default DOTlog Domain Address](#61-default-dotlog-domain-address)
 - [6.2 API URIs](#62-api-uris)
 - [6.3 Default HTTPS behavior](#63-default-https-behavior)
- [Section 7 - Alert and Error Documentation](#section-7---alert-and-error-documentation)
 - [7.1 Alert Messages](#71-alert-messages)
  - [7.1.1 Events List Messages](#711-events-list-messages)
  - [7.1.2 Add Event Messages](#712-add-event-messages)
 - [7.2 Syncing & API Errors](#72-syncing--api-errors)
  - [7.2.1 Airport API Errors](#721-airport-api-errors)
  - [7.2.2 Category API Errors](#722-category-api-errors)
  - [7.2.3 Events API Errors](#723-events-api-errors)
  - [7.2.4 Network API Errors](#724-network-api-errors)
- [Section 8 - Dependent & Included Libraries / Frameworks / Assets](#section-8---dependent--included-libraries--frameworks--assets)
 - [8.1 SwiftyJSON](#81-swiftyjson)
 - [8.2 Locksmith](#82-locksmith)
 - [8.3 Icons & Images](#83-icons--images)
- [Section 9 - Extra Design Features / Outstanding Issues](#section-9---extra-design-features--outstanding-issues)
 - [9.1 Logout must exit app & User misreporting](#91-logout-must-exit-app--user-misreporting)
 - [9.2 KeychainAccess errors ignored](#92-keychainaccess-errors-ignored)
 - [9.3 Summary Field maximum length](#93-summary-field-maximum-length)
- [Section 10 – References](#section-10--references)
- [Section 11 – Glossary](#section-11--glossary)

# **Section 2 - Overview**

## 2.1 Purpose

This documentation is intended for the Department of Transportation Information Technology staff and anyone tasked with supporting users of DOTlog iOS. This documentation will give any reader an understanding of all the parts of DOTlog iOS and how to work with and troubleshoot it.

## 2.2 Scope

DOTlog iOS is intended for use by any DOTlog users with the State of Alaska DOT, particularly those users who may be in the field or without constant internet connectivity.

## 2.3 Requirements

iOS 8.2

Xcode 6.3 (for compilation)



# **Section 3 - System Architecture**

![iOS Sync Architecture](/Documentation/Assets/iOSSyncArchitecture.png)

DOTlog iOS will be integrate with the DOTlog ColdFusion web application, performing Windows(NTLM) authentication to the web server and performing syncing with the DOTlog API.

# 

# **Section 4 - Core Data Model**

![iOS CoreData](/Documentation/Assets/iOSCoreData.png)

Local storage is achieved using Apple’s built in Core Data model utilities. An entity description is provided below.

# **Section 5 - Software Design**

## 5.1 iOS Storyboard and Views

![Storyboard Diagram](/Documentation/Assets/iOSStoryboard.png)

The iOS app uses a number of types of view components. 

The regions of the Storyboard are shown in the diagram above and follow the hierarchy:



TabBarViewController - Splits app into two Tabs, Events and Accounts Settings

ViewEventsList - Lists events and has Sync and Add Event buttons

ViewSyncCredentials - Displayed when sync called if no credentials saved

ViewAddEvent - View for adding new event.

ViewAddEventCategory - View for selecting event category

ViewAddEventRegion - View for selecting event region, if > 1.

ViewAddEventDistrict - View for selecting event district, if > 1.

ViewAddEventHub - View for selecting event hub, if > 1.

ViewAddEventAirport - View for selecting event airport.

ViewAccountsSettings - Shows server address and saved login information.

ViewAccountsSettingsTableView - Allows for well formatted data presentation.

## 5.2 API Handling Components



![API Sync UML](/Documentation/Assets/iOSSyncUML.png)

UML Class diagram of the classes involved in the API handling.

# **Section 6 – Components to customize in final environment**

When DOTlog iOS is deployed there are components which may require adjusting to match the final environment.

## 6.1 Default DOTlog Domain Address

**Description** : The default URL that populates the Address field in the Account Settings tab. Should include http/https specification and not have anything trailing after TLD.

**File** : DOTlog/API/APIResource.swift

**Variable** : defaultBaseURL

## 6.2 API URIs

**Description** : The location where the APIs keep the resource identifiers.

**Files** : DOTlog/API/APIAirportResource.swift & APICategoryResource.swift & APIEventResource.swift

**Variables** : airportURI, categoryURI, eventURI

## 6.3 Default HTTPS behavior

**Description** : When a user enters a domain without specifying a protocol scheme, it will default to HTTPS. Users may type HTTP manually to achieve that result. Behavior by modifying the scheme variable in saveURL function.

**File** : DOTlog/Views/ViewAccountSettingsTableView.swift

**Variable** : `scheme` local to saveURL function.



# **Section 7 - Alert and Error Documentation**

## 7.1 Alert Messages

A number of events will cause an alert to be displayed to the user, and are documented here.

### 7.1.1 Events List Messages

**Error Message:** Run Initial Sync Before Adding Events

**Description of Problem** : Airports and/or Categories are empty so events cannot be added.



**Error Message:** Sync Completed Successfully

**Description of Problem** : A successful sync occurred without any errors being received.



**Error Message:** Unable to Sync

**Description of Problem** : The sync was unable to complete, the details page will give an error code. Codes are described in 7.2.



### 7.1.2 Add Event Messages

**Error Message:** No Category

**Description of Problem** : No category was selected by the user in the Add Event screen before trying to save.



**Error Message:** No Airport

**Description of Problem** : No airport was selected by the user in the Add Event screen before trying to save.



**Error Message:** No Event Summary

**Description of Problem** : No event text was entered in the Add Event before trying to save.



## 7.2 Syncing & API Errors

### 7.2.1 Airport API Errors

**Error Code** : 10

**Description of Problem** : No name found for airport in JSON received from webserver. Region, District, and Hubs were parsed.



**Error Code** : 11

**Description of Problem** : No airports were found within a hub JSON object received from webserver. Region, District, and Hub name were parsed.



**Error Code** : 12

**Description of Problem** : No name found within a hub JSON object received from webserver. Region and District were parsed.



**Error Code** : 13

**Description of Problem** :  No hubs were found within a district JSON object received from webserver. Region and and district name were parsed.



**Error Code** : 14

**Description of Problem** :  No name found within a district JSON object received from webserver. Region was parsed.



**Error Code** : 15

**Description of Problem** :  No districts were found within a region JSON object received from webserver. Region was parsed.



**Error Code** : 16

**Description of Problem** :  No name was found for the region. Regions array was parsed correctly.



**Error Code** : 17

**Description of Problem** : Could not read JSON object or open the REGIONS array within the JSON object.



### 7.2.2 Category API Errors

**Error Code** : 20

**Description of Problem** : Could not read JSON object or open the CATEGORIES array within the JSON correctly.



**Error Code** : 21

**Description of Problem** : JSON objects without "CATEGORY_TITLE" fields were found inside the CATEGORIES array and could not be parsed.



### 7.2.3 Events API Errors

**Error Code** : 430

**Description of Problem** : User is submitting events for airports they do not own. To resolve, delete and recreate events in the app after deleting all events and resyncing.



**Error Code** : 431

**Description of Problem** : Airport not found in database



**Error Code** : 432

**Description of Problem** : Category not found in database



### 7.2.4 Network API Errors

**Error Code** : 401

**Description of Problem** : Incorrect Username or Password - returned if Windows/NTLM authentication with web server server fails.



**Error Code** : 445

**Description of Problem** : User not in DOTlog, but successfully authenticated to server.



**Error Code** : Others

**Description of Problem** : Any not explicitly caught network error returns the code given by the iOS networking library, and can be referenced in the Apple documentation. 

# **Section 8 - Dependent & Included Libraries / Frameworks / Assets**

This section contains the external projects that are incorporated in or used by DOTlog iOS. 

## 8.1 SwiftyJSON

SwiftyJSON is a JSON deserialization library for Swift. DOTlog iOS uses it to parse the JSON received from the airport and category API calls.



8.2.1 License & Copyright

SwiftyJSON is published under the MIT license, and is provided for free for any use without warranty by the copyright holder Ruoyu Fu.

8.2.2 Inclusion

SwiftyJSON is linked as a git submodule in the DOTlog iOS repository and is not redistributed in the DOTlog iOS code, although it is required for compilation.

8.2.3 Software Location

[https://github.com/SwiftyJSON/SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)

## 8.2 Locksmith

Locksmith is included inside the KeychainAccess class in DOTlog iOS. The purpose of Locksmith is to provide a Swift-friendly wrapper around Apple’s iOS keychain libraries for secure, encrypted app storage. The KeychainAccess class in DOTlog iOS uses Locksmith to store saved account credentials.



8.2.1 License & Copyright

The Locksmith version used was published under the MIT license, and is provided for free for any use without warranty by the copyright holder Matthew Palmer.

8.2.2 Inclusion

Locksmith is included in it’s entirety statically inside the KeychainAccess.swift file.

8.2.3 Software Location

[https://github.com/matthewpalmer/Locksmith/](https://github.com/matthewpalmer/Locksmith/)



## 8.3 Icons & Images

All icons in DOTlog iOS are either part of Apple’s framework or in the public domain.

The DOTlog logo was designed by Nathan Helms and is licensed within the project. The DOT banner used within the application are the property of the State of Alaska and are used in coordination of the Department of Transportation.



# **Section 9 - Extra Design Features / Outstanding Issues**

## 9.1 Logout must exit app & User misreporting

When a user attempts to logout of the App they are notified that the app must exit.

The reason behind this is that the networking library in iOS 8.1 started to use cached NTLM authentication for new network connections for a short period of time after the last use before the previous network connections fully finish closing, usually 15 to 60 seconds. This behavior is exhibited even when persistent credential storage is set to never save credentials.



Allowing a user to “logout” (clear their stored credentials) immediately would initiate their sync under the old user whose session is still active.



**NOTE** : This behavior may still happen if the username/password stored are changed without using the logout button.

## 9.2 KeychainAccess errors ignored

Any errors encountered with the internal credential storage library, or the access to it through Locksmith, are ignored. This is partially because we must delete the old credentials before storing knew ones; the delete operation returns an error if there is no existing remembered user, and as that is an expected result the error is unhandled. Errors returned in the save operation are returned by KeychainAccess but the callers do not implement error checking at this time.



## 9.3 Summary Field maximum length

The maximum length of the summary field is limited to 4000 characters. This is set in the ViewAddEvent.swift file, in the variable SUMMARYCHARLIMIT.

# **Section 10 – References**


# **Section 11 – Glossary**


---

