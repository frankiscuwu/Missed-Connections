
# Track
Reimagine Reality: 
Our greatest strength as humans lies in our ability to innovate. As we set our sights on exploring the stars, we must refine existing products and technologies to meet new demands and operational challenges. Today, the world is filled with countless established products and applications. But have you ever wished an app had a feature it lacked? Or thought you could design it better if you were the creator? Now's your chance to unleash the inner creator in you and turn those ideas into reality!

In this track, you can take existing products and applications and transform them into something entirely different. Add new features, reimagine interfaces, or discover novel uses – this track is all about pushing the boundaries and reimagining current reality:

– If you were the creator, what changes would you make or like to see?
– What features have you always wished an existing product or app had?
– Are there any underutilized features that could be improved or repurposed?
– What common problems do users face with the current product, and how can you solve them?
– What new industries or fields could benefit from this product with some modifications?
– How can you make the user experience smoother or more intuitive?
– What new industries or fields could benefit from this product with some modifications?


# Our idea
A modern Social Streetpass

## Streetpass – Nintendo (c)
Experience a new level of social gaming with StreetPass, only on Nintendo 3DS family systems!

If you carry your Nintendo 3DS with you wherever you go, it’ll automatically search for and exchange data with other powered on Nintendo 3DS systems, whether you’re actively using the system or even if it’s tucked away in Sleep Mode. You control what data you exchange (if any) and this data can then be used to play unique new games or access extra content in StreetPass-enabled titles.

Cross paths with another player and you’ll receive their Mii character and gameplay profiles. You can also see what games those around you are playing, share messages with people that you pass regularly, and unlock new gameplay elements in titles that you’ve enabled StreetPass for. When the notification light shows green, you’ve received StreetPass data!

The Nintendo 3DS system’s range of built-in Instant Software allows you to play games that are only possible on Nintendo 3DS in StreetPass Mii Plaza. You can also send information about your favourite music with Nintendo 3DS Sound – can you find a passer-by that shares your taste in tunes?

Certain titles are enhanced with StreetPass functionality, bringing new possibilities to a range of games. Show off your pets in nintendogs + cats, proudly exchange a copy of your home in Animal Crossing: New Leaf or send your army off to battle in Fire Emblem: Awakening – and that’s just the beginning. Find out more about StreetPass-enabled titles in the Games with StreetPass section.


# Implementation

## 1) Nearby Interaction Framework (Ultra-Wideband, UWB)
If both devices support UWB (like recent iPhones with the U1 chip), Apple’s Nearby Interaction framework enables highly accurate proximity sensing.

Key Features: Detects nearby devices with precise distance and direction.
Use Case: Ideal for applications requiring spatial awareness (e.g., sharing content between nearby devices).
Limitations: Only available on devices with the U1 chip (iPhone 11 and later).
How to Use:

Both devices need to run the app and agree to share their location and interaction data.
Establish a UWB session to passively track nearby devices.
Documentation: https://developer.apple.com/documentation/nearbyinteraction

## 2) Core Bluetooth (BLE Beacon Detection)
Using Bluetooth Low Energy (BLE), you can broadcast and detect beacon signals in the background. BLE is a low-power communication protocol similar to what StreetPass uses.

How It Works: One device advertises itself using BLE, and nearby devices scan for that beacon.
Limitations: Due to iOS’s background restrictions, background scanning and advertising are limited in terms of frequency and duration.
Steps:
Device A advertises a BLE service.
Device B scans and detects Device A’s beacon in the background.

        import CoreBluetooth

        class BLEAdvertiser: NSObject, CBPeripheralManagerDelegate {
            var peripheralManager: CBPeripheralManager!

            func startAdvertising() {
                peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                let advertisementData = [CBAdvertisementDataLocalNameKey: "MyDevice"]
                peripheralManager.startAdvertising(advertisementData)
            }

            func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
                if peripheral.state == .poweredOn {
                    startAdvertising()
                }
            }
        }

## 3) Multipeer Connectivity Framework (Wi-Fi Direct & Bluetooth)
The Multipeer Connectivity framework allows devices to discover each other and exchange data using peer-to-peer Wi-Fi and Bluetooth.

Key Features: Works without an internet connection, supports file and message exchange between nearby devices.
How It Works: Devices in close range automatically connect to form a peer-to-peer network.
Steps:
Devices advertise themselves as available peers.
When a peer is found, the devices exchange small payloads like in StreetPass.
Code Example (Swift):

        import MultipeerConnectivity

        class PeerSession: NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
            var session: MCSession!
            var advertiser: MCNearbyServiceAdvertiser!

            override init() {
                super.init()
                let peerID = MCPeerID(displayName: UIDevice.current.name)
                session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
                advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "my-app")
                advertiser.delegate = self
                advertiser.startAdvertisingPeer()
            }

            func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
                invitationHandler(true, session)
            }

            // Implement additional delegate methods for handling session events.
        }
Limitations: Requires both devices to have the app running to initiate communication. However, it can run in the background briefly to scan for peers.
Documentation: https://developer.apple.com/documentation/multipeerconnectivity

## Background Tasks & Push Notifications
If continuous background scanning is limited (due to iOS background restrictions), you can use push notifications or BackgroundTasks API to wake the app at intervals to perform scans.

**BackgroundTasks API**: You can schedule scans to run periodically in the background.
**Silent Push Notifications**: Trigger the app to scan when another device sends a signal.
