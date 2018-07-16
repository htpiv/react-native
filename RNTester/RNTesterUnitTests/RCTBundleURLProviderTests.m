/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 */
#import <XCTest/XCTest.h>

#import <React/RCTBundleURLProvider.h>
#import <React/RCTUtils.h>

static NSString *const testFile = @"test.jsbundle";
static NSString *const mainBundle = @"main.jsbundle";

static NSURL *mainBundleURL()
{
  return [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:mainBundle];
}

static NSURL *localhostBundleURL()
{
  return [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:8081/%@.bundle?platform=%@&dev=true&minify=false", testFile, kRCTPlatformName]];
}

static NSURL *ipBundleURL()
{
  return [NSURL URLWithString:[NSString stringWithFormat:@"http://192.168.1.1:8081/%@.bundle?platform=%@&dev=true&minify=false", testFile, kRCTPlatformName]];
}

@implementation NSBundle (RCTBundleURLProviderTests)

- (NSURL *)RCT_URLForResource:(NSString *)name withExtension:(NSString *)ext
{
  // Ensure that test files is always reported as existing
  if ([[name stringByAppendingFormat:@".%@", ext] isEqualToString:mainBundle]) {
    return [[self bundleURL] URLByAppendingPathComponent:mainBundle];
  }
  return [self RCT_URLForResource:name withExtension:ext];
}

@end

@interface RCTBundleURLProviderTests : XCTestCase
@end

@implementation RCTBundleURLProviderTests

- (void)setUp
{
  [super setUp];

  RCTSwapInstanceMethods([NSBundle class],
                         @selector(URLForResource:withExtension:),
                          @selector(RCT_URLForResource:withExtension:));
}

- (void)tearDown
{
  RCTSwapInstanceMethods([NSBundle class],
                         @selector(URLForResource:withExtension:),
                         @selector(RCT_URLForResource:withExtension:));

  [super tearDown];
}

- (void)testBundleURL
{
  RCTBundleURLProvider *settings = [RCTBundleURLProvider sharedSettings];
  settings.jsLocation = nil;
  NSURL *URL = [settings jsBundleURLForBundleRoot:testFile fallbackResource:nil];
  if (!getenv("CI_USE_PACKAGER")) {
    XCTAssertEqualObjects(URL, mainBundleURL());
  } else {
    XCTAssertEqualObjects(URL, localhostBundleURL());
  }
}

- (void)testLocalhostURL
{
  RCTBundleURLProvider *settings = [RCTBundleURLProvider sharedSettings];
  settings.jsLocation = @"localhost";
  NSURL *URL = [settings jsBundleURLForBundleRoot:testFile fallbackResource:nil];
  XCTAssertEqualObjects(URL, localhostBundleURL());
}

- (void)testIPURL
{
  RCTBundleURLProvider *settings = [RCTBundleURLProvider sharedSettings];
  settings.jsLocation = @"192.168.1.1";
  NSURL *URL = [settings jsBundleURLForBundleRoot:testFile fallbackResource:nil];
  XCTAssertEqualObjects(URL, ipBundleURL());
}

@end
