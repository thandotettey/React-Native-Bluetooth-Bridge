//
//  ESAccessoryController.m
//  ESAccessory
//
//  Created by Hau (Hayward) V. LE on 3/25/19.
//  Copyright © 2019 ErnestSports. All rights reserved.
//

#import "ESAccessoryController.h"
#import "EADSessionController.h"

#define ARC4RANDOM_MAX 0x100000000
#define METER_TO_YARD(x) ( (x) * 1.0936133 )
#define YARD_TO_METER(x) ( (x) / 1.0936133 )
#define MILES_TO_KILOMETER(x) ( (x) * 1.609344)
#define KILOMETER_TO_MILES(x) ( (x) / 1.609344)

#define EA_PROTOCOL @"com.ernestsportsinc.es14"
#define EA_ACCESSORYNAME @"es14"

@interface ESAccessoryController()
    @property (nonatomic, copy) NSString *dataStr;
@end

@implementation ESAccessoryController

- (void)startSession
{
    NSLog(@"ESAccessoryController: startSession");
    
    EADSessionController *sessionController = [EADSessionController sharedController];
    self.connectedAccessory = [sessionController accessory];
    
    // Remove observers
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EADSessionDataReceivedNotification object:nil];
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDataReceived:) name:EADSessionDataReceivedNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    [sessionController openSession];
}

- (void)endSession
{
    NSLog(@"ESAccessoryController: endSession");
    
    if(self.connectedAccessory == nil)
    {
        NSLog(@"No session to end.");
        return;
    }
    
    // Remove observers
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EADSessionDataReceivedNotification object:nil];
    
    EADSessionController *sessionController = [EADSessionController sharedController];
    [sessionController closeSession];
    [sessionController setupControllerForAccessory:nil withProtocolString:nil];
    
    self.connectedAccessory = nil;
}

- (void)startWaitingForConnection
{
    if(self.connectedAccessory != nil)
        return;
    
    NSLog(@"ESAccessoryController: startWaitingforConnection");
    
    // Remove observers
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EADSessionDataReceivedNotification object:nil];
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessoryDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    
    NSMutableArray *accessoryList = [[NSMutableArray alloc] initWithArray:[[EAAccessoryManager sharedAccessoryManager] connectedAccessories]];
    
    for(EAAccessory *accessory in accessoryList)
    {
        if([self checkAccessory:accessory])
        {
            [self connectAccessory:accessory];
            
            if(self.delegate) {
                [self.delegate accessoryControllerDidConnect:self];
            }
            return;
        }
    }
}

- (void)stopWaitingForConnection
{
    if(self.connectedAccessory != nil)
        return;
    
    // Remove observers
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EADSessionDataReceivedNotification object:nil];
}

- (void)connectAccessory:(EAAccessory *)accessory
{
    if(self.connectedAccessory != nil)
        return;
    
    NSLog(@"ESAccessoryController: connectAccessory");
    
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
    //change
    //NSString *absoluteProtocolString = [NSString stringWithFormat:@"%@%@",EA_PROTOCOL,accessory.name];
    //[[EADSessionController sharedController] setupControllerForAccessory:accessory withProtocolString:absoluteProtocolString];
    [[EADSessionController sharedController] setupControllerForAccessory:accessory withProtocolString:EA_PROTOCOL];
}

- (BOOL)checkAccessory:(EAAccessory *)accessory
{
    NSLog(@"accessory name = %@", accessory.name);
    //change
    //if([accessory.name isEqualToString:EA_ACCESSORYNAME] ||[accessory.name isEqualToString:EA_ACCESSORYNAME_ES12])
    if([accessory.name isEqualToString:EA_ACCESSORYNAME])
    {
        NSArray *protocolStrings = [accessory protocolStrings];
        //change
        //NSString *absoluteProtocolString = [NSString stringWithFormat:@"%@%@",EA_PROTOCOL,accessory.name];
        
        for(NSString *protocolString in protocolStrings)
        {
            NSLog(@"protocol string = %@",protocolString);
            //change
            //if([protocolString isEqualToString:absoluteProtocolString])
            if([protocolString isEqualToString:EA_PROTOCOL])
                return YES;
        }
    }
    
    /*
     #ifdef __TESTING__
     
     NSLog(@"Testing");
     _selectedAccessory = [accessory retain];
     
     NSArray *protocolStrings = [accessory protocolStrings];
     
     _protocolSelectionActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"strSelectProtocol", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
     
     protocolStrings = [NSArray arrayWithObjects:@"Protocol1", @"Protocol2", @"Protocol3", nil];
     
     for(NSString *protocolString in protocolStrings) {
     [_protocolSelectionActionSheet addButtonWithTitle:protocolString];
     }
     
     [_protocolSelectionActionSheet setCancelButtonIndex:[_protocolSelectionActionSheet addButtonWithTitle:NSLocalizedString(@"strCancel", nil)]];
     [_protocolSelectionActionSheet showInView:tableView];
     
     return YES;
     #endif
     */
    
    return NO;
}

