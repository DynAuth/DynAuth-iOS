# GeoAuth Client for iOS
This is the GeoAuth iOS client. It is designed for use on the iPhone (not the iPad), both retina and non-retina variants.

## Instructions

1. Launch XCode
2. Open the ``GeoAuth.xcworkspace`` workspace file (this is required to load the CocoaPods frameworks used for this project
3. Choose a simulator target (tested on iOS 6.1 only, as this is what I run)
4. Press "Run" (or Command-R) to build and run the application
5. To test location in the simulator, in the menu bar go to **Debug -> Location -> Freeway Drive**, which will simulate a freeway drive for location updates from the simulator
6. To set the device ID to something other than the hardcoded ID: request a new device key from the server, enter that device key and the device name, and press "Register", which will consume the device key, and store the new device ID for future use

## Third Party Libraries
This client makes extensive use of Mugunth Kumar's MKNetworkKit library for all HTTP requests.
