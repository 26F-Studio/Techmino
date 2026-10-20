// Included by src/common/ios.mm inside LOVE_IOS; no separate Xcode source phase is needed.
// SDL's documented subclass hook is +[SDLUIKitDelegate getAppDelegateClassName]:
// https://github.com/libsdl-org/SDL/blob/release-2.0.20/src/video/uikit/SDL_uikitappdelegate.m
// The pinned love-apple-dependencies 402eed62 SDK is SDL 2.0.19. Its URL selector
// depends on the SDK's deployment target, so both real SDL delegate variants are preserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

extern "C" void tn_mobile_callback(const uint8_t *url, size_t len);

// This is the upstream SDL class declaration, not an invented SDL C export.
@interface SDLUIKitDelegate : NSObject <UIApplicationDelegate>
+ (NSString *)getAppDelegateClassName;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
@end

static IMP tnOriginalOpenURL = nullptr;
static IMP tnOriginalLegacyOpenURL = nullptr;

static bool tnDispatchAuthorizationURL(NSURL *url)
{
    if (url == nil)
        return false;

    NSString *product = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Studio26TransportProduct"];
    NSString *callback = nil;
    if ([product isEqualToString:@"techmino"])
        callback = @"org.studio26f.techmino:/callback";
    else if ([product isEqualToString:@"techminoGalaxy"])
        callback = @"org.studio26f.techmino-galaxy:/callback";
    else
        abort();

    NSString *address = url.absoluteString;
    if (address.length > 8192 || [address rangeOfString:@"#"].location != NSNotFound
        || !([address isEqualToString:callback] || [address hasPrefix:[callback stringByAppendingString:@"?"]]))
        return false;

    NSData *encoded = [address dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    if (encoded == nil || encoded.length > 8192)
        return false;

    // Consume authorization callbacks here instead of exposing the query as SDL_DROPFILE.
    // Rust validates outstanding request state and issuer before accepting a code.
    tn_mobile_callback(static_cast<const uint8_t *>(encoded.bytes), encoded.length);
    return true;
}

static NSString *tnAppDelegateClassName(id object, SEL selector)
{
    return @"TNTransportAppDelegate";
}

@interface TNTransportAppDelegate : SDLUIKitDelegate
@end

@implementation TNTransportAppDelegate

+ (void)load
{
    @autoreleasepool
    {
        Class upstream = [SDLUIKitDelegate class];
        Method chooser = class_getClassMethod(upstream, @selector(getAppDelegateClassName));
        Method launch = class_getInstanceMethod(upstream, @selector(application:didFinishLaunchingWithOptions:));
        Method modern = class_getInstanceMethod(upstream, @selector(application:openURL:options:));
        Method legacy = class_getInstanceMethod(upstream, @selector(application:openURL:sourceApplication:annotation:));
        if (chooser == nullptr || method_getNumberOfArguments(chooser) != 2
            || launch == nullptr || method_getNumberOfArguments(launch) != 4
            || (modern == nullptr && legacy == nullptr)
            || (modern != nullptr && method_getNumberOfArguments(modern) != 5)
            || (legacy != nullptr && method_getNumberOfArguments(legacy) != 6))
        {
            // A changed SDK must fail loudly, not silently ship a callback-less application.
            NSLog(@"Transport requires the pinned SDL UIKit delegate interface");
            abort();
        }
        if (modern != nullptr)
            tnOriginalOpenURL = method_getImplementation(modern);
        if (legacy != nullptr)
            tnOriginalLegacyOpenURL = method_getImplementation(legacy);

        NSString *(*originalChooser)(id, SEL) = reinterpret_cast<NSString *(*)(id, SEL)>(method_getImplementation(chooser));
        if (![originalChooser(upstream, @selector(getAppDelegateClassName)) isEqualToString:@"SDLUIKitDelegate"])
        {
            NSLog(@"Transport cannot replace another application delegate");
            abort();
        }
        // Use SDL's real documented class chooser before its UIApplicationMain call.
        method_setImplementation(chooser, reinterpret_cast<IMP>(tnAppDelegateClassName));
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BOOL result = [super application:application didFinishLaunchingWithOptions:launchOptions];
    if (result)
    {
        id url = launchOptions[UIApplicationLaunchOptionsURLKey];
        if ([url isKindOfClass:[NSURL class]])
            tnDispatchAuthorizationURL(url);
    }
    return result;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    if (tnDispatchAuthorizationURL(url))
        return YES;

    if (tnOriginalOpenURL != nullptr)
    {
        auto original = reinterpret_cast<BOOL (*)(id, SEL, UIApplication *, NSURL *, NSDictionary *)>(tnOriginalOpenURL);
        return original(self, @selector(application:openURL:options:), application, url, options);
    }
    auto original = reinterpret_cast<BOOL (*)(id, SEL, UIApplication *, NSURL *, NSString *, id)>(tnOriginalLegacyOpenURL);
    return original(self, @selector(application:openURL:sourceApplication:annotation:), application, url,
        options[UIApplicationOpenURLOptionsSourceApplicationKey], options[UIApplicationOpenURLOptionsAnnotationKey]);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (tnDispatchAuthorizationURL(url))
        return YES;

    if (tnOriginalLegacyOpenURL != nullptr)
    {
        auto original = reinterpret_cast<BOOL (*)(id, SEL, UIApplication *, NSURL *, NSString *, id)>(tnOriginalLegacyOpenURL);
        return original(self, @selector(application:openURL:sourceApplication:annotation:), application, url, sourceApplication, annotation);
    }
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if (sourceApplication != nil)
        options[UIApplicationOpenURLOptionsSourceApplicationKey] = sourceApplication;
    if (annotation != nil)
        options[UIApplicationOpenURLOptionsAnnotationKey] = annotation;
    auto original = reinterpret_cast<BOOL (*)(id, SEL, UIApplication *, NSURL *, NSDictionary *)>(tnOriginalOpenURL);
    return original(self, @selector(application:openURL:options:), application, url, options);
}

@end