- (void)accessoryDidConnect:(NSNotification *)notification
{
    NSLog(@"ESAccessoryController: accessoryDidConnect");
    
    if(self.connectedAccessory == nil)
    {
        EAAccessory *a = [[notification userInfo] objectForKey:EAAccessoryKey];
        
        if([self checkAccessory:a])
        {
            [self connectAccessory:a];
            
            if(self.delegate) {
                [self.delegate accessoryControllerDidConnect:self];
            }
            return;
        }
    }
}

- (void)accessoryDidDisconnect:(NSNotification *)notification
{
    NSLog(@"ESAccessoryController: accessoryDidDisconnect");
    
    if(self.connectedAccessory != nil)
    {
        EAAccessory *a = [[notification userInfo] objectForKey:EAAccessoryKey];
        
        //NSString *msg = [NSString stringWithFormat:@"%@: name=%@, protocols=[%@]",NSLocalizedString(@"strDeviceDisconnected",nil), disconnectedAccessory.name, disconnectedAccessory.protocolStrings];
        //textView.text = [textView.text stringByAppendingString:msg];
        
        //NSLog(@"%@", msg);
        
        if ([a connectionID] == [self.connectedAccessory connectionID])
        {
            if(self.delegate) {
                [self.delegate accessoryControllerDidDisconnect:self];
            }
        }
    }
}

- (void)sessionDataReceived:(NSNotification *)notification
{
    NSLog(@"ESAccessoryController: sessionDataReceived");
    
    EADSessionController *sessionController = (EADSessionController *)[notification object];
    uint32_t bytesAvailable = 0;
    
    NSString *dataStrTmp = @"";
    
    while ((bytesAvailable = [sessionController readBytesAvailable]) > 0)
    {
        NSData *data = [sessionController readData:bytesAvailable];
        if (data)
        {
            NSString *str = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
            dataStrTmp = [dataStrTmp stringByAppendingString:str];
        }
    }
    
    [self onStringReceived:dataStrTmp];
}

- (void)sendStringToAccessory:(NSString *)str
{
    NSLog(@"Sending string to device: %@", str);
    
    const char *buf = [str UTF8String];
    if (buf)
    {
        uint32_t len = strlen(buf) + 1.0;
        [[EADSessionController sharedController] writeData:[NSData dataWithBytes:buf length:len]];
    }
}

