//
//  TNDefaultsWrapper.m
//  Libing
//
//  Created by tarunon on 2014/06/28.
//  Copyright (c) 2014年 tarunon. All rights reserved.
//

#import "TNDefaultsWrapper.h"

@implementation NSString (defaultsWrapper)

- (NSString *)firstLetterUppercaseString_TNDefaultsWrapper
{
    return [[self substringToIndex:1].uppercaseString stringByAppendingString:[self substringFromIndex:1]];
}

- (NSString *)firstLetterLowercaseString_TNDefaultsWrapper
{
    return [[self substringToIndex:1].lowercaseString stringByAppendingString:[self substringFromIndex:1]];
}

@end

@implementation TNDefaultsWrapper

static NSDictionary *_propertiesDictionary;

static NSString *const defaultsWrapperPrefix = @"TNDefaultsWrapper";

static NSString *keyForSelector(SEL aSelector)
{
    NSString *selName = NSStringFromSelector(aSelector);
    NSString *propertyName = [selName hasSuffix:@":"] ? propertyNameFromSetter(aSelector) : selName;
    NSString *key = _propertiesDictionary[propertyName];
    return key ? key : [defaultsWrapperPrefix stringByAppendingString:propertyName.capitalizedString];
}

static NSString *propertyNameFromSetter(SEL aSelector)
{
    NSString *selName = NSStringFromSelector(aSelector);
    return [[selName substringWithRange:NSMakeRange(3, selName.length - 4)] firstLetterLowercaseString_TNDefaultsWrapper];
}

static SEL setterForString(NSString *propertyName)
{
    return NSSelectorFromString([NSString stringWithFormat:@"set%@:", [propertyName firstLetterUppercaseString_TNDefaultsWrapper]]);
}

static id getDefaultsObject(id _self, SEL aSelector)
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyForSelector(aSelector)];
}

static void setDefaultsObject(id _self, SEL aSelector, id value)
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:keyForSelector(aSelector)];
}

static BOOL getDefaultsBoolean(id _self, SEL aSelector)
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:keyForSelector(aSelector)];
}

static void setDefaultsBoolean(id _self, SEL aSelector, BOOL value)
{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:keyForSelector(aSelector)];
}

static NSInteger getDefaultsInteger(id _self, SEL aSelector)
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:keyForSelector(aSelector)];
}

static void setDefaultsInteger(id _self, SEL aSelector, NSInteger value)
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:keyForSelector(aSelector)];
}

static float getDefaultsFloat(id _self, SEL aSelector)
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:keyForSelector(aSelector)];
}

static void setDefaultsFloat(id _self, SEL aSelector, float value)
{
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:keyForSelector(aSelector)];
}

static double getDefaultsDouble(id _self, SEL aSelector)
{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:keyForSelector(aSelector)];
}

static void setDefaultsDouble(id _self, SEL aSelector, double value)
{
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:keyForSelector(aSelector)];
}

+ (instancetype)sharedWrapper
{
    static TNDefaultsWrapper *_sharedWrapper;
    @synchronized (self) {
        if (!_sharedWrapper) {
            _sharedWrapper = [[self alloc] init];
        }
    }
    return _sharedWrapper;
}

+ (void)initialize
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    for (unsigned int idx = 0; idx < count; idx++) {
        objc_property_t property = properties[idx];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        const char *type = [self instanceMethodSignatureForSelector:NSSelectorFromString(propertyName)].methodReturnType;
        IMP getIMP, setIMP;
        if (!strcmp(type, @encode(BOOL))) {
            getIMP = (IMP)getDefaultsBoolean;
            setIMP = (IMP)setDefaultsBoolean;
        } else if (!strcmp(type, @encode(NSInteger))) {
            getIMP = (IMP)getDefaultsInteger;
            setIMP = (IMP)setDefaultsInteger;
        } else if (!strcmp(type, @encode(float))) {
            getIMP = (IMP)getDefaultsFloat;
            setIMP = (IMP)setDefaultsFloat;
        } else if (!strcmp(type, @encode(double))) {
            getIMP = (IMP)getDefaultsDouble;
            setIMP = (IMP)setDefaultsDouble;
        } else {
            getIMP = (IMP)getDefaultsObject;
            setIMP = (IMP)setDefaultsObject;
        }
        SEL getSEL = NSSelectorFromString(propertyName);
        SEL setSEL = setterForString(propertyName);
        class_replaceMethod(self, setSEL, setIMP, method_getTypeEncoding(class_getClassMethod(self, setSEL)));
        class_replaceMethod(self, getSEL, getIMP, method_getTypeEncoding(class_getClassMethod(self, getSEL)));
    }
}

- (void)setPropertiesDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *properties = dictionary.mutableCopy;
    [properties addEntriesFromDictionary:_propertiesDictionary];
    _propertiesDictionary = properties.copy;
}

- (void)addConverterToObj:(id(^)(id fromDefaults))d2o toDefaults:(id(^)(id fromObj))o2d withPropertyName:(NSString *)propertyName
{
    IMP getIMP = imp_implementationWithBlock(^id (id _self){
        return d2o(getDefaultsObject(_self, NSSelectorFromString(propertyName)));
    });
    IMP setIMP = imp_implementationWithBlock(^(id _self, id value){
        setDefaultsObject(_self, setterForString(propertyName), o2d(value));
    });
    SEL getSEL = NSSelectorFromString(propertyName);
    SEL setSEL = setterForString(propertyName);
    class_replaceMethod(self.class, getSEL, getIMP, method_getTypeEncoding(class_getInstanceMethod(self.class, getSEL)));
    class_replaceMethod(self.class, setSEL, setIMP, method_getTypeEncoding(class_getInstanceMethod(self.class, setSEL)));
}

- (void)synchronize
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
