//
//  BluetoothManager.m
//  BluetoothApp
//
//  Created by Thando Tettey on 2019/04/02.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "React/RCTViewManager.h"

@interface RCT_EXTERN_MODULE(BluetoothManager, NSObject)
RCT_EXTERN_METHOD(startSession)
RCT_EXTERN_METHOD(endSession)
RCT_EXTERN_METHOD(startWaitingForConnection)
RCT_EXTERN_METHOD(stopWaitingForConnection)
RCT_EXTERN_METHOD(connectAccessory)
RCT_EXTERN_METHOD(checkAccessory)
RCT_EXTERN_METHOD(sendStringToAccessory)
@end