-(NSDictionary *)parseData:(NSString *)str
{
    /*
     
     Communication Data Rate between RangePro and Smart Phone Apps will be as follows:
     
     Baud Rate:    9600
     Data Bits:    8
     Parity:    None
     Stop Bits:    1
     
     The data will be sent from the RangePro to the Smart Phone App in packets of 20 byte data
     At the end of each packet, the RangePro will look for an acknowledgement from the APP.
     Acknowledgement from app  =  [OK]
     If no acknowledgement is seen by the RangePro within 500ms, the RangePro will resubmit the packet one time.
     Example Packet:   StartM120Y178c7IrEnd
     
     New Example Packet:
     ES14StartCS105.0BS122.5CDY178.0TDY178.0LA15.2SP12505SF1.40CL7IrEnd<CR>
     
     */
    NSMutableDictionary *entry = nil;
    NSRange rangeStart = [str rangeOfString:@"ES14Start"];
    NSRange rangeEnd = [str rangeOfString:@"End"];
    
    if(rangeStart.length == 0 || rangeEnd.length == 0)
    {
        // Start or End not found in the string
        entry = nil;
    }
    else
    {
        
        str = [str substringWithRange:NSMakeRange(rangeStart.location, rangeEnd.location + rangeEnd.length - rangeStart.location)];
        
        if([str hasPrefix:@"ES14Start"] && [str hasSuffix:@"End"])
        {
            float clubSpeed;
            float ballSpeed;
            float totalDistance;
            float carryDistance;
            float launchAngle;
            int spin;
            float smashFactor;
            NSString *club = @"";
            int isDeviceUnitYard = YES;
            BOOL isDeviceSpeedUnitMPH = YES;
            BOOL isBadDataString = NO;
            NSString *strClubSpeed = [str substringWithRange:NSMakeRange(9, 7)];
            NSString *strBallSpeed = [str substringWithRange:NSMakeRange(16, 7)];
            NSString *strCarryDistance = [str substringWithRange:NSMakeRange(23,8)];
            NSString *strTotalDistance = [str substringWithRange:NSMakeRange(31,8)];
            NSString *strLaunchAngle = [str substringWithRange:NSMakeRange(39,6)];
            NSString *strSpin = [str substringWithRange:NSMakeRange(45,7)];
            NSString *strSmashFactor = [str substringWithRange:NSMakeRange(52,6)];
            NSString *strClubName = [str substringWithRange:NSMakeRange(58,5)];
            
            if([strClubSpeed hasPrefix:@"CS"])
            {
                // Speed in mph (miles per hour)
                clubSpeed = [[strClubSpeed substringFromIndex:2] floatValue];
                //isDeviceSpeedUnitMPH = YES;
                if (clubSpeed < 15.0 || clubSpeed > 160.0)
                {
                    isBadDataString = YES;
                }
            }
            if([strBallSpeed hasPrefix:@"BS"])
            {
                // Speed in mph (miles per hour)
                ballSpeed = [[strBallSpeed substringFromIndex:2] floatValue];
                //isDeviceSpeedUnitMPH = NO;
                if (ballSpeed < 15.0 || ballSpeed > 250.0)
                {
                    isBadDataString = YES;
                }
            }
            if([strTotalDistance hasPrefix:@"TDY"])
            {
                // Distance in Yards
                totalDistance = [[strTotalDistance substringFromIndex:3] floatValue];
                isDeviceUnitYard = YES;
                if (totalDistance < 11.0 || totalDistance > 499.0)
                {
                    isBadDataString = YES;
                }
            }
            else if([strTotalDistance hasPrefix:@"TDM"])
            {
                // Distance in meters
                totalDistance = [[strTotalDistance substringFromIndex:3] floatValue];
                isDeviceUnitYard = NO;
                if (totalDistance < 10.0 || totalDistance > 455.0)
                {
                    isBadDataString = YES;
                }
            }
            if([strCarryDistance hasPrefix:@"CDY"])
            {
                // Distance in Yards
                carryDistance = [[strCarryDistance substringFromIndex:3] floatValue];
                isDeviceUnitYard = YES;
                if (carryDistance < 11.0 || carryDistance > 499.0)
                {
                    isBadDataString = YES;
                }
            }
            else if([strCarryDistance hasPrefix:@"CDM"])
            {
                // Distance in meters
                carryDistance = [[strCarryDistance substringFromIndex:3] floatValue];
                isDeviceUnitYard = NO;
                if (carryDistance < 10.0 || carryDistance > 455.0)
                {
                    isBadDataString = YES;
                }
            }
            if ([strLaunchAngle hasPrefix:@"LA"])
            {
                launchAngle = [[strLaunchAngle substringFromIndex:2] floatValue];
                if (launchAngle < 0.0 || launchAngle > 55.0)
                {
                    isBadDataString = YES;
                }
            }
            if ([strSpin hasPrefix:@"SP"])
            {
                spin = [[strSpin substringFromIndex:2] intValue];
                if (spin < 0 || spin > 19000)
                {
                    isBadDataString = YES;
                }
            }
            if ([strSmashFactor hasPrefix:@"SF"])
            {
                smashFactor = [[strSmashFactor substringFromIndex:2] floatValue];
                if (smashFactor < 0.0 || smashFactor > 1.99)
                {
                    isBadDataString = YES;
                }
            }
            
            if([strClubName hasPrefix:@"CL"])
            {
                NSString *clubCode = [strClubName substringFromIndex:2];
                if([clubCode isEqualToString:@"Drv"]) club = @"Driver";
                //else if([clubCode isEqualToString:@"D"]) club = @"Driver Carry";
                else if([clubCode isEqualToString:@"3Wd"]) club = @"3 Wood";
                else if([clubCode isEqualToString:@"5Wd"]) club = @"5 Wood";
                else if([clubCode isEqualToString:@"7Wd"]) club = @"7 Wood";
                else if([clubCode isEqualToString:@"2Hy"]) club = @"2 Hybrid";
                else if([clubCode isEqualToString:@"3Hy"]) club = @"3 Hybrid";
                else if([clubCode isEqualToString:@"4Hy"]) club = @"4 Hybrid";
                else if([clubCode isEqualToString:@"5Hy"]) club = @"5 Hybrid";
                else if([clubCode isEqualToString:@"2Ir"]) club = @"2 Iron";
                else if([clubCode isEqualToString:@"3Ir"]) club = @"3 Iron";
                else if([clubCode isEqualToString:@"4Ir"]) club = @"4 Iron";
                else if([clubCode isEqualToString:@"5Ir"]) club = @"5 Iron";
                else if([clubCode isEqualToString:@"6Ir"]) club = @"6 Iron";
                else if([clubCode isEqualToString:@"7Ir"]) club = @"7 Iron";
                else if([clubCode isEqualToString:@"8Ir"]) club = @"8 Iron";
                else if([clubCode isEqualToString:@"9Ir"]) club = @"9 Iron";
                else if([clubCode isEqualToString:@"Gpw"]) club = @"Gap Wedge";
                else if([clubCode isEqualToString:@"Ptw"]) club = @"Pitching Wedge";
                else if([clubCode isEqualToString:@"Sdw"]) club = @"Sand Wedge";
                else if([clubCode isEqualToString:@"Lbw"]) club = @"Lob Wedge";
                else if([clubCode isEqualToString:@"HLw"]) club = @"High Loft Wedge";
            }
            if (!isBadDataString)
            {
                entry = [NSMutableDictionary dictionary];
                if(isDeviceSpeedUnitMPH == YES)
                {
                    entry[@"clubSpeed"] = @(clubSpeed);
                    entry[@"ballSpeed"] = @(ballSpeed);
                }
                else
                {
                    entry[@"clubSpeed"] = @(KILOMETER_TO_MILES(clubSpeed));
                    entry[@"ballSpeed"] = @(KILOMETER_TO_MILES(ballSpeed));
                }
                if(isDeviceUnitYard == YES)
                {
                    entry[@"totalDistance"] = @(totalDistance);
                    entry[@"carryDistance"] = @(carryDistance);
                }
                else
                {
                    entry[@"totalDistance"] = @(METER_TO_YARD(totalDistance));
                    entry[@"carryDistance"] = @(METER_TO_YARD(carryDistance));
                }
                
                if (self.delegate) {
                    [self.delegate accessoryControllerShowUnitMismatchMessage:self isDeviceUnitYard:isDeviceUnitYard];
                }
                
                entry[@"launchAngle"] = @(launchAngle);
                entry[@"spin"] = @(spin);
                entry[@"smashFactor"] = @(smashFactor);
                entry[@"club"] = club;
                entry[@"direction"] = @"Straight";
                self.dataStr = @"";
            }
            else
            {
                self.dataStr = @"";
            }
        }
    }
    return entry;
}

