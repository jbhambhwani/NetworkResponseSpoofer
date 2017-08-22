# APIResponseSpoofer

APIResponseSpoofer is a network request-response recording and replaying library for iOS. It's built on top of the [Foundation URL Loading System](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html) to make recording and replaying network requests really simple.


## Getting Started
Before you start, import Spoofer framework into your project
```swift
@import APIResponseSpoofer
```

## Intercepting responses
Spoofer swizzles default and ephemeral session configs to insert its protocols for network intercept. In case this does not seem to work, you can create a URLSessionConfiguration extension in your project and add code similar to below (for both default and ephemeral) to have the spoofer intercept any networking interactions that happen through NSURLSession. Then use the spoofed configuration instaed of default/ephemeral in your code. Take care not to insert Spoofer protocols in release mode.
```swift
extension URLSessionConfiguration {

    static var spoofedDefault: URLSessionConfiguration {

        let sessionConfig = URLSessionConfiguration.default
        #if DEBUG
            var protocolClasses = sessionConfig.protocolClasses
            protocolClasses?.insert(SpooferRecorder.self, at: 0)
            protocolClasses?.insert(SpooferReplayer.self, at: 0)
            sessionConfig.protocolClasses = protocolClasses
        #endif

        return sessionConfig
    }
}
```


###Start Recording
```swift
Spoofer.startRecording(inViewController: self) // Provide scenario name using popup UI
--OR--
Spoofer.startRecording(scenarioName: "Give a name to your scenario")  // Provide scenario name directly from code
```

Recording can be either initiated by providing the scenario name from UI (BDD / UI Tests / Manually) or from code if you prefer it that way. Each scenario needs a name. Preferably keep this short so that it can be displayed as a list in device/simulator without word wrap. Once a cycle of recording finishes (end to end), stop the recording and this will save the requests and responses for that session under the scenario.


###Stop Recording
```swift
Spoofer.stopRecording()
```
Stops recording and saves the scenario in the application's sandboxed Documents directory (under /Spoofer)


###Start Replay
```swift
Spoofer.showRecordedScenarios(inViewController: self) // Shows a list of recorded scenarios, select one to start replay
--OR--
Spoofer.startReplaying(scenarioName: "Scenario name to replay") // Directly start replaying a recorded scenario
```

The first method displays a list of recorded scenarios available in the application documents directory. Tapping a scenario from the list starts replay immediately serving the responses from inside the scenario. If you know the scenario name already and do not want a selection UI, use the second method. The UI also allows configuring the Spoofer behavior and toggling a few settings, so give it a spin.


###Stop Replay
Stop replaying the current scenario
```swift
Spoofer.stopReplaying()
```

##Exporting and Importing scenarios
Spoofer uses the sandboxed documents folder of the app to save the scenario files.

##Documentation
Read the [docs](./Classes/Spoofer.html).

##Advanced Configuration

###Whitelisting host names
By default, the spoofer will intercept and save all HTTP requests and responses originating from an app. If you need to be selective, provide an array of domains you want to record requests and responses from as below. Once domainsToSpoof is set, only the specified domain calls will be intercepted.
```swift
Spoofer.hostNamesToSpoof(["example1.com","example2.com"])
```

###Blacklisting host names
Blacklist does the opposite of above, allowing selective domain names to be ignored while Spoofer records API requests and responses.
```swift
Spoofer.hostNamesToIgnore(["example3.com","example4.com"])
```

###Ignoring subdomains
If end points have subdomains that need to be ignored, those can be set as below. This allows responses recorded from one realm to be played back on another. Spoofer normalizes the URL so that **example.qa.com** becomes **example.com**
```swift
Spoofer.subDomainsToIgnore(["DEV","QA","PREPROD"])
```

###Ignoring query parameters
If constructed URL's contain query parameters which appear and go away dynamically, response lookup might fail during replay. To avoid that, setup ignore rules for such query parameters so that they are removed before URL's are compared.
```swift
Spoofer.queryParametersToIgnore(["node","swarm","cluster"])
```

###Normalize query parameters
```swift
Spoofer.normalizeQueryParameters = true
```

Query Parameter Normalization causes values (not keys) of the query parameters to be dropped while comparing URL's. For most cases this means only one response is saved per end point if the query parameter keys are the same. Effects are
1. Reduced scenario file size saving some storage space.
2. Consistent response for the same end point regardless of query parameter values

###Allow self signed certificate
```swift
Spoofer.allowSelfSignedCertificate = true
```

Allow spoofer to record from self signed certificate authority domains

##Receiving call back from the spoofer

#####Method 1
If you need to update UI or respond to the spoofer state changes, implement the SpooferDelegate protocol and use the delegate callbacks to do so.
```swift
class MyClass: SpooferDelegate {

    init() {
        // Some setup code
        ...
        Spoofer.delegate = self
    }

}

```
And then implement the below methods
```swift
func spooferDidStartRecording(scenarioName: String)
func spooferDidStopRecording(scenarioName: String, success: Bool)
func spooferDidStartReplaying(scenarioName: String, success: Bool)
func spooferDidStopReplaying(scenarioName: String)
```

#####Method 2
Spoofer will fire the following notifications whenever its state changes. You can subscribe to these notifications and do any related work.
- spooferStartedRecordingNotification
- spooferStoppedRecordingNotification
- spooferStartedReplayingNotification
- spooferStoppedReplayingNotification

##Installation

###Cocoapods
```ruby
platform :ios, '8.0'
pod "APIResponseSpoofer", "~> 4.0"
```

###Carthage
```ruby
github "Hotwire/APIResponseSpoofer" ~> 4.0
```
