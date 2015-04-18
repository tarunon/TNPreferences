#TNPreferences

TNPreferences is wrapper class for NSUserDefaults and NSUbiquityKeyValueStore

##How to
- Make subclass for TNPreferences.
- Define property. Supports NSInteger, CGFloat, BOOL and NSObject implemented NSCoding.

##Pod
pod 'TNPreferences', :git => 'https://github.com/tarunon/TNPreferences.git'


##Sample
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

