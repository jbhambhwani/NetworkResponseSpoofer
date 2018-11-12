# NetworkResponseSpoofer

NetworkResponseSpoofer is a network response record and replay library for iOS, watchOS, tvOS and macOS. It's built on top of the [Foundation URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system) to make recording and replaying network requests really simple.


## Getting Started
Before you start, import Spoofer framework into your project
```swift
@import NetworkResponseSpoofer
```

#### Start Recording
```swift
Spoofer.startRecording(inViewController: self) // Provide scenario name using built-in UI
--OR--
Spoofer.startRecording(scenarioName: "Give a name to your scenario")  // Provide scenario name directly from code
```

Recording can be either initiated by providing the scenario name from UI (BDD / UI Tests / Manual interaction) or from code if you prefer it that way. Each scenario needs a name. Once a cycle of recording finishes (end to end), stop the recording and this will save the requests and responses for that session under the scenario.


#### Stop Recording
```swift
Spoofer.stopRecording()
```
Stops recording and saves the scenario in the application's Documents directory (under Documents/Spoofer/). If you are using the built-in UI, you won't need this method.


#### Start Replay
```swift
Spoofer.showRecordedScenarios(inViewController: self) // Shows a list of recorded scenarios, select one to start replay
--OR--
Spoofer.startReplaying(scenarioName: "Scenario name to replay") // Directly start replaying a recorded scenario
```

The first method displays a list of recorded scenarios available in the documents directory. Tapping a scenario from the list starts replay immediately serving the responses from inside the scenario. If you know the scenario name already and do not want a selection UI, use the second method. The UI also allows configuring the Spoofer behavior and toggling a few settings, so give it a spin.


#### Stop Replay
Stop replaying the current scenario
```swift
Spoofer.stopReplaying()
```

If you are using the built-in UI, you won't need this method.


## Exporting and Importing scenarios
Spoofer uses the sandboxed documents folder of the app to save the scenario files. The file location is printed in console as well, for convenience. The application documents folder is a volatile place, since simulator reset and deletion of apps causes the folder to be deleted. So backup your Spoofer suites outside and use scripts to move them in and out of these folders for backup.


## Intercepting responses (optional configuration)
Spoofer swizzles default and ephemeral session configs to insert its protocols for network intercept. In case this does not seem to work, you can create a URLSessionConfiguration extension in your project and add code similar to below (for both default and ephemeral) to have the spoofer intercept any networking interactions that happen through URLSession. Then use the spoofed configuration instaed of default/ephemeral in your code. Take care that you insert Spoofer protocols in debug configuration only.

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

## Documentation
Additional details are available in [docs](./Classes/Spoofer.html).

## Advanced Configuration

#### Whitelisting host names
By default, the spoofer will intercept and save all HTTP requests and responses originating from an app. If you need to be selective, provide an array of domains you want to record requests and responses from as below. Once domainsToSpoof is set, only the specified domain calls will be intercepted.
```swift
Spoofer.hostNamesToSpoof(["example1.com","example2.com"])
```

#### Blacklisting host names
Blacklist does the opposite of above, allowing selective domain names to be ignored while Spoofer records Network requests and responses.
```swift
Spoofer.hostNamesToIgnore(["example3.com","example4.com"])
```

#### Blacklisting paths
Blacklist specific paths that need to be ignored from recording
```swift
Spoofer.pathsToIgnore(["tracking","logging"])
```

#### Ignoring paths
If end points have subdomains that need to be ignored, those can be set as below. This allows responses recorded from one realm to be played back on another. Spoofer normalizes the URL so that **example.qa.com** becomes **example.com**
```swift
Spoofer.subDomainsToNormalize(["DEV","QA","PREPROD"])
```

#### Ignoring query parameters
If constructed URL's contain query parameters which appear and go away dynamically, response lookup might fail during replay. To avoid that, setup ignore rules for such query parameters so that they are removed before URL's are compared.
```swift
Spoofer.queryParametersToNormalize(["node","swarm","cluster"])
```

#### Ignoring path components
If constructed URL's contain path components which vary between environments or so, response lookup might fail during replay. To avoid that, setup ignore rules for such path components so that they are removed before URL's are compared.
```swift
Spoofer.pathComponentsToNormalize(["v1","v1.1"])
```

#### Replacing path ranges
If constructed URL's contain path components which provide similar response and need to be interchanged or removed, a replacement can be setup. For example, in the below case, a request for a trip with id any value will be served with a saved trip response always.
```swift
Spoofer.pathRangesToReplace([URLPathRangeReplacement(start: "/trip/", end: nil, replacement: "")])
```

#### Normalize query values
```swift
Spoofer.normalizeQueryValues = true
```

Query Value Normalization causes values (not keys) of the query parameters to be dropped while comparing URL's. For most cases this means only one response is saved per end point if the query parameter keys are the same. Effects are
1. Reduced scenario file size saving some storage space.
2. Consistent response for the same end point regardless of query parameter values

#### Allow self signed certificate
```swift
Spoofer.allowSelfSignedCertificate = true
```

Allow spoofer to record from self signed certificate authority domains

## Receiving call back from the spoofer

##### Method 1
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

##### Method 2
Spoofer will fire the following notifications whenever its state changes. You can subscribe to these notifications and do any related work.
```swift
- spooferStartedRecordingNotification
- spooferStoppedRecordingNotification
- spooferStartedReplayingNotification
- spooferStoppedReplayingNotification
```

## Requirements (Latest Version)

- iOS 10+ / macOS 10.11+ / tvOS 10.0+ / watchOS 4.0+
- Xcode 10+
- Swift 4.2+

## Installation

#### Cocoapods
```ruby
pod "NetworkResponseSpoofer"
# or
pod "NetworkResponseSpoofer/SpooferUI" # Only for iOS, brings in the built-in UI to manage spoofed scenarios and settings
```

#### Carthage
```swift
github "HotwireDotCom/NetworkResponseSpoofer"
```
