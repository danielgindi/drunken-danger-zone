//
//  DGTeaEncryptor.h
//  DGTeaEncryptor
//
//  Created by Daniel Cohen Gindi on 4/3/12.
//  Copyright (c) 2013 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  An implementation of the Corrected Block Tiny Encryption Algorithm (XXTEA)

#import <Foundation/Foundation.h>

@interface DGTeaEncryptor : NSObject

+ (NSString *)encrypt:(NSString *)plaintext withPassword:(NSString *)password;
+ (NSString *)decrypt:(NSString *)ciphertext withPassword:(NSString *)password;

@end
