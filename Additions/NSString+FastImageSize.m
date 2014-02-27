//
//  NSString+FastImageSize.m
//  Additions
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//
//  The MIT License (MIT)
//  
//  Copyright (c) 2014 Daniel Cohen Gindi (danielgindi@gmail.com)
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE. 
//  

#import "NSString+FastImageSize.h"

@implementation NSString (FastImageSize)

- (CGSize *)sizeOfImageForFilePath
{
    BOOL success = NO;
    CGSize size = {-1.f, -1.f};
    
    FILE *file = fopen([[NSFileManager defaultManager] fileSystemRepresentationWithPath:self], "r");
    if (file)
    {
        uint8_t buffer[4];
        if (fread(buffer, 1, 4, file) == 4 &&
            memcmp(buffer, (uint8_t[4]){0xff, 0xd8, 0xff, 0xe0}, 4) == 0)
        {
            // JPEG?
            if (fread(buffer, 1, 2, file) == 2)
            {
                int blockLength = ((buffer[0] << 8) + buffer[1]);
                
                if (fread(buffer, 1, 4, file) == 4 &&
                    strncmp((char *)buffer, "JFIF", 4) == 0 &&
                    fread(buffer, 1, 1, file) == 1 &&
                    buffer[0] == 0)
                {
                    // JPEG!
                    
                    int reverseBytes = 7;
                    while (!success && !feof(file))
                    {
                        if (fseek(file, blockLength - reverseBytes, SEEK_CUR))
                        {
                            break;
                        }
                        
                        if (fread(buffer, 1, 4, file) == 4)
                        {
                            reverseBytes = 4;
                            blockLength = ((buffer[2] << 8) + buffer[3]);
                            
                            if (blockLength >= 7 && buffer[0] == 0xff && buffer[1] == 0xc0)
                            {
                                if (fseek(file, 1, SEEK_CUR))
                                {
                                    break;
                                }
                                reverseBytes++;
                                
                                if (fread(buffer, 1, 4, file) == 4)
                                {
                                    size = (CGSize){((buffer[2] << 8) + buffer[3]), ((buffer[0] << 8) + buffer[1])};
                                    success = YES;
                                    break;
                                }
                            }
                            reverseBytes -= 2;
                        }
                    }
                }
            }
        }
        
        if (!success)
        {
            fseek(file, 0, SEEK_SET);
            
            if (fread(buffer, 1, 4, file) == 4 &&
                memcmp(buffer, (uint8_t[4]){0x89, 0x50, 0x4E, 0x47}, 4) == 0 &&
                fread(buffer, 1, 4, file) == 4 &&
                memcmp(buffer, (uint8_t[4]){0x0D, 0x0A, 0x1A, 0x0A}, 4) == 0)
            {
                // PNG
                
                if (!fseek(file, 8, SEEK_CUR))
                {
                    if (fread(buffer, 1, 4, file) == 4)
                    {
                        size.width = (buffer[0] << 24) + (buffer[1] << 16) + (buffer[2] << 8) + buffer[3];
                    }
                    if (fread(buffer, 1, 4, file) == 4)
                    {
                        size.height = (buffer[0] << 24) + (buffer[1] << 16) + (buffer[2] << 8) + buffer[3];
                        success = YES;
                    }
                }
            }
        }
        
        if (!success)
        {
            fseek(file, 0, SEEK_SET);
            
            if (fread(buffer, 1, 3, file) == 3 &&
                strncmp((char *)buffer, "GIF", 3) == 0)
            {
                // GIF
                
                if (!fseek(file, 3, SEEK_CUR)) // 87a / 89a
                {
                    if (fread(buffer, 1, 4, file) == 4)
                    {
                        size = (CGSize){*((int16_t*)buffer), *((int16_t*)(buffer + 2))};
                        success = YES;
                    }
                }
            }
        }
        
        if (!success)
        {
            fseek(file, 0, SEEK_SET);
            
            if (fread(buffer, 1, 2, file) == 2 &&
                memcmp(buffer, (uint8_t[2]){0x42, 0x4D}, 2) == 0)
            {
                // BMP
                
                if (!fseek(file, 16, SEEK_CUR))
                {
                    if (fread(buffer, 1, 4, file) == 4)
                    {
                        size.width = *((int32_t*)buffer);
                    }
                    if (fread(buffer, 1, 4, file) == 4)
                    {
                        size.height = *((int32_t*)buffer);
                        // success = YES; // Not needed, analyzer...
                    }
                }
            }
        }
        
        fclose(file);
    }
    
    return size;
}

@end
