#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.jadenzaleski.SwiftLift";

/// The "customGreen" asset catalog color resource.
static NSString * const ACColorNameCustomGreen AC_SWIFT_PRIVATE = @"customGreen";

/// The "customPurple" asset catalog color resource.
static NSString * const ACColorNameCustomPurple AC_SWIFT_PRIVATE = @"customPurple";

/// The "ld" asset catalog color resource.
static NSString * const ACColorNameLd AC_SWIFT_PRIVATE = @"ld";

/// The "mainSystemColor" asset catalog color resource.
static NSString * const ACColorNameMainSystemColor AC_SWIFT_PRIVATE = @"mainSystemColor";

/// The "offset" asset catalog color resource.
static NSString * const ACColorNameOffset AC_SWIFT_PRIVATE = @"offset";

/// The "LaunchScreen" asset catalog image resource.
static NSString * const ACImageNameLaunchScreen AC_SWIFT_PRIVATE = @"LaunchScreen";

#undef AC_SWIFT_PRIVATE
