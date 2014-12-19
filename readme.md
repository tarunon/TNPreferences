#TNPreferences

##使い方
NSUserDefaults, NSUbiquityKeyValueStoreのラッパークラス。
TNPreferencesのサブクラスに設定したpropertyが永続化される。
propertyの型はNSUserDefaultsに使用可能なNSObject、NSInteger、CGFloat、BOOLの何れか。

##サンプル
```objc

@interface SamplePreferences : TNPreferences

@property (nonatomic) NSInteger intValue;
@property (nonatomic) NSString *stringValue;
@property (nonatomic) NSArray *arrayValue;
@property (nonatomic) BOOL booleanValue;

@end

...

SamplePreferences *preferences = [SamplePreferences sharedPreferences];
preferences.intValue = 1;
preferences.stringValue = @"A";
preferences.arrayValue = @[@"B", @"C"];
preferences.booleanValue = YES;
[preferences synchronize];

