//
//  AppDelegate.m
//  NKCrashReport
//
//  Created by nanoka____ on 2014/10/21.
//  Copyright (c) 2014年 nanoka____. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import  "NKCrashReport.h"

/*========================================================
 ; AppDelegate
 ========================================================*/
@implementation AppDelegate

/*--------------------------------------------------------
 ; dealloc : 解放
 ;      in :
 ;     out :
 --------------------------------------------------------*/
-(void)dealloc
{
    self.window = nil;
}

/*--------------------------------------------------------
 ; didFinishLaunchingWithOptions : アプリ起動時に呼び出される
 ;                            in : UIApplication * application
 ;                               : NSDictionary *launchOptions
 ;                           out : BOOL YES
 --------------------------------------------------------*/
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //クラッシュレポートがあれば指定のメールアカウントから指定のアドレスにクラッシュレポートを送信する
    [[NKCrashReport sharedInstance] sendCrashExceptionFromEmail:@"hoge@gmail.com"
                                                       fromHost:@"smtp.gmail.com"
                                                         fromID:@"hoge@gmail.com"
                                                       fromPass:@"hoge"
                                                        toEmail:@"huga@gmail.com"
                                                        ccEmail:@"huga2@gmail.com"
                                                       bccEmail:@"huga3@gmail.com"
                                                    sendHandler:^(NSError *error){
                                                        if(error){
                                                            //送信失敗
                                                        }else{
                                                            //送信成功
                                                        }
                                                    }
     ];
    
    //Windowの生成
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *oViewController = [[ViewController alloc] init];
    self.window.rootViewController = oViewController;
    oViewController = nil;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
