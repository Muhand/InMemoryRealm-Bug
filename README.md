# InMemoryRealm-Bug
Issue can be tracked here: https://github.com/realm/realm-cocoa/issues/7017

**NOTE: This only happens using `InMemoryRealm` configuration something like `Realm.Configuration(inMemoryIdentifier: "messagesRealm")`**

## Goals
I am writing a cache protocol which I can implement later using any or multiple cache libraries (regardless of disk or memory), in this case it is `Realm`

## Expected Results
Expectation was when the save function is called realm should successfully save the object in memory and when retrieved it should return it successfully or return all objects. 

## Actual Results
In memory realm is returning empty every time I insert something and try to fetch it (I am 100% sure it is inserting successfully and I will explain later why)

## Steps for others to Reproduce
### Reproduce the problem
1. Clone the git repository in `Code Sample`
2. Compile and run on a simulator/device (they both are giving the same results)
3. In the `Message` field write anything
4. Press `Save`
5. Now press `Refresh` it should populate a list with data but it won't do it

### What I have done
- While reproducing the problem navigate to `Realm` -> `InMemoryRealmCache.swift` and setup a breakpoint at line `94`.
- Now run the application again and repeat step `3` to `4` the application should break after pressing `Save`
- In the `lldb` write `po realm.objects(MessageRealmEntity.self)` and finally continue the application
- Now press `Refresh` and the list will be populated No matter how many times you add and refresh it will work now 100%.

### Video to show the problem and how to reproduce
https://user-images.githubusercontent.com/12287547/102961663-e3b3a200-44b2-11eb-8cc4-a19ed831c6c1.mov

## Code Sample
This is a git repository for a dummy application to reproduce the bug: 

https://github.com/Muhand/InMemoryRealm-Bug

## Version of Realm and Tooling

Realm framework version: RealmSwift (10.1.4)

Realm Object Server version: ?

Xcode version: Version 12.2 (12B45b)

iOS/OSX version: iOS 14.2

Dependency manager + version: ?

## Few important notes
- As can be seen in the project I am initializing `Realm` in every function in my wrapper this way I can avoid `Realm accessed from incorrect thread` issue.
- However, to avoid realm being initialized on different threads I made sure to set a `DispatchQueue` in which they all are initialized and ran in.
- I have tried making my `Realm` object to be static and living somewhere else but this is not scalable and if someone in the team called the functions from a different thread it can crash the app with the error `Realm accessed from incorrect thread` 
- The wrapper works 100% fine if I am using disk realm instead of memory
- The wrapper is initialized only once so I don't have multiple instances of it
