APIResponseSpoofer is a network request-response recording and replaying library for iOS. It's built on top of the [Foundation URL Loading System](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html) to make recording and replaying network requests really simple.

## How to Get Started
Embed APIResponseSpoofer.framework in your project by draggig it into the Target > General > Embedded Binaries section. When asked whether to copy in, say Yes. In AppDelegate or any other class you need the spoofer functionality, import it as below.
```swift
@import APIResponseSpoofer
```

####Start Recording
```swift
Spoofer.startRecording(scenarioName: "Give a name to your scenario")
```

Each scenario needs a name. Preferably keep this short so that it can be displayed as a list in device/simulator without word wrap. Once a cycle of recording finishes (end to end), stop the recording and this will save the requests and responses for that session under the scenario.

If UI Testing / BDD / Users need to provide a name for the scenario from UI instead from code, invoke startRecording passing in the view controller from which to display a popup for naming the scenario.

```swift
Spoofer.startRecording(scenarioName: "", inViewController: self)
```

####Stop Recording
Stop recording and save the scenario in the applications Documents/Spoofer directory
```swift
Spoofer.stopRecording()
```

####Start Replay
```swift
Spoofer.startReplaying(scenarioName: "Give the scenario name to replay")
```

If instead what you need is a listing of all scenarios and a convenient way to start replaying the scenario, invoke the spoofer as below asking it to show you a list of scenarios. This will popup a tableview with a list of all available scenarios, tapping one will start the replay for that particular scenario.
```swift
Spoofer.showRecordedScenarios(inViewController: self)
```

####Stop Replay
Stop replaying the current scenario
```swift
Spoofer.stopReplaying()
```

####Whitelisting host names to record
By default, the spoofer will intercept and save all HTTP requests and responses originating from an app. If you need to be selective, provide an array of domains you want to record requests and responses from as below. Once domainsToSpoof is set, only the specified domain calls will be intercepted.
```swift
Spoofer.domainsToSpoof(["example1.com","example2.com"])
```

####Ignoring query parameters
The spoofer normalizes request url and uses that as a key to save the responses. Normalization strips the paramater values and uses query parameter names alone. It also strips the port and fragment. For e.g. http://www.example.com:8042/over/there/index.html?class=vehicle&type=2wheeler&name=ferrari#red becomes www.example.com/over/there/index.html?class&type&name after normalization. Provide an array of query parameters that needs to be ignored (in case query parameters are dynamic and you want to ignore them).
```swift
Spoofer.queryParametersToIgnore(["dynamicparameter","ignoreme"])
```

####Receiving call back from the spoofer
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

## Integrating via Dependency management

#####Cocoapods
```ruby
platform :ios, '8.0'
pod "APIResponseSpoofer", "~> 1.0"
```

##### Carthage
```ruby
github "Hotwire/APIResponseSpoofer" ~> 1.0
```