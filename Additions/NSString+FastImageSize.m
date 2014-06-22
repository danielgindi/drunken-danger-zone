//
//  NSString+FastImageSize.m
//  Additions
//
//  Created by Daniel Cohen Gindi on 3/29/13.
//  Copyright (c) 2013 danielgindi@gmail.com. All rights reserved.
//
//  Extended to handle TIFF and ICNS files by David W. Stockton 4/23/14.
//  Copyright (c) 2014 Syntonicity, LLC. All rights reserved.
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

// Headers to identify the different formats
#define JPEG_HEADER			(uint8_t[2]){ 0xff, 0xd8 }
#define JPEG_EXIF_HEADER	(uint8_t[4]){ 'E', 'x', 'i', 'f' }
#define PNG_HEADER			(uint8_t[8]){ 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }
#define GIF_HEADER			(uint8_t[3]){ 'G', 'I', 'F' }
#define BMP_HEADER			(uint8_t[2]){ 0x42, 0x4D }
#define ICNS_HEADER			(uint8_t[4]){ 'i', 'c', 'n', 's' }

// Tiff codes
#define TIFF_HEADER_LITTLE	(uint8_t[4]){ 0x49, 0x49, 0x2a, 0x00 }
#define TIFF_HEADER_BIG		(uint8_t[4]){ 0x4d, 0x4d, 0x00, 0x2a }

#define TIFF_DATATYPE_BYTE			1		// BYTE	    8-bit unsigned integer
#define TIFF_DATATYPE_ASCII			2		// ASCII    8-bit, NULL-terminated string
#define TIFF_DATATYPE_SHORT			3		// SHORT    16-bit unsigned integer
#define TIFF_DATATYPE_LONG			4		// LONG        32-bit unsigned integer
#define TIFF_DATATYPE_RATIONAL		5		// RATIONAL Two 32-bit unsigned integers
#define TIFF_DATATYPE_SBYTE			6		// SBYTE    8-bit signed integer
#define TIFF_DATATYPE_UNDEFINE		7		// UNDEFINE    8-bit byte
#define TIFF_DATATYPE_SSHORT		8		// SSHORT    16-bit signed integer
#define TIFF_DATATYPE_SLONG			9		// SLONG    32-bit signed integer
#define TIFF_DATATYPE_SRATIONAL		10		// SRATIONAL    Two 32-bit signed integers
#define TIFF_DATATYPE_FLOAT			11		// FLOAT    4-byte single-precision IEEE floating-point value
#define TIFF_DATATYPE_DOUBLE		12		// DOUBLE    8-byte double-precision IEEE floating-point value

#define TIFF_TAG_ORIENTATION		274		// Short value
#define TIFF_TAG_IMAGEHEIGHT		257		// SHORT or LONG
#define TIFF_TAG_IMAGEWIDTH			256		// SHORT or LONG

// Exif tags
#define EXIF_TAG_ORIENTATION 0x0112
#define EXIF_TAG_PIX_XDIM 0xA002
#define EXIF_TAG_PIX_YDIM 0xA003
#define EXIF_TAG_IFD 0x8769

// Bitwise macros
#define READ_UINT16	(fread(buffer, 1, 2, file) == 2)
#define LAST_UINT16	(uint16_t)(littleEndian ? (buffer[0] | buffer[1] << 8) : (buffer[1] | buffer[0] << 8))
#define LAST_INT16	(int16_t)(littleEndian ? (buffer[0] | buffer[1] << 8) : (buffer[1] | buffer[0] << 8))
#define READ_UINT32	(fread(buffer, 1, 4, file) == 4)
#define LAST_UINT32	(uint32_t)(littleEndian ? (buffer[0] | buffer[1] << 8 | buffer[2] << 16 | buffer[3] << 24) : (buffer[3] | buffer[2] << 8 | buffer[1] << 16 | buffer[0] << 24))

- (CGSize)sizeOfImageForFilePath
{
    BOOL success = NO;
    CGSize size = CGSizeZero;

    FILE *file = fopen([[NSFileManager defaultManager] fileSystemRepresentationWithPath:self], "r");
    if (file)
    {
        uint8_t buffer[4];
        if (fread(buffer, 1, 2, file) == 2 &&
            memcmp(buffer, JPEG_HEADER, 2) == 0)
        { // JPEG
            size = [self sizeOfImageForFilePath_JPEG:file];
            success = size.width > 0.f && size.height > 0.f;
        }
        
        if(!success)
        { // TIFF
            fseek(file, 0, SEEK_SET);
            size = [self sizeOfImageForFilePath_TIFF:file];
            success = size.width > 0.f && size.height > 0.f;
        }
        
        if(!success)
        { // Apple icon file
            fseek( file, 0, SEEK_SET );
            size = [self sizeOfImageForFilePath_ICNS: file];
            success = size.width > 0.f && size.height > 0.f;
        }
        
        if (!success)
        { // Now try to detect a PNG
            fseek(file, 0, SEEK_SET);
            
            uint8_t buffer8[8];
            if (fread(buffer8, 1, 8, file) == 8 &&
                memcmp(buffer8, PNG_HEADER, 8) == 0)
            {
                // It's a PNG!
                
                if (!fseek(file, 8, SEEK_CUR))
                {
                    if (fread(buffer, 1, 4, file) == 4)
                    {
                        size.width = (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3];
                    }
                    if (fread(buffer, 1, 4, file) == 4)
                    {
                        size.height = (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3];
                        success = YES;
                    }
                }
            }
        }
        
        if (!success)
        { // Now try to detect a GIF
            fseek(file, 0, SEEK_SET);
            
            if (fread(buffer, 1, 3, file) == 3 &&
                memcmp(buffer, GIF_HEADER, 3) == 0)
            {
                // It's a GIF!
                
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
        { // Now try to detect a bitmap
            fseek(file, 0, SEEK_SET);
            
            if (fread(buffer, 1, 2, file) == 2 &&
                memcmp(buffer, BMP_HEADER, 2) == 0)
            {
                // It's a bitmap!
                
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

- (CGSize)sizeOfImageForFilePath_JPEG:(FILE *)file
{
    uint8_t buffer[4];
    
    while (fread(buffer, 1, 2, file) == 2 && buffer[0] == 0xFF &&
           ((buffer[1] >= 0xE0 && buffer[1] <= 0xEF) ||
            buffer[1] == 0xDB ||
            buffer[1] == 0xC4 || buffer[1] == 0xC2 ||
            buffer[1] == 0xC0))
    {
        if (buffer[1] == 0xE1)
        { // Parse APP1 EXIF
            
            fpos_t offset;
            if (fgetpos(file, &offset)) return CGSizeZero;
            
            // Marker segment length
            
            if (fread(buffer, 1, 2, file) != 2) return CGSizeZero;
            // int blockLength = ((buffer[0] << 8) | buffer[1]) - 2;
            
            // Exif
            if (fread(buffer, 1, 4, file) != 4 ||
                memcmp(buffer, JPEG_EXIF_HEADER, 4) != 0) return CGSizeZero;
            
            // Read Byte alignment offset
            if (fread(buffer, 1, 2, file) != 2 ||
                buffer[0] != 0x00 || buffer[1] != 0x00) return CGSizeZero;
            
            // Read Byte alignment
            if (fread(buffer, 1, 2, file) != 2) return CGSizeZero;
            
            bool littleEndian = false;
            if (buffer[0] == 0x49 && buffer[1] == 0x49)
            {
                littleEndian = true;
            }
            else if (buffer[0] != 0x4D && buffer[1] != 0x4D) return CGSizeZero;
            
            // TIFF tag marker
            if (!READ_UINT16 || LAST_UINT16 != 0x002A) return CGSizeZero;
            
            // Directory offset bytes
            if (!READ_UINT32) return CGSizeZero;
            uint32_t dirOffset = LAST_UINT32;
            
            int tag;
            uint16_t numberOfTags, tagType;
            uint32_t /*tagLength, */tagValue;
            int orientation = 1, width = 0, height = 0;
            uint32_t exifIFDOffset = 0;
            
            while (dirOffset != 0)
            {
                fseek(file, (long)offset + 8 + dirOffset, SEEK_SET);
                
                if (!READ_UINT16) return CGSizeZero;
                numberOfTags = LAST_UINT16;
                
                for (uint16_t i = 0; i < numberOfTags; i++)
                {
                    if (!READ_UINT16) return CGSizeZero;
                    tag = LAST_UINT16;
                    
                    if (!READ_UINT16) return CGSizeZero;
                    tagType = LAST_UINT16;
                    
                    if (!READ_UINT32) return CGSizeZero;
                    /*tagLength = LAST_UINT32*/;
                    
                    if (tag == EXIF_TAG_ORIENTATION ||
                        tag == EXIF_TAG_PIX_XDIM ||
                        tag == EXIF_TAG_PIX_YDIM ||
                        tag == EXIF_TAG_IFD)
                    {
                        switch (tagType)
                        {
                            default:
                            case 1:
                                tagValue = fread(buffer, 1, 1, file) == 1 && buffer[0];
                                fseek(file, 3, SEEK_CUR);
                                break;
                            case 3:
                                if (!READ_UINT16) return CGSizeZero;
                                tagValue = LAST_UINT16;
                                fseek(file, 2, SEEK_CUR);
                                break;
                            case 4:
                            case 9:
                                if (!READ_UINT32) return CGSizeZero;
                                tagValue = LAST_UINT32;
                                break;
                        }
                        
                        if (tag == EXIF_TAG_ORIENTATION)
                        { // Orientation tag
                            orientation = (int)tagValue;
                        }
                        else if (tag == EXIF_TAG_PIX_XDIM)
                        { // Width tag
                            width = (int)tagValue;
                        }
                        else if (tag == EXIF_TAG_PIX_YDIM)
                        { // Height tag
                            height = (int)tagValue;
                        }
                        else if (tag == EXIF_TAG_IFD)
                        { // EXIF IFD offset tag
                            exifIFDOffset = tagValue;
                        }
                    }
                    else
                    {
                        fseek(file, 4, SEEK_CUR);
                    }
                }
                
                if (dirOffset == exifIFDOffset)
                {
                    break;
                }
                
                if (!READ_UINT32) return CGSizeZero;
                dirOffset = LAST_UINT32;
                
                if (dirOffset == 0)
                {
                    dirOffset = exifIFDOffset;
                }
            }
            
            if (width > 0 && height > 0)
            {
                if (orientation >= 5 && orientation <= 8)
                {
                    return (CGSize){height, width};
                }
                else
                {
                    return (CGSize){width, height};
                }
            }
            
            // Just because the height and width were not in this EXIF is no reason to give up!
            //return CGSizeZero;
        }
        else if (buffer[1] == 0xC0 || buffer[1] == 0xC2)
        { // Parse SOF0 (Start of Frame, Baseline DCT or Progressive DCT)
            
            // Skip LF, P
            if (fseek(file, 3, SEEK_CUR)) return CGSizeZero;
            
            // Read Y,X
            if (fread(buffer, 1, 4, file) != 4) return CGSizeZero;
            
            return (CGSize){buffer[2] << 8 | buffer[3], buffer[0] << 8 | buffer[1]};
        }
        else
        { // Skip APPn segment
            if (fread(buffer, 1, 2, file) == 2)
            { // Marker segment length
                fseek(file, (int)((buffer[0] << 8) | buffer[1]) - 2, SEEK_CUR);
            }
            else
            {
                return CGSizeZero;
            }
        }
    }
    
    return CGSizeZero;
}

#pragma mark - TIFF

/*!
 @author David W. Stockton
 @brief 
     Code below based on the description at:
     http://www.fileformat.info/format/tiff/egff.htm
 */
 
- (CGSize)sizeOfImageForFilePath_TIFF:(FILE *)file
{
    CGSize size = CGSizeZero;
    bool littleEndian = false;
    uint8_t buffer[4];
    
    // Attempt to read TIFF header
    // Read TIFF byte alignment and version number (always 2A)
    if (fread(buffer, 1, 4, file) != 4)
    {
        return CGSizeZero;
    }
    if (memcmp(buffer, TIFF_HEADER_BIG, 4) == 0)
    {
        // Found TIFF big endian header
        littleEndian = false;
    }
    else if (memcmp(buffer, TIFF_HEADER_LITTLE, 4) == 0)
    {
        // Found TIFF little endian header
        littleEndian = true;
    }
    else
    {
        return CGSizeZero;
    }
    
    // Read the offset to the first Image File Directory (IFD)
    if (!READ_UINT32) return CGSizeZero;
    uint32_t dirOffset = LAST_UINT32;
    
    // If we are not at the first IFD seek to it
    if (dirOffset != 0x08)
    {
        fseek( file, dirOffset, SEEK_SET );
    }
    
    do
    {
        int orientation = 1, width = 0, height = 0;
        
        // Loading an IFD
        uint16_t numDirEntries, tagID, tagDataType;
        uint32_t tagValue = 0;
        
        // Figure out how many Tags in the IFD
        if (!READ_UINT16) return CGSizeZero;        
        numDirEntries = LAST_UINT16;
        
        // Read the tags
        for (uint16_t i = 0; i < numDirEntries; ++i)
        {
            if (!READ_UINT16) return CGSizeZero;
            tagID = LAST_UINT16;
            
            if (!READ_UINT16) return CGSizeZero;
            tagDataType = LAST_UINT16;
            
            // Read the number of data items
            if (!READ_UINT32) return CGSizeZero;
                        
            if (tagID == TIFF_TAG_ORIENTATION ||
               tagID == TIFF_TAG_IMAGEHEIGHT ||
               tagID == TIFF_TAG_IMAGEWIDTH)
            {
                switch (tagDataType)
                {
                    case TIFF_DATATYPE_BYTE:
                    case TIFF_DATATYPE_SBYTE:
                        tagValue = fread(buffer, 1, 1, file) == 1 && buffer[0];
                        fseek(file, 3, SEEK_CUR);
                        break;
                    case TIFF_DATATYPE_SHORT:
                    case TIFF_DATATYPE_SSHORT:
                        if (!READ_UINT16) return CGSizeZero;
                        tagValue = LAST_UINT16;
                        fseek(file, 2, SEEK_CUR);
                        break;
                    case TIFF_DATATYPE_LONG:
                    case TIFF_DATATYPE_SLONG:
                        if (!READ_UINT32) return CGSizeZero;
                        tagValue = LAST_UINT32;
                        break;
                    case TIFF_DATATYPE_ASCII:
                    case TIFF_DATATYPE_RATIONAL:
                    case TIFF_DATATYPE_UNDEFINE:
                    case TIFF_DATATYPE_SRATIONAL:
                    case TIFF_DATATYPE_FLOAT:
                    case TIFF_DATATYPE_DOUBLE:
                    default:
                        if (!READ_UINT32) return CGSizeZero;
                        tagValue = LAST_UINT32;
                        break;
                }
                
                switch (tagID)
                {
                    case TIFF_TAG_ORIENTATION:
                        orientation = (int)tagValue;
                        break;
                    case TIFF_TAG_IMAGEHEIGHT:
                        height = (int)tagValue;
                        break;
                    case TIFF_TAG_IMAGEWIDTH:
                        width = (int)tagValue;
                        break;
                    default:
                        break;
                }
            }
            else
            {
                // Don't care about the tag -- skip past its offset
                fseek(file, 4, SEEK_CUR);
            }
        }
        
        if (width > 0 && height > 0)
        {
            // Maybe I should just keep the largest...
            if (orientation >= 5 && orientation <= 8)
            {
                if (height > size.width && width > size.height)
                {
                    size = CGSizeMake(height, width);
                }
            }
            else
            {
                if (height > size.height && width > size.width)
                {
                    size = CGSizeMake(width, height);
                }
            }
        }
        
        // Read the offset to tbe next IFD
        if (!READ_UINT32) return CGSizeZero;        
        dirOffset = LAST_UINT32;
        
        // Advance the file to the next IFD
        if (dirOffset > 0)
        {
            fseek(file, dirOffset, SEEK_SET);
        }
    } while( dirOffset != 0x00 );
    
    return size;
}

#pragma mark - ICNS

/*!
 @author David W. Stockton
 @brief 
     Code below based on the description at:
     http://en.wikipedia.org/wiki/Apple_Icon_Image_format
 */
 
typedef struct {
    char osType[5];
    int width;
    int height;
} appleIconInfo;

static appleIconInfo appleIconInfoTable[] = {
	//	OSType	Width, Height		// Length	Size	Supported OS Version	Description
	//					  (bytes)	(pixels)
	{ "ICON", 32, 32 },		// 128		32	1.0	32ֳ—32 1-bit mono icon
	{ "ICN#", 32, 32 },		// 256		32	6.0	32ֳ—32 1-bit mono icon with 1-bit mask
	{ "icm#", 16, 12 },		// 48		16	6.0	16ֳ—12 1 bit mono icon with 1-bit mask
	{ "icm4", 16, 12 },		// 96		16	7.0	16ֳ—12 4 bit icon
	{ "icm8", 16, 12 },		// 192		16	7.0	16ֳ—12 8 bit icon
	{ "ics#", 16, 16 },		// 64 (32 img + 32 mask) 16	6.0	16ֳ—16 1-bit mask
	{ "ics4", 16, 16 },		// 128		16	7.0	16ֳ—16 4-bit icon
	{ "ics8", 16, 16 },		// 256		16	7.0	16x16 8 bit icon
	{ "is32", 16, 16 },		// varies (768)	16	8.5	16ֳ—16 24-bit icon
	{ "s8mk", 16, 16 },		// 256		16	8.5	16x16 8-bit mask
	{ "icl4", 32, 32 },		// 512		32	7.0	32ֳ—32 4-bit icon
	{ "icl8", 32, 32 },		// 1,024	32	7.0	32ֳ—32 8-bit icon
	{ "il32", 32, 32 },		// varies (3,072) 32	8.5	32x32 24-bit icon
	{ "l8mk", 32, 32 },		// 1,024	32	8.5	32ֳ—32 8-bit mask
	{ "ich#", 48, 48 },		// 288		48	8.5	48ֳ—48 1-bit mask
	{ "ich4", 48, 48 },		// 1,152	48	8.5	48ֳ—48 4-bit icon
	{ "ich8", 48, 48 },		// 2,304	48	8.5	48ֳ—48 8-bit icon
	{ "ih32", 48, 48 },		// varies (6,912) 48	8.5	48ֳ—48 24-bit icon
	{ "h8mk", 48, 48 },		// 2,304	48	8.5	48ֳ—48 8-bit mask
	{ "it32", 128, 128 },	// varies (49,152) 128	10.0	128ֳ—128 24-bit icon
	{ "t8mk", 128, 128 },	// 16,384	128	10.0	128ֳ—128 8-bit mask
	{ "icp4", 16, 16 },		// varies	16	10.7	16x16 icon in JPEG 2000 or PNG format
	{ "icp5", 32, 32 },		// varies	32	10.7	32x32 icon in JPEG 2000 or PNG format
	{ "icp6", 64, 64 },		// varies	64	10.7	64x64 icon in JPEG 2000 or PNG format
	{ "ic07", 128, 128 },	// varies	128	10.7	128x128 icon in JPEG 2000 or PNG format
	{ "ic08", 256, 256 },	// varies	256	10.5	256ֳ—256 icon in JPEG 2000 or PNG format
	{ "ic09", 512, 512 },	// varies	512	10.5	512ֳ—512 icon in JPEG 2000 or PNG format
	{ "ic10", 1024, 1024 },	// varies	1024	10.7	1024ֳ—1024 in 10.7 (or 512x512@2x "retina" in 10.8) icon in JPEG 2000 or PNG format
	{ "ic11", 32, 32 },		// varies	32	10.8	16x16@2x "retina" icon in JPEG 2000 or PNG format
	{ "ic12", 64, 64 },		// varies	64	10.8	32x32@2x "retina" icon in JPEG 2000 or PNG format
	{ "ic13", 256, 256 },	// varies	256	10.8	128x128@2x "retina" icon in JPEG 2000 or PNG format
	{ "ic14", 512, 512 },	// varies	512	10.8	256x256@2x "retina" icon in JPEG 2000 or PNG format
	{ "----", 0, 0 },		// end marker for search failure
};

- (CGSize)sizeOfImageForFilePath_ICNS:(FILE *)file
{
    CGSize size = CGSizeZero;
    bool littleEndian = false;
    uint8_t buffer[4];
    
    // Attempt to read ICNS header
    // Read ICNS magic number (always "icns")
    if (fread(buffer, 1, 4, file) != 4 ||
       memcmp(buffer, ICNS_HEADER, 4) != 0)
    {
        return CGSizeZero;
    }
    
    // Read the length of the file in bytes
    if (!READ_UINT32) return CGSizeZero;
    uint32_t fileSize = LAST_UINT32;
    
    uint32_t dataLength = 0;
    uint32_t filepos = 8;
    int width = 0;
    int height = 0;
    int i;
	
    do
    {
        // Read the icon type
        if (!READ_UINT32) return CGSizeZero;
        char iconType[5];
        memcpy(iconType, buffer, 4);
        iconType[4] = '\0';
        
        // Read the Length of data, in bytes (including type and length), msb first
        if (!READ_UINT32) return CGSizeZero;
        dataLength = LAST_UINT32;
        
        for (i = 0; appleIconInfoTable[i].width > 0; ++i)
        {
            if (strcmp(iconType, appleIconInfoTable[i].osType) == 0) 
			{
                if (appleIconInfoTable[i].width > width) 
				{
					width = appleIconInfoTable[i].width;
				}
                if (appleIconInfoTable[i].height > height) 
				{
					height = appleIconInfoTable[i].height;
				}
                break;
            }
        }
		
        if (appleIconInfoTable[i].width <= 0 &&
           strcmp(iconType, "icnV") != 0 &&
           strcmp(iconType, "TOC ") != 0)
        {
            NSLog(@"sizeOfImageForFilePath_ICNS failed: OSType '%s' not found in the table", iconType);
        }
        
        filepos += dataLength;
    } while (filepos < fileSize && fseek(file, dataLength - 8, SEEK_CUR) == 0);
    
    if (width > 0 && height > 0)
    {
        size = CGSizeMake( (CGFloat) width, (CGFloat) height );
    }
    return size;
}

@end
