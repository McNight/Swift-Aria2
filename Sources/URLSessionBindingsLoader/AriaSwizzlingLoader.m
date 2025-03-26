#import <Foundation/Foundation.h>

__attribute__((constructor))
static void swizzleLoader(void) {
    [NSURLSession performSelector:NSSelectorFromString(@"performSwizzling")];
    [NSURLSessionTask performSelector:NSSelectorFromString(@"performSwizzling")];
}
