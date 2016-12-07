# AcronymFinder
A simple app to look up the meanings of acronyms/initialisms. 

App written in Objective-C and supports Xcode 8 

App is developed using Storyboards and has only one screen as described below.

Acronym Finder - This has a textfield which accepts valid Acronyms / Initialisms. On entering the word and hit "search" key, webservice api is called and corresponding meanings are shown in a table view. If no meanings are found / if any webservice errors, an alert is shown with proper message. TextField can accept only alpha numeric values. TextField require atleast 1 character and maximum 30 characters.
    
Below API is used to fetch the meanings.
http://www.nactem.ac.uk/software/acromine/rest.html - This is GET request.

Cocoapods are used as dependency manager to add below projects:

   1. ‘AFNetworking’, ‘~> 2.0’ (https://github.com/AFNetworking/AFNetworking)

   2. ‘MBProgressHUD’, ‘~> 1.0.0’ (https://github.com/jdg/MBProgressHUD)
