//
//  ViewController.m
//  NKCrashReport
//
//  Created by nanoka____ on 2014/10/21.
//  Copyright (c) 2014年 nanoka____. All rights reserved.
//

#import "ViewController.h"
#import  "NKCrashReport.h"

#import <CoreData/CoreData.h>

/*========================================================
 ; ViewController
 ========================================================*/
@implementation ViewController

/*--------------------------------------------------------
 ; dealloc : 解放
 ;      in :
 ;     out :
 --------------------------------------------------------*/
-(void)dealloc
{
    
}

/*--------------------------------------------------------
 ; viewDidAppear : Viewが読み込まれた時
 ;            in : (BOOL)animated
 ;           out :
 --------------------------------------------------------*/
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"NKCrashReport"
                                                                   message:@"クラッシュさせよう！"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"NSArrayにない参照先を参照する"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action){
                                                //NSArrayの用意されていない参照先を参照してクラッシュさせる
                                                NSArray *array = [NSArray array];
                                                [array objectAtIndex:0];
                                            }
                      ]
     ];
    [alert addAction:[UIAlertAction actionWithTitle:@"NSManagedObjectをcopyする"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action){
                                                //NSArrayの用意されていない参照先を参照してクラッシュさせる
                                                [[[NSManagedObject alloc] initWithEntity:nil insertIntoManagedObjectContext:nil] copy];
                                            }
                      ]
     ];
    [self presentViewController:alert animated:YES completion:^(){}];
}

/*--------------------------------------------------------
 ; viewDidLoad : 初回Viewが読み込まれた時
 ;          in :
 ;         out :
 --------------------------------------------------------*/
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

@end