//
//  NKCrashReport.h
//  NKCrashReport
//
//  Created by nanoka____ on 2014/10/21.
//  Copyright (c) 2014年 nanoka____. All rights reserved.
//
//  シングル㌧でインスタンスを取得、sendCrashExceptionFromEmailメソッドを呼んだタイミングでクラッシュログの送信を開始します。
//  シングルトンでインスタンスの生成が行われた時にクラッシュレポートの保存準備ができるのでクラッシュレポートの送信自体はどこで呼び出しても大丈夫ですが、インスタンスの生成は起動時に行ってください。
//  クラッシュログ送信時、メールサーバーへのログインなどがあるので少し時間がかかるのでバックグラウンド処理で行います。
//  送信結果はハンドラでNSErrorとして帰ってきます。nilの場合は送信成功、もしくはクラッシュレポートが無く送信の必要が無い状態です。
//  「crash-reports」というKeyでクラッシュログをキャッシュして保持しているのでNKCrashReportクラス内以外では使用しないでください。
//
//  不明点、改良点があればhttp://nanoka.wpcloud.net/?p=551までコメントいただけると助かります。
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NKCrashReport : NSObject
//インスタンスの生成
+(NKCrashReport *)sharedInstance;

//メールの送信
-(void)sendCrashExceptionFromEmail:(NSString *)fromEmail
                          fromHost:(NSString *)fromHost
                            fromID:(NSString *)fromID
                          fromPass:(NSString *)fromPass
                           toEmail:(NSString *)toEmail
                           ccEmail:(NSString *)ccEmail
                          bccEmail:(NSString *)bccEmail
                       sendHandler:(void (^)(NSError *error))handler;
@end