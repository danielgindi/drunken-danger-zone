//
//  DGSpreadSheetExport.h
//  CSV or XMLSS (XML Spreadsheet) generation library
//
//  Created by Daniel Cohen Gindi (danielgindi@gmail.com)
//
//  Usage:
//  1. send [beginFile] to start
//     1. for each worksheet, send [newWorksheetNamed:]
//        1. for each expected column, send [addColumn] or [addColumnWithWidthOf:]
//        2. for each row, send [beginRow...]
//           1. for each cell, send [setCell...Value...]
//  2. send [endFile]
//
//  Optional:
//  * send [addStyle...] to generate styles that you can use later on rows and cells. 
//    for each style you have to save the returned index to use later.
//    * you have to call all [addStyle...]s BEFORE [beginFile]
//    * This is supported only by XML
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

#import <Foundation/Foundation.h>

#pragma mark - Constant macros

#define kDGSpreadSheetExportNumberFormatGeneral @"General"
#define kDGSpreadSheetExportNumberFormatGeneralNumber @"General Number"
#define kDGSpreadSheetExportNumberFormatGeneralDate @"General Date"
#define kDGSpreadSheetExportNumberFormatLongDate @"Long Date"
#define kDGSpreadSheetExportNumberFormatMediumDate @"Medium Date"
#define kDGSpreadSheetExportNumberFormatShortDate @"Short Date"
#define kDGSpreadSheetExportNumberFormatLongTime @"Long Time"
#define kDGSpreadSheetExportNumberFormatMediumTime @"Medium Time"
#define kDGSpreadSheetExportNumberFormatShortTime @"Short Time"
#define kDGSpreadSheetExportNumberFormatCurrency @"Currency"
#define kDGSpreadSheetExportNumberFormatEuroCurrency @"Euro Currency"
#define kDGSpreadSheetExportNumberFormatFixed @"Fixed"
#define kDGSpreadSheetExportNumberFormatStandard @"Standard"
#define kDGSpreadSheetExportNumberFormatPercent @"Percent"
#define kDGSpreadSheetExportNumberFormatScientific @"Scientific"
#define kDGSpreadSheetExportNumberFormatYesNo @"Yes/No"
#define kDGSpreadSheetExportNumberFormatTrueFalse @"True/False"
#define kDGSpreadSheetExportNumberFormatOnOff @"On/Off"
#define kDGSpreadSheetExportNumberFormat0 @"0"
#define kDGSpreadSheetExportNumberFormat0_00 @"0.00"

#pragma mark - Enums

typedef enum _DGSpreadSheetExportAlignmentHorizontal
{
    DGSpreadSheetExportAlignmentHorizontalAutomatic,
    DGSpreadSheetExportAlignmentHorizontalLeft,
    DGSpreadSheetExportAlignmentHorizontalCenter,
    DGSpreadSheetExportAlignmentHorizontalRight,
    DGSpreadSheetExportAlignmentHorizontalFill,
    DGSpreadSheetExportAlignmentHorizontalJustify,
    DGSpreadSheetExportAlignmentHorizontalCenterAcrossSelection,
    DGSpreadSheetExportAlignmentHorizontalDistributed,
    DGSpreadSheetExportAlignmentHorizontalJustifyDistributed
} DGSpreadSheetExportAlignmentHorizontal;

typedef enum _DGSpreadSheetExportAlignmentVertical
{
    DGSpreadSheetExportAlignmentVerticalAutomatic,
    DGSpreadSheetExportAlignmentVerticalTop,
    DGSpreadSheetExportAlignmentVerticalCenter,
    DGSpreadSheetExportAlignmentVerticalBottom,
    DGSpreadSheetExportAlignmentVerticalJustify,
    DGSpreadSheetExportAlignmentVerticalDistributed,
    DGSpreadSheetExportAlignmentVerticalJustifyDistributed
} DGSpreadSheetExportAlignmentVertical;

typedef enum _DGSpreadSheetExportAlignmentReadingOrder
{
    DGSpreadSheetExportAlignmentReadingOrderContext,
    DGSpreadSheetExportAlignmentReadingOrderRightToLeft,
    DGSpreadSheetExportAlignmentReadingOrderLeftToRight
} DGSpreadSheetExportAlignmentReadingOrder;

typedef enum _DGSpreadSheetExportBorderPosition
{
    DGSpreadSheetExportBorderPositionLeft,
    DGSpreadSheetExportBorderPositionTop,
    DGSpreadSheetExportBorderPositionRight,
    DGSpreadSheetExportBorderPositionBottom,
    DGSpreadSheetExportBorderPositionDiagonalLeft,
    DGSpreadSheetExportBorderPositionDiagonalRight
} DGSpreadSheetExportBorderPosition;

typedef enum _DGSpreadSheetExportBorderLineStyle
{
    DGSpreadSheetExportBorderLineStyleNone,
    DGSpreadSheetExportBorderLineStyleContinuous,
    DGSpreadSheetExportBorderLineStyleDash,
    DGSpreadSheetExportBorderLineStyleDot,
    DGSpreadSheetExportBorderLineStyleDashDot,
    DGSpreadSheetExportBorderLineStyleDashDotDot,
    DGSpreadSheetExportBorderLineStyleSlantDashDot,
    DGSpreadSheetExportBorderLineStyleDouble
} DGSpreadSheetExportBorderLineStyle;

typedef enum _DGSpreadSheetExportInteriorPattern
{
    DGSpreadSheetExportInteriorPatternNone,
    DGSpreadSheetExportInteriorPatternSolid,
    DGSpreadSheetExportInteriorPatternGray75,
    DGSpreadSheetExportInteriorPatternGray50,
    DGSpreadSheetExportInteriorPatternGray25,
    DGSpreadSheetExportInteriorPatternGray125,
    DGSpreadSheetExportInteriorPatternGray0625,
    DGSpreadSheetExportInteriorPatternHorzStripe,
    DGSpreadSheetExportInteriorPatternVertStripe,
    DGSpreadSheetExportInteriorPatternReverseDiagStripe,
    DGSpreadSheetExportInteriorPatternDiagStripe,
    DGSpreadSheetExportInteriorPatternDiagCross,
    DGSpreadSheetExportInteriorPatternThickDiagCross,
    DGSpreadSheetExportInteriorPatternThinHorzStripe,
    DGSpreadSheetExportInteriorPatternThinVertStripe,
    DGSpreadSheetExportInteriorPatternThinReverseDiagStripe,
    DGSpreadSheetExportInteriorPatternThinDiagStripe,
    DGSpreadSheetExportInteriorPatternThinHorzCross,
    DGSpreadSheetExportInteriorPatternThinDiagCross
} DGSpreadSheetExportInteriorPattern;

typedef enum _DGSpreadSheetExportFontUnderline
{
    DGSpreadSheetExportFontUnderlineNone,
    DGSpreadSheetExportFontUnderlineSingle,
    DGSpreadSheetExportFontUnderlineDouble,
    DGSpreadSheetExportFontUnderlineSingleAccounting,
    DGSpreadSheetExportFontUnderlineDoubleAccounting
} DGSpreadSheetExportFontUnderline;

typedef enum _DGSpreadSheetExportFontVerticalAlign
{
    DGSpreadSheetExportFontVerticalAlignNone,
    DGSpreadSheetExportFontVerticalAlignSubscript,
    DGSpreadSheetExportFontVerticalAlignSuperscript
} DGSpreadSheetExportFontVerticalAlign;

typedef enum _DGSpreadSheetExportFontFamily
{
    DGSpreadSheetExportFontFamilyAutomatic,
    DGSpreadSheetExportFontFamilyDecorative,
    DGSpreadSheetExportFontFamilyModern,
    DGSpreadSheetExportFontFamilyRoman,
    DGSpreadSheetExportFontFamilyScript,
    DGSpreadSheetExportFontFamilySwiss
} DGSpreadSheetExportFontFamily;

#pragma mark - DGSpreadSheetExport

@class DGSpreadSheetExportStyle;

@interface DGSpreadSheetExport : NSObject

- (id)initAsXml:(bool)isXml intoFileHandle:(NSFileHandle *)fileHandle withEncoding:(NSStringEncoding)encoding;
- (id)initAsXml:(bool)isXml intoFileHandle:(NSFileHandle *)fileHandle;
- (id)initAsXml:(bool)isXml;

