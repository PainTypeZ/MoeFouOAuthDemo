//
//  NSString+PTCollection.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
@interface NSString (PTCollection)
// URL编码，9.0之前使用此方法，9.0之后有原生方法，但是不好用
+ (NSString *)urlEncodeString:(NSString *)string;
// Base64 + HAMC-SHA1加密
+ (NSString *)base64_HMAC_SHA1:(NSString *)key string:(NSString *)string;
// 升序排列get请求参数
+ (NSString *)ascendingOrderGETRequesetParamsDictionary:(NSDictionary *)params;

@end
