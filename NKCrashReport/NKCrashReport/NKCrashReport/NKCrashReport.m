//
//  NKCrashReport.m
//  NKCrashReport
//
//  Created by nanoka____ on 2014/10/21.
//  Copyright (c) 2014年 nanoka____. All rights reserved.
//

#import  "NKCrashReport.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"
#include <sys/types.h>
#include <sys/sysctl.h>

typedef void (^HandlerError)(NSError *error);

@interface NKCrashReport () <SKPSMTPMessageDelegate>
@end

/*========================================================
 ; NKCrashReport
 ========================================================*/
@implementation NKCrashReport{
    HandlerError sendHandler;
}

#pragma mark Initialize Methods
/*--------------------------------------------------------
 ; sharedInstance : シングル㌧インスタンスの生成
 ;             in :
 ;            out : (NKCrashReport *)gInstance
 --------------------------------------------------------*/
+(NKCrashReport *)sharedInstance
{
    static NKCrashReport *gInstance;
    @synchronized(self){
        if (gInstance == NULL){
            gInstance = [[self alloc] init];
        }
    }
    return(gInstance);
}

/*--------------------------------------------------------
 ; init : シングル㌧インスタンスの生成
 ;   in :
 ;  out : (instancetype)self
 --------------------------------------------------------*/
-(instancetype)init
{
    self = [super init];
    if(self){
        //エラーログ取得用ハンドルを登録
        NSSetUncaughtExceptionHandler(uncaughtExceptionHandler);
    }
    return self;
}

/*--------------------------------------------------------
 ; uncaughtExceptionHandler : エラーログ取得用のハンドル
 ;                       in :
 ;                      out : (NSException *)exception
 --------------------------------------------------------*/
