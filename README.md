APIResponseSpoofer is a network request-response recording and replaying library for iOS. It's built on top of the [Foundation URL Loading System](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html) to make recording and replaying network requests really simple.

## How to Get Started
Embed the APIResponseSpoofer.framework in your Project

####Start Recording
```swift
AppDelegate.swift // Or any class where you want spoofer to start recording

@import APIResponseSpoofer

Spoofer.startRecording(scenarioName: "Give a name to your scenario")
```
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

####Whitelisting host names for Recording
```swift
Spoofer.domainsToSpoof(["example.com",["api.example.com"])
```

#### Podfile

```ruby
platform :ios, '8.0'
pod "APIResponseSpoofer", "~> 1.0"
```
