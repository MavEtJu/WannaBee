//
//  ImageManager.m
//  WannaBee
//
//  Created by Edwin Groothuis on 29/6/17.
//  Copyright © 2017 Edwin Groothuis. All rights reserved.
//

#import "Wannabee-prefix.h"

@interface ImageManager ()

@property (nonatomic, retain) NSFileManager *fm;
@property (nonatomic, retain) NSString *rootdir;

@end

@implementation ImageManager

- (instancetype)init
{
    self = [super init];

    self.fm = [[NSFileManager alloc] init];
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    self.rootdir = [paths objectAtIndex:0];

    return self;
}

- (BOOL)isCached:(NSString *)urlhash
{
    NSString *fn = [NSString stringWithFormat:@"%@/%@", self.rootdir, urlhash];
    return [self.fm fileExistsAtPath:fn];
}

- (UIImage *)fromCache:(NSString *)urlhash
{
    NSString *fn = [NSString stringWithFormat:@"%@/%@", self.rootdir, urlhash];
    NSData *data = [NSData dataWithContentsOfFile:fn];
    return [UIImage imageWithData:data];
}

- (void)cache:(NSString *)urlhash data:(NSData *)data
{
    NSString *fn = [NSString stringWithFormat:@"%@/%@", self.rootdir, urlhash];
    [data writeToFile:fn atomically:YES];
}

- (NSString *)hash:(NSString *)url
{
    // Create pointer to the string as UTF8
    const char *ptr = [url UTF8String];

    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];

    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);

    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];

    return output;
}

- (UIImage *)url:(NSString *)urlstring
{
    if (urlstring == nil)
        return nil;
    NSString *urlhash = [self hash:urlstring];
    if ([self isCached:urlhash] == YES)
        return [self fromCache:urlhash];
    
    NSURL *url = [NSURL URLWithString:urlstring];

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
//    [req setValue:self.apikey forHTTPHeaderField:@"x-wallabee-api-key"];
//    if (self.token != nil)
//        [req setValue:self.token forHTTPHeaderField:@"x-user-token"];

    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];

    if (error != nil) {
        NSLog(@"%@", [error description]);
        return nil;
    }
    if (response.statusCode != 200) {
        NSLog(@"Return value: %d", response.statusCode);
        return nil;
    }

    [self cache:urlhash data:data];

    return [UIImage imageWithData:data];
}

@end
