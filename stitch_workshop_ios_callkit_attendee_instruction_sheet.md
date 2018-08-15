#Welcome to the Stitch Workshop on How to Make a Nexmo's In-App Voice Call with Apple's iOS CallKit 

In this workshop learn how your Nexmo In-App Voice integrations use Apple's CallKit for system-level phone functionalities such as dial pad, call or hangup. 

Note: CallKit features won’t work in the simulator. In order to follow along with this tutorial, you’ll need an iPhone with iOS 11 installed.

## What is Nexmo In-App Voice

Nexmo In-App Voice is a conversation centric API. 

## What is Apple's CallKit

CallKit is a relatively new framework that facilitates integrations like Nexmo's In-App Voice for rich VoIP experiences with the iPhone/iPad's native UI. Integrations with Apple's CallKit use Apple's own incoming call screen in both locked / unlocked states, allowing end users to initiate Nexmo In-App Voice calls from an iPhone app’s Contacts, Favorites or Recents screens.

## Getting Started 

### Make an Outgoing Call 

A user can initiate an outgoing call with a VoIP app in any of the following ways:
- Performing an interaction within the app
- Opening a link with a supported custom URL scheme
- Initiating a VoIP call using Siri

To make an outgoing call, an app requests a `CXStartCallAction` object from its `CXCallController` object. The action consists of a UUID to uniquely identify the call and a `CXHandle` object to specify the recipient.

```Swift 
let uuid = UUID()
let handle = CXHandle(type: .emailAddress, value: "jappleseed@apple.com")
 
let startCallAction = CXStartCallAction(call: uuid)
startCallAction.destination = handle
 
let transaction = CXTransaction(action: startCallAction)
callController.request(transaction) { error in
    if let error = error {
        print("Error requesting transaction: \(error)")
    } else {
        print("Requested transaction successfully")
    }
}
```


## Resources 
- [CallKit Tutorial for iOS](https://www.raywenderlich.com/701-callkit-tutorial-for-ios) 
- [Apple's CallKit Documentation](https://developer.apple.com/documentation/callkit)
- [Apple's Voice Over IP (VoIP) Best Practices](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/OptimizeVoIP.html#//apple_ref/doc/uid/TP40015243-CH30-SW1)


Download the starter project [here](https://github.com/Nexmo/stitch-demo-ios/tree/master/folder/conversationdemo) To get up and running 

Answering 

Declining 

Holding 