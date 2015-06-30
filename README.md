NKCrashReport
=============
http://nanoka.wpcloud.net  

機能
-----
クラッシュ時にクラッシュログを保存  
次回起動時にクラッシュログを指定メールアドレスに自動送信  
起動時に落ちるバグにはまだ対応できず…

○送信内容  
`プロジェクト名` `アプリバージョン` `端末OS` `端末プラットフォーム` `クラッシュ時刻` `クラッシュレポート送信時刻` `エラー名` `エラー詳細` `コールスタック`  
  
○送信に必要なもの  
`送信者メールアドレス` `送信者メールサーバーホスト` `ホストにログインするユーザーID` `ホストにログインするバスワード` `宛先メールアドレス` `CCメールアドレス(nilでも可)` `BCCメールアドレス(nilでも可)`  
  
使用方法
-----
AppDelegate.m
```
#import "AppDelegate.h"
#import  "NKCrashReport.h"

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //クラッシュレポートがあれば指定のメールアカウントから指定のアドレスにクラッシュレポートを送信する
    [[NKCrashReport sharedInstance] sendCrashExceptionFromEmail:送信者メールアカウント
                                                       fromHost:送信者メールサーバーホスト
                                                         fromID:ホストにログインするユーザーID
                                                       fromPass:ホストにログインするバスワード
                                                        toEmail:宛先メールアドレス
                                                        ccEmail:nil
                                                       bccEmail:nil
                                                    sendHandler:^(NSError *error){
                                                        if(error){
                                                            //送信失敗
                                                        }else{
                                                            //送信成功
                                                        }
                                                    }
    ];

    〜〜
```