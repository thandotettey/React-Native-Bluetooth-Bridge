//
//  ESAccessoryController.h
//  ESAccessory
//
//  Created by Hau (Hayward) V. LE on 3/25/19.
//  Copyright © 2019 ErnestSports. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

@class ESAccessoryController;

@protocol ESAccessoryControllerDelegate <NSObject>

- (void)accessoryControllerDidConnect:(ESAccessoryController *)controller;
- (void)accessoryControllerDidDisconnect:(ESAccessoryController *)controller;
- (void)accessoryControllerShowUnitMismatchMessage:(ESAccessoryController *)controller isDeviceUnitYard:(BOOL)isDeviceUnitYard;
- (void)accessoryController:(ESAccessoryController *)controller didReceiveEntry:(NSDictionary *)entry;
@end

@interface ESAccessoryController : NSObject

@property (nonatomic, strong) EAAccessory *connectedAccessory;
@property (nonatomic, assign) id<ESAccessoryControllerDelegate> delegate;

- (void)startSession;
- (void)endSession;
- (void)startWaitingForConnection;
- (void)stopWaitingForConnection;
- (void)startTest:(NSString *)clubCode;
@end
