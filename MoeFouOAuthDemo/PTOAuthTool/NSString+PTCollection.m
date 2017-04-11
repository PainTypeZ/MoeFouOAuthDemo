//
//  NSString+PTCollection.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "NSString+PTCollection.h"

@implementation NSString (PTCollection)
// URL编码，iOS9.0之后有原生方法NSString *encodeString = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLXXXXAllowedCharacterSet]]，但是还不知道正确的使用方法，需要学习
+ (NSString *)urlEncodeString:(NSString *)string {
    NSString *encodeString = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);

    return encodeString;
}
// Base64 + HAMC-SHA1加密
+ (NSString *)base64_HMAC_SHA1:(NSString *)key string:(NSString *)string {
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [string cStringUsingEncoding:NSASCIIStringEncoding];
    // SHA1加密
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *data = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    // 对加密结果进行Base64编码
    NSString *hashString = [data base64EncodedStringWithOptions:0];
    return hashString;
}
// 升序排列get请求参数
+ (NSString *)ascendingOrderGETRequesetParamsDictionary:(NSDictionary *)params {
    // 得到升序排列的paramsArray
    NSArray *keyArray = [params allKeys];
    NSArray *sortedArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *sortString in sortedArray) {
        [valueArray addObject:params[sortString]];
    }
    NSMutableArray *paramsArray = [NSMutableArray array];
    for (int i = 0; i < sortedArray.count; i++) {
        NSString *keyValueStr = [NSString stringWithFormat:@"%@=%@", sortedArray[i], valueArray[i]];
        [paramsArray addObject:keyValueStr];
    }
    // 得到paramsString
    NSString *paramsString = [paramsArray componentsJoinedByString:@"&"];
    return paramsString;
}

@end