- (void)beginFile;
- (void)endFile;
- (void)setCellStringValue:(NSString *)string;
- (void)setCellStringValue:(NSString *)string mergeAcross:(NSUInteger)mergeAcross mergeDown:(NSUInteger)mergeAcross;
- (void)setCellStringValue:(NSString *)string withStyleIndex:(int)idxStyle andFormatValueUsingStyle:(BOOL)formatFromStyle;
- (void)setCellStringValue:(NSString *)string withStyleIndex:(int)idxStyle andFormatValueUsingStyle:(BOOL)formatFromStyle mergeAcross:(NSUInteger)mergeAcross mergeDown:(NSUInteger)mergeAcross;
- (void)beginRow;
- (void)beginRowAtBeginningOfFile:(BOOL)beginning;
- (void)beginRowWithStyleIndex:(int)idxStyle;
- (void)beginRowAtBeginningOfFile:(BOOL)beginning withStyleIndex:(int)idxStyle;
- (void)beginRowAtBeginningOfFile:(BOOL)beginning withStyleIndex:(int)idxStyle andHeight:(float)height;
- (void)beginRowWithStyleIndex:(int)idxStyle andHeight:(float)height;
- (int)addStyle:(DGSpreadSheetExportStyle *)style;
- (void)newWorksheetNamed:(NSString *)name;
- (void)addColumn;
- (void)addColumnWithWidthOf:(float)width;
- (void)setCellIntValue:(int)data;
- (void)setCellIntValue:(int)data withStyleIndex:(int)idxStyle;
- (void)setCellIntValue:(int)data mergeAcross:(NSUInteger)mergeAcross mergeDown:(NSUInteger)mergeDown;
- (void)setCellIntValue:(int)data withStyleIndex:(int)idxStyle mergeAcross:(NSUInteger)mergeAcross mergeDown:(NSUInteger)mergeDown;
- (void)setCellInt64Value:(long long int)data;
- (void)setCellInt64Value:(long long int)data withStyleIndex:(int)idxStyle;
- (void)setCellInt64Value:(long long int)data mergeAcross:(NSUInteger)mergeAcross mergeDown:(NSUInteger)mergeDown;
- (void)setCellInt64Value:(long long int)data withStyleIndex:(int)idxStyle mergeAcross:(NSUInteger)mergeAcross mergeDown:(NSUInteger)mergeDown;
- (void)setCellDoubleValue:(double)data;
- (void)setCellDoubleValue:(double)data withStyleIndex:(int)idxStyle;
- (void)setCellDoubleValue:(double)data mergeAcross:(NSUInteger)mergeAcross mergeDown:(NSUInteger)mergeDown;
- (void)setCellDoubleValue:(double)data withStyleIndex:(int)idxStyle mergeAcross:(NSUInteger)mergeAcross mergeDown:(NSUInteger)mergeDown;
- (void)setCellFloatValue:(float)data;
- (void)setCellFloatValue:(float)data withStyleIndex:(int)idxStyle;
- (void)setCellFloatValue:(float)data mergeAcross:(NSUInteger)mergeAcross mergeDown:(NSUInteger)mergeDown;
- (void)setCellFloatValue:(float)data withStyleIndex:(int)idxStyle mergeAcross:(NSUInteger)mergeAcross mergeDown:(NSUInteger)mergeDown;

@property (assign, readonly, nonatomic) BOOL isXml;
@property (retain, readonly, nonatomic, getter=getFileExtension) NSString *fileExtension;
@property (retain, readonly, nonatomic, getter=getFileContentType) NSString *fileContentType;

@end

#pragma mark - DGSpreadSheetExportAlignment

@interface DGSpreadSheetExportAlignment : NSObject

@property (assign, nonatomic) DGSpreadSheetExportAlignmentHorizontal horizontal;
@property (assign, nonatomic) DGSpreadSheetExportAlignmentVertical vertical;
@property (assign, nonatomic) NSUInteger indent;
@property (assign, nonatomic) DGSpreadSheetExportAlignmentReadingOrder readingOrder;
@property (assign, nonatomic) double rotate;
@property (assign, nonatomic) BOOL shrinkToFit;
@property (assign, nonatomic) BOOL verticalText;
@property (assign, nonatomic) BOOL wrapText;

@end

#pragma mark - DGSpreadSheetExportBorder

@interface DGSpreadSheetExportBorder : NSObject

- (id)initWithPosition:(DGSpreadSheetExportBorderPosition)position;
- (id)initWithPosition:(DGSpreadSheetExportBorderPosition)position andColor:(UIColor *)color;
- (id)initWithPosition:(DGSpreadSheetExportBorderPosition)position andColor:(UIColor *)color andLineStyle:(DGSpreadSheetExportBorderLineStyle)lineStyle;
- (id)initWithPosition:(DGSpreadSheetExportBorderPosition)position andColor:(UIColor *)color andLineStyle:(DGSpreadSheetExportBorderLineStyle)lineStyle andWeight:(double)weight;

@property (assign, nonatomic) DGSpreadSheetExportBorderPosition position;
@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) DGSpreadSheetExportBorderLineStyle lineStyle;
@property (assign, nonatomic) double weight;

@end

#pragma mark - DGSpreadSheetExportInterior

@interface DGSpreadSheetExportInterior : NSObject

@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) DGSpreadSheetExportInteriorPattern pattern;
@property (strong, nonatomic) UIColor *patternColor;

@end

#pragma mark - DGSpreadSheetExportFont

@interface DGSpreadSheetExportFont : NSObject

@property (assign, nonatomic) BOOL bold;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSString *fontName;
@property (assign, nonatomic) BOOL italic;
@property (assign, nonatomic) BOOL outline;
@property (assign, nonatomic) BOOL shadow;
@property (assign, nonatomic) double size;
@property (assign, nonatomic) BOOL strikeThrough;
@property (assign, nonatomic) DGSpreadSheetExportFontUnderline underline;
@property (assign, nonatomic) DGSpreadSheetExportFontVerticalAlign verticalAlign;
@property (assign, nonatomic) NSUInteger charSet;
@property (assign, nonatomic) DGSpreadSheetExportFontFamily family;

@end

#pragma mark - DGSpreadSheetExportStyle

@interface DGSpreadSheetExportStyle : NSObject

@property (strong, nonatomic) NSString *numberFormat;
@property (strong, nonatomic) DGSpreadSheetExportAlignment *alignment;
@property (strong, nonatomic) NSMutableArray *borders;
@property (strong, nonatomic) DGSpreadSheetExportInterior *interior;
@property (strong, nonatomic) DGSpreadSheetExportFont *font;

@end