void uncaughtExceptionHandler(NSException *exception)
{
    //クラッシュ情報配列を用意
    NSData *crashData = [[NSUserDefaults standardUserDefaults] objectForKey:@"crash-reports"];
    NSMutableArray *crashArray = [NSKeyedUnarchiver unarchiveObjectWithData:crashData];
    if(!crashArray){
        crashArray = [[NSMutableArray alloc] init];
        NSData *crashData = [NSKeyedArchiver archivedDataWithRootObject:crashArray];
        [[NSUserDefaults standardUserDefaults] setObject:crashData forKey:@"crash-reports"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // ここで、例外発生時の情報を保存します。
    NSMutableDictionary *crashDict = [[NSMutableDictionary alloc] init];
    //保存
    [crashDict setObject:exception.name forKey:@"name"];
    [crashDict setObject:exception.reason forKey:@"reason"];
    [crashDict setObject:[NSString stringWithFormat:@"%@",exception.callStackSymbols] forKey:@"callStackSymbols"];
    [crashDict setObject:[NSDate date] forKey:@"date"];
    [crashArray addObject:crashDict];
    //クラッシュ情報配列を保存
    {
        NSData *crashData = [NSKeyedArchiver archivedDataWithRootObject:crashArray];
        [[NSUserDefaults standardUserDefaults] setObject:crashData forKey:@"crash-reports"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

/*--------------------------------------------------------
 ; sendCrashExceptionFromEmail : クラッシュレポートを送信する
 ;                          in : (NSString *)fromEmail
 ;                             : (NSString *)fromHost
 ;                             : (NSString *)fromID
 ;                             : (NSString *)fromPass
 ;                             : (NSString *)toEmail
 ;                             : (NSString *)ccEmail
 ;                             : (NSString *)bccEmail
 ;                             : (void (^)(NSError *error))handler
 ;                         out :
 --------------------------------------------------------*/
-(void)sendCrashExceptionFromEmail:(NSString *)fromEmail fromHost:(NSString *)fromHost fromID:(NSString *)fromID fromPass:(NSString *)fromPass toEmail:(NSString *)toEmail ccEmail:(NSString *)ccEmail bccEmail:(NSString *)bccEmail sendHandler:(void (^)(NSError *error))handler
{
    //送信中でなく、ハンドラが渡されている時
    if(handler && !sendHandler){
        sendHandler = handler;
        //クラッシュ情報配列を用意
        NSData *crashData = [[NSUserDefaults standardUserDefaults] objectForKey:@"crash-reports"];
        NSMutableArray *crashArray = [NSKeyedUnarchiver unarchiveObjectWithData:crashData];
        if(!crashArray){
            crashArray = [[NSMutableArray alloc] init];
            NSData *crashData = [NSKeyedArchiver archivedDataWithRootObject:crashArray];
            [[NSUserDefaults standardUserDefaults] setObject:crashData forKey:@"crash-reports"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        //クラッシュレポートがあるかどうか
        if(0 < [crashArray count]){
            //送信者情報があるかどうか
            if(fromEmail && ![fromEmail isEqual:@""] && fromHost && ![fromHost isEqual:@""] && fromID && ![fromID isEqual:@""] && fromPass && ![fromPass isEqual:@""]){
                SKPSMTPMessage *emailMessage = [[SKPSMTPMessage alloc] init];
                //送信者メールアドレス
                emailMessage.fromEmail = fromEmail;
                emailMessage.requiresAuth = YES;
                //メールサーバーのホスト
                emailMessage.relayHost = fromHost;
                //メールサーバーのユーザー名
                emailMessage.login = fromID;
                //メールサーバーのパスワード
                emailMessage.pass = fromPass;
                //宛先メールアドレス
                emailMessage.toEmail = toEmail;
                //ccメールアドレス
                if(ccEmail && ![ccEmail isEqual:@""]){
                    emailMessage.ccEmail = ccEmail;
                }
                //bccメールアドレス
                if(bccEmail && ![bccEmail isEqual:@""]){
                    emailMessage.bccEmail = bccEmail;
                }
                //メールタイトル「[CrashReport] (アプリ名)」
                emailMessage.subject = [NSString stringWithFormat:@"[CrashReport] %@",[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleName"]]; //アプリ名
                //2段階認証プロセスを利用する場合、アプリパスワードを使用する
                emailMessage.wantsSecure = YES;
                emailMessage.delegate = self;
                //メール本文
                NSString *messageBody = @"";
                for(NSDictionary *crashDict in crashArray){
                    messageBody = [NSString stringWithFormat:@"%@%@\n\n",messageBody ,[self makeMessageBody:crashDict]];
                }
                NSDictionary *plainMsg = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                                                                                    messageBody  ,kSKPSMTPPartMessageKey,nil];
                emailMessage.parts = [NSArray arrayWithObjects:plainMsg,nil];
                [emailMessage send];
            }else{
                sendHandler([NSError errorWithDomain:nil code:0 userInfo:@{@"error":@"送信者メールアドレスの情報に不備があります"}]);
                sendHandler = nil;
            }
        }else{
            sendHandler(nil);
            sendHandler = nil;
        }
    }
}

/*--------------------------------------------------------
 ; makeMessageBody : クラッシュレポートの本文を作成する
 ;              in :
 ;             out :
 --------------------------------------------------------*/
-(NSString *)makeMessageBody:(NSDictionary *)crashDict
{
    NSString *messageBody = @"■プロジェクト情報";
    //アプリ名
    messageBody = [NSString stringWithFormat:@"%@\nプロジェクト名：%@",messageBody,[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleName"]];
    //アプリバージョン
    messageBody = [NSString stringWithFormat:@"%@\nアプリバージョン：%@",messageBody,[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"]];
    //端末情報タイトル
    messageBody = [NSString stringWithFormat:@"%@\n■端末情報",messageBody];
    //端末OS
    messageBody = [NSString stringWithFormat:@"%@\nOS：%@",messageBody,[UIDevice currentDevice].systemVersion];
    //端末名
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    messageBody = [NSString stringWithFormat:@"%@\nプラットフォーム：%@",messageBody,platform];
    //エラー情報タイトル
    messageBody = [NSString stringWithFormat:@"%@\n■エラー情報",messageBody];
    //発生日時
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter.calendar = calendar;
    calendar = nil;
    [dateFormatter setLocale:[NSLocale systemLocale]];
    dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    messageBody = [NSString stringWithFormat:@"%@\nクラッシュ時刻：%@",messageBody,[dateFormatter stringFromDate:[crashDict objectForKey:@"date"]]];
    //送信日時
    messageBody = [NSString stringWithFormat:@"%@\n送信時刻：%@",messageBody,[dateFormatter stringFromDate:[NSDate date]]];
    //エラー名
    messageBody = [NSString stringWithFormat:@"%@\nエラー名：%@",messageBody,[crashDict objectForKey:@"name"]];
    //エラー原因
    messageBody = [NSString stringWithFormat:@"%@\nエラー詳細：%@",messageBody,[crashDict objectForKey:@"reason"]];
    //コールスタック
    messageBody = [NSString stringWithFormat:@"%@\nコールスタック：\n%@",messageBody,[crashDict objectForKey:@"callStackSymbols"]];
    return messageBody;
}

/*========================================================
 ; SKPSMTPMessageDelegate
 ========================================================*/
/*--------------------------------------------------------
 ; messageSent : 送信成功
 ;          in : (SKPSMTPMessage *)message
 ;         out :
 --------------------------------------------------------*/
-(void)messageSent:(SKPSMTPMessage *)message
{
    //送信した内容は初期化する
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"crash-reports"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    sendHandler(nil);
    sendHandler = nil;
}

/*--------------------------------------------------------
 ; messageFailed : 送信失敗
 ;            in : (SKPSMTPMessage *)message
 ;               : (NSError *)error
 ;           out :
 --------------------------------------------------------*/
-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    sendHandler(error);
    sendHandler = nil;
}

@end