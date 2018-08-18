#Welcome to the Stitch Workshop on How to Make a Nexmo's In-App Voice Call with Apple's iOS CallKit 

In this workshop learn how your Nexmo In-App Voice integrations can use Apple's CallKit for system-level phone functionalities such as dial pad, call or hangup. 

Note: CallKit features do work in the simulator. In order to follow along with this tutorial, you’ll need an iPhone with iOS 11 installed.

## What is Nexmo In-App Voice

Nexmo In-App Messaging, In-App Voice, and In-App Video is part of a single, conversation centric API offered by Nexmo, the Vonage API Platform. Nexmo In-App Voice leverages the rising power of WebRTC to enable developers and builders of all kinds to create and deliver fully programmable, feature rich voice applications and experiences across the cloud. 

### Concepts 

There are just a few key concepts. These are: 

- __Conversation__

A conversation is a shared core component that Nexmo APIs rely on. Conversations happen over multiple mediums and and can have associated Users through Memberships.

- __User__

The concept of a user exists in Nexmo APIs, you can associate one with a user in your own application if you choose. A user can have multiple memberships to conversations and can communicate with other users through various different mediums.

- __Member__

Memberships connect users with conversations. Each membership has one conversation and one user however a user can have many memberships to conversations just as conversations can have many members.

- __Audio__

Audio streams can be enabled and disabled in a Conversation so that Members can communicate with voice.

- __Media Events__

Media events will fire in a Conversation when media state changes for a member. This can be when an Audio stream is started or ended.

### Goal

In this workshop we use all of the concepts that are key to Nexmo In-App Voice for initiating a call with Apple's iOS CallKit.  

## What is Apple's CallKit

CallKit is a relatively new framework that facilitates integrations like Nexmo's In-App Voice for rich VoIP experiences with the iPhone/iPad's native calling UI. Integrations with Apple's CallKit use Apple's own incoming call screen in both locked / unlocked states, allowing end users to initiate Nexmo In-App Voice calls from an iPhone app’s Contacts, Favorites or Recents screens. 

![iOS call screen](assets/callingHome.jpg)


## Getting Started 

Download the starter project [here](https://github.com/Nexmo/stitch-demo-ios). To get the app up and running on your localhost, you follow the directions for the server [here](https://github.com/Nexmo/stitch-demo). After you are able to get up and running, test out your setup by creating a member, joining a conversation and triggering an event. If everything worked out well, you are all setup! You go and make an outgoing call now! 

### Make an Outgoing Call 

To make an outgoing call with CallKit, an app requests an action from a controller. In much the same way as `UIAlertController`s operate, an app requests a `CXStartCallAction` object from its `CXCallController` object. This action, however, consists of a UUID to uniquely identify the call and a `CXHandle` object to specify the recipient.

You set the constants for this method call:

```Swift 
let uuid = UUID()
let handle = CXHandle(type: .emailAddress, value: "timcook@apple.com")
```

You create an action setting its destination to the handle we set above and embed it into a transaction: 
 
```Swift
let startCallAction = CXStartCallAction(call: uuid)
startCallAction.destination = handle
let transaction = CXTransaction(action: startCallAction)
```
You pass your transaction into a controller's request, just as stated above. 

```Swift
callController.request(transaction) { error in
    if let error = error {
        print("Error requesting transaction: \(error)")
    } else {
        print("Requested transaction successfully")
    }
}
```
Voila! There is how the CallKit works. In your integration, however, you perform these same steps, except differently, since the Nexmo Stitch In-App Messaging SDK handles the calling functionality for us with convenience call methods. You go and refactor this setup for your iOS app now. 

#### First Step 

The first step is to create a `Caller` object. Here you configure the UUID and handle and set it up as an initializable object. You call this file the caller. 

```Swift
import Foundation

enum CallState {
    case connecting
    case active
    case held
    case ended
}

enum ConnectedState {
    case pending
    case complete
}
```
After setting up a few states for the call and the connection, you declare a class called `Caller`. 

```Swift
class Caller {
    
    let uuid: UUID
    let outgoing: Bool
    let handle: String
    
    var state: CallState = .ended {
        didSet {
            stateChanged?()
        }
    }
    
    var connectedState: ConnectedState = .pending {
        didSet {
            connectedStateChanged?()
        }
    }
    
    var stateChanged: (() -> Void)?
    var connectedStateChanged: (() -> Void)?
    
    init(uuid: UUID, outgoing: Bool = false, handle: String) {
        self.uuid = uuid
        self.outgoing = outgoing
        self.handle = handle
    }
    
    func start(completion: ((_ success: Bool) -> Void)?) {
        completion?(true)
        
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 3) {
            self.state = .connecting
            self.connectedState = .pending
            
            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 1.5) {
                self.state = .active
                self.connectedState = .complete
            }
        }
    }
 
    func answer() {
        state = .active
    }
    
    func end() {
        state = .ended
    }
    
}
```
In the initializer you set the properties to be assigned such values as `UUID`, `outgoing` or `handle`, two of which were mentioned above. The remaining methods facilitate the initialization. Two other methods are native to the Nexmo In-App Voice SDK (i.e., `.answer()` and `.end`). 

#### Second Step 

With our `Caller` object set up, you create a `CallManager` to handle calls, control and make requests and process transactions, as mentioned above. 

To start off you `import` `Foundation` and `CallKit`.   

```Swift 
import Foundation
import CallKit
```

Underneath the imports you create a class called `CallManager`, which follows the same style as many of Apple's own native "managers" such as Apple's `CCLocationManager`. 

```Swift
class CallManager {
    
    private let callController = CXCallController()
    
    var callsChangedHandler: (() -> Void)?
    
    private(set) var calls = [Caller]()
    
    func callWithUUID(uuid: UUID) -> Caller? {
        guard let index = calls.index(where: { $0.uuid == uuid }) else {
            return nil
        }
        return calls[index]
    }
}
```
Your first property is an instance of `CXCallController()`, a placeholder for `Caller` objects and a method for calling with `UUID`s. Below are the remaining boilerplate that you configure. 

```Swift
    func startCall(handle: String, videoEnabled: Bool) {
        let handle = CXHandle(type: .phoneNumber, value: handle)
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)
        startCallAction.isVideo = videoEnabled
        let transaction = CXTransaction(action: startCallAction)
        requestTransaction(transaction)
    }
    
    func add(call: Caller) {
        calls.append(call)
        call.stateChanged = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.callsChangedHandler?()
        }
        callsChangedHandler?()
    }
    
    func end(call: Caller) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction(action: endCallAction)
        requestTransaction(transaction)
    }
    
    func remove(call: Caller) {
        guard let index = calls.index(where: { $0 === call }) else { return }
        calls.remove(at: index)
        callsChangedHandler?()
    }
    
    func removeAllCalls() {
        calls.removeAll()
        callsChangedHandler?()
    }
    
    func setHeld(call: Caller, onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)
        requestTransaction(transaction)
    }
    
    private func requestTransaction(_ transaction: CXTransaction) {
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
            }
        }
    }
```
Most of these methods are straightforward. `startCall()` is almost verbatim Apple's own destination, handle and transaction as shared above, except you embed these elements into a method so that `requestTransaction()`, the last method, is daisy-chained. 

#### Receiving an Incoming Call 
Come now the incoming calls. To configure your app to receive incoming calls, first create a `CXProvider` object and store it for global access. Using information provided by the external notification, the app creates a UUID and a `CXCallUpdate` object to uniquely identify the call and the caller, and passes them both to the provider using the `reportNewIncomingCall(with:update:completion:)` method as shown below.

```Swift 
if let uuidString = payload.dictionaryPayload["UUID"] as? String,
    let identifier = payload.dictionaryPayload["identifier"] as? String,
    let uuid = UUID(uuidString: uuidString)
{
    let update = CXCallUpdate()    
    update.callerIdentifier = identifier
    
    provider.reportNewIncomingCall(with: uuid, update: update) { error in
        // …
    }
}
```

After the call is connected, the system calls the `provider(_:perform:)` method of the provider delegate to handle the incoming call. In your implementation, the delegate, which is called the `ProviderDelegate` in your project` is responsible for configuring an `AVAudioSession` and calling `fulfill()` on the action when finished, as is shown below.

```Swift
func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    // configure audio session
    action.fulfill()
}
```

#### Third Step

Your provider is a Nexmo In-App Voice call so you configure your iOS app to interface with this API. 

```
import AVFoundation
import CallKit

class ProviderDelegate: NSObject {
    
    fileprivate let callManager: CallManager
    fileprivate let provider: CXProvider
    
    init(callManager: CallManager) {
        self.callManager = callManager
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    static var providerConfiguration: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration(localizedName: "Stitch")
        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
        
        return providerConfiguration
    }
    
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)?) {
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.hasVideo = hasVideo
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            if error == nil {
                let call = Caller(uuid: uuid, handle: handle)
                self.callManager.add(call: call)
            }
            
            completion?(error as NSError?)
        }
    }
}
``` 
After creating the class for the provider delegate, you extend its functionality to implement the `CXProviderDelegate`'s required methods. 

```Swift
extension ProviderDelegate: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
        stopAudio()
        
        for call in callManager.calls {
            call.end()
        }
        
        callManager.removeAllCalls()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        configureAudioSession()
        call.answer()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        startAudio()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        stopAudio()
        call.end()
        action.fulfill()
        callManager.remove(call: call)
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        let call = Caller(uuid: action.callUUID, outgoing: true, handle: action.handle.value)
        
        configureAudioSession()
        
        call.connectedStateChanged = { [weak self, weak call] in
            guard let strongSelf = self, let call = call else { return }
            
            if call.connectedState == .pending {
                strongSelf.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: nil)
            } else if call.connectedState == .complete {
                strongSelf.provider.reportOutgoingCall(with: call.uuid, connectedAt: nil)
            }
        }
        
        call.start { [weak self, weak call] success in
            guard let strongSelf = self, let call = call else { return }
            
            if success {
                action.fulfill()
                strongSelf.callManager.add(call: call)
            } else {
                action.fail()
            }
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.state = action.isOnHold ? .held : .active
        if call.state == .held {
            stopAudio()
        } else {
            startAudio()
        }
        action.fulfill()
    }
}
```
Simplified, the code above covers a set of actions such as `CXAnswerCallAction`, `CXEndCallAction`, `CXStartCallAction`, `CXSetHeldCallAction`. Thankfully, these methods are mostly boilerplate so filling in the blanks is straightforward. 

#### Fourth Step 

With the proper setup in place you configure CallKit to operate with Nexmo In-App Voice. You add a property for initializing an instance of `CallManager` to handle outgoing, incoming calls in `ChatVC.swift`. 

```Swift 
var callManager: CallManager!
```
With an instance of `callManager` available you configure `endCall()` to end a call. 

```Swift 
@IBAction func endCallAction(_ sender: Any) {
        
        call?.hangUp(onSuccess: { [weak self] in
            self?.conversation?.media.disable()
            self?.call = nil
        })
        
        guard let call = callManager.calls.first else { return }
        callManager?.setHeld(call: call, onHold: true)
        callManager.removeAllCalls()
    }
```
In `ChatVC+Stitch.swift` you modify `call(_ member: Member)` to handle calling with the `CallManager`: 

```Swift 
    func call(_ member: Member) {
        
        client.media.call([member.user.name],
                          onSuccess: { [weak self] result in
                            print("Call Result: ", result)
                            self?.call = result.call
                            DispatchQueue.main.async {
                                self?.callManager.startCall(handle: member.user.name, videoEnabled: false)
                            }
        }) { [weak self] error in
            self?.showAlert(with: "Unable to call member.", message: "Reason: \(error.localizedDescription)")
        }
    }
```
In `ChatVC+AudioPermission.swift` you update the request for audio permissions to set the mod for an `AVAudioSessionModeVoiceChat`: 

```Swift
func requestAudioPermission(completion: @escaping (_ success: Bool) -> Void) {
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setMode(AVAudioSessionModeVoiceChat)
            session.requestRecordPermission { success in
                completion(success)
            }
        } catch {
            print("Error requesting audio services: ", error.localizedDescription)
            completion(false)
        }
    }
``` 


## Try it out! 

You have had a chance to integrate Nexmo In-App Voice with Apple's iOS CallKit. You go ahead and initiate a call now! Join a conversation. Tap a member. Call him / her up right away. Stitch it up from the one Nexmo In-App Messaging channel to the Nexmo In-App Video channel. Engage in multichannel communications! 

## Where to go next?

If you want to take a deeper look at Nexmo's In-App conversation centric API, check out the iOS quick starts on the Nexmo Developer Portal. If you would like to gather background knowledge on either the Stitch Demo server or the Stitch Demo iOS App work, then revisit the links from the getting started guide where full length walkthroughs are available! 

### Is CallKit overkill?

If you thought that CallKit might have been overkill or unnecessary for what you would like to accomplish with calling, check out another workshop where the sole purpose is to initiate an IP-PSTN call with Nexmo In-App Voice without any additional coding [here](https://github.com/ericgiannini/StitchWorkshop). 

## Resources 

If you would like to learn more about Apple's iOS CallKit, Nexmo In-App Voice or 
- [CallKit Tutorial for iOS](https://www.raywenderlich.com/701-callkit-tutorial-for-ios) 
- [Apple's CallKit Documentation](https://developer.apple.com/documentation/callkit)
- [Apple's Voice Over IP (VoIP) Best Practices](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/OptimizeVoIP.html#//apple_ref/doc/uid/TP40015243-CH30-SW1)
- 


