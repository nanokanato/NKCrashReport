//
//  NKCrashReport.h
//  NKCrashReport
//
//  Created by nanoka____ on 2014/10/21.
//  Copyright (c) 2014年 nanoka____. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NKCrashReport : NSObject
+(NKCrashReport *)sharedInstance;
-(void)sendCrashExceptionFromEmail:(NSString *)fromEmail
                          fromHost:(NSString *)fromHost
                            fromID:(NSString *)fromID
                          fromPass:(NSString *)fromPass
                           toEmail:(NSString *)toEmail
                           ccEmail:(NSString *)ccEmail
                          bccEmail:(NSString *)bccEmail
                       sendHandler:(void (^)(NSError *error))handler;
@end