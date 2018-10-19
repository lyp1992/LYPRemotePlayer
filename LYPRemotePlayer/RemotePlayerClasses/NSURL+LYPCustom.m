//
//  NSURL+LYPCustom.m
//  LYPRemotePlayer
//
//  Created by laiyp on 2018/10/16.
//  Copyright © 2018 laiyongpeng. All rights reserved.
//

#import "NSURL+LYPCustom.h"

@implementation NSURL (LYPCustom)
-(NSURL *)lypURL{
//http://
    //    lyp://
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"lyp";
    return compents.URL;
}
-(NSURL *)lypHttpurl{
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"http";
    return compents.URL;
}
@end
