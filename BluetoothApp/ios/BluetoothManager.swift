//
//  BluetoothManager.swift
//  BluetoothApp
//
//  Created by Thando Tettey on 2019/04/02.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation

let accessoryController = ESAccessoryController()
//var accessory = EAAccessory()
var connected = false

@objc(BluetoothManager)
class Bluetooth: NSObject {
  
  override init() {
  }

  @objc
  func startSession() {
    accessoryController.startSession()
    print("In start session...")
  }
  
  @objc
  func endSession() {
    accessoryController.endSession()
    print("In end session...")
  }
  
  @objc
  func startWaitingForConnection() {
    accessoryController.startWaitingForConnection()
    print("In start waiting for connection...")
  }
  
  @objc
  func stopWaitingForConnection() {
    accessoryController.stopWaitingForConnection()
    print("In stop waiting for connection...")
  }
  
  @objc
  func connectAccessory() {
    print("NOT REQUIRED")
  }
  
  @objc
  func sendStringToAccessory() {
    print("In send string to accessory")
  }
  
  @objc
  func checkAccessory() {
    if(accessoryController.connectedAccessory != nil)
    {
      connected = true;
    } else {
      connected = false;
    }
    print("In check accessory")
    print(connected)
    //print(accessory)
  }
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