- (void)onStringReceived:(NSString *)str
{
    NSLog(@"ESAccessoryController: onStringReceived: %@", str);
    
    self.dataStr = [self.dataStr stringByAppendingString:str];
#ifdef __TESTING__
    self.dataStr = str;
#endif
    self.dataStr = [self.dataStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *msg = [NSString stringWithFormat:@"\nData: %@, (Full: %@)", str, self.dataStr];
    NSLog(@"%@", msg);
    
    NSDictionary *entry = [self parseData:self.dataStr];
    if(entry)
    {
        // Acknowledgement
        [self sendStringToAccessory:@"OK"];
        
        if(self.delegate)
        {
            [self.delegate accessoryController:self didReceiveEntry:entry];
        }
    }
    else
    {
    }
}

- (void)startTest:(NSString *)clubCode {
    float clubSpeed = 15.0 + (arc4random() % 145);
    float ballSpeed = 15.0 + (arc4random() % 145);
    float carryDistance = 11.0 + (arc4random() % 488);
    float totalDistance = 11.0 + (arc4random() % 488);
    float launchAngle = 0.0 + (arc4random() % 55);
    int spin = 0 + (arc4random() % 19000);
    float smashFactor = ((double)arc4random() / ARC4RANDOM_MAX)* 2;
    // Yard
    //NSString *testDataStr = [NSString stringWithFormat:@"StartM%03dY%03dc%@End\n\r", velocity, distance, clubCode];
    NSString *testDataStr = [NSString stringWithFormat:@"ES14StartCS%05.1fBS%05.1fCDY%05.1fTDY%05.1fLA%04.1fSP%05dSF%04.2fCL%@End\n\r",clubSpeed,ballSpeed,carryDistance,totalDistance,launchAngle,spin,smashFactor,clubCode];
    // Meter
    //NSString *testDataStr = [NSString stringWithFormat:@"StartM%03dm%03dc%@End\n\r", velocity, distance, clubCode];
    NSLog(@"testDataStr = %@",testDataStr);
    self.dataStr = @"";
    [self onStringReceived:testDataStr];
}

@end
