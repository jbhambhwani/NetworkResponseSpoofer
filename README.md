APIResponseSpoofer is a network request-response recording and replaying library for iOS. It's built on top of the [Foundation URL Loading System](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html) to make recording and replaying network requests really simple.

## How to Get Started
Embed the APIResponseSpoofer.framework in your project

####Start Recording
```swift
AppDelegate.swift // Or any class where you want spoofer to start recording

@import APIResponseSpoofer

Spoofer.startRecording(scenarioName: "Give a name to your scenario")
```

Each scenario needs a name. This could be anything, preferably keep this short so that it can be displayed as a list in device/simulator without word wrap. Once a cycle of recording finishes (end to end), stop the recording and this will save the requests and responses for that session under the scenario name.

####Stop Recording
```swift
Spoofer.stopRecording()
```

####Start Replay
```swift
AppDelegate.swift // Or any class where you want spoofer to start recording

@import APIResponseSpoofer

Spoofer.startReplaying(scenarioName: "Give the scenario name to replay")
```

####Stop Replay
```swift
Spoofer.stopReplaying()
```

####Whitelisting host names to record
Provide an array of domains you want to record requests and responses from as below
```swift
Spoofer.domainsToSpoof(["example.com",["api.example.com"])
```

#### Podfile

```ruby
platform :ios, '8.0'
pod "APIResponseSpoofer", "~> 1.0"
```
