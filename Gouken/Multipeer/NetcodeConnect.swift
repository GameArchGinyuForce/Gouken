//
//  MultiplayerConnect.swift
//  Gouken
//
//  Created by Sepehr Mansouri on 2024-03-27.
//

import Foundation
import MultipeerConnectivity
import os


enum Move: String, CaseIterable, Codable {
    case left, right, jump, crouch, lowDash, midDash, block
}

struct MoveData: Codable {
    let move: Move
    let timestamp: TimeInterval
}

class NetcodeConnect: NSObject, ObservableObject {
    private let serviceType = "GoukenMP"
    private let session: MCSession
    
    // TODO: Get the GameCenter Username from the apple device
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private let log = Logger()
    private var numberOfMovesSent = 0;
    private var cumulativeTime: TimeInterval = 0.0

    @Published var currentMove: Move? = nil
    @Published var latency: TimeInterval = 0.0
    @Published var maxLatency: TimeInterval = 0.0
    @Published var avgLatency: TimeInterval = 0.0
    @Published var connectedPeers: [MCPeerID] = []

    override init() {
        precondition(Thread.isMainThread)
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)

        super.init()

        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self

        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }

    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }

    func send(move: Move) {
        precondition(Thread.isMainThread)
        log.info("sendMove: \(String(describing: move)) to \(self.session.connectedPeers.count) peers")

        if !session.connectedPeers.isEmpty {
            let timestamp = Date().timeIntervalSince1970
            let moveData = MoveData(move: move, timestamp: timestamp)
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(moveData)
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                log.error("Error for sending move: \(error)")
            }
        }
    }
}

extension NetcodeConnect: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        precondition(Thread.isMainThread)
        log.error("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        precondition(Thread.isMainThread)
        log.info("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, session)
    }
}

extension NetcodeConnect: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        log.error("ServiceBrowser didNotStartBrowsingForPeers: \(String(describing: error))")
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        log.info("ServiceBrowser found peer: \(peerID)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log.info("ServiceBrowser lost peer: \(peerID)")
    }
}

extension NetcodeConnect: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        log.info("peer \(peerID) didChangeState: \(state.debugDescription)")
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
            do {
                let decoder = JSONDecoder()
                let receivedData = try decoder.decode(MoveData.self, from: data)

                log.info("didReceive move \(receivedData.move.rawValue)")

                let currentTimestamp = Date().timeIntervalSince1970
                let roundTripLatency = (currentTimestamp - receivedData.timestamp)
                DispatchQueue.main.async {
                    self.numberOfMovesSent += 1
                    self.cumulativeTime+=roundTripLatency
                    self.currentMove = receivedData.move
                    self.latency = roundTripLatency
                    self.maxLatency = (roundTripLatency > self.maxLatency) ? roundTripLatency : self.maxLatency
                    self.avgLatency = Double(self.cumulativeTime) / Double(self.numberOfMovesSent)

                }
            } catch {
                log.error("Error decoding move data: \(error)")
            }
        }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        log.error("Receiving streams is not supported")
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        log.error("Receiving resources is not supported")
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        log.error("Receiving resources is not supported")
    }
}

extension MCSessionState: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .notConnected:
            return "notConnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        @unknown default:
            return "\(rawValue)"
        }
    }
}
