#import "PpgPlugin.h"
#if __has_include(<ppg/ppg-Swift.h>)
#import <ppg/ppg-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ppg-Swift.h"
#endif

@implementation PpgPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPpgPlugin registerWithRegistrar:registrar];
}
@end
