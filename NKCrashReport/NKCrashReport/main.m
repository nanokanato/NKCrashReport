//
//  main.m
//  NKCrashReport
//
//  Created by nanoka____ on 2015/06/29.
//  Copyright (c) 2015年 nanoka____. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NKCrashReport.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        @try{
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch(NSException *exception) {
            
        }
    }
}
