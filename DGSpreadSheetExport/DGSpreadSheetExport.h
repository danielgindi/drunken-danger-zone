//
//  DGSpreadSheetExportExport.h
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

#import <Foundation/Foundation.h>

#pragma mark - Constant macros

#define kDGSpreadSheetExportExportNumberFormatGeneral @"General"
#define kDGSpreadSheetExportExportNumberFormatGeneralNumber @"General Number"
#define kDGSpreadSheetExportExportNumberFormatGeneralDate @"General Date"
#define kDGSpreadSheetExportExportNumberFormatLongDate @"Long Date"
#define kDGSpreadSheetExportExportNumberFormatMediumDate @"Medium Date"
#define kDGSpreadSheetExportExportNumberFormatShortDate @"Short Date"
#define kDGSpreadSheetExportExportNumberFormatLongTime @"Long Time"
#define kDGSpreadSheetExportExportNumberFormatMediumTime @"Medium Time"
#define kDGSpreadSheetExportExportNumberFormatShortTime @"Short Time"
#define kDGSpreadSheetExportExportNumberFormatCurrency @"Currency"
#define kDGSpreadSheetExportExportNumberFormatEuroCurrency @"Euro Currency"
#define kDGSpreadSheetExportExportNumberFormatFixed @"Fixed"
#define kDGSpreadSheetExportExportNumberFormatStandard @"Standard"
#define kDGSpreadSheetExportExportNumberFormatPercent @"Percent"
#define kDGSpreadSheetExportExportNumberFormatScientific @"Scientific"
#define kDGSpreadSheetExportExportNumberFormatYesNo @"Yes/No"
#define kDGSpreadSheetExportExportNumberFormatTrueFalse @"True/False"
#define kDGSpreadSheetExportExportNumberFormatOnOff @"On/Off"
#define kDGSpreadSheetExportExportNumberFormat0 @"0"
#define kDGSpreadSheetExportExportNumberFormat0_00 @"0.00"

#pragma mark - Enums

typedef enum _DGSpreadSheetExportExportAlignmentHorizontal
{
    DGSpreadSheetExportExportAlignmentHorizontalAutomatic,
    DGSpreadSheetExportExportAlignmentHorizontalLeft,
    DGSpreadSheetExportExportAlignmentHorizontalCenter,
    DGSpreadSheetExportExportAlignmentHorizontalRight,
    DGSpreadSheetExportExportAlignmentHorizontalFill,
    DGSpreadSheetExportExportAlignmentHorizontalJustify,
    DGSpreadSheetExportExportAlignmentHorizontalCenterAcrossSelection,
    DGSpreadSheetExportExportAlignmentHorizontalDistributed,
    DGSpreadSheetExportExportAlignmentHorizontalJustifyDistributed
} DGSpreadSheetExportExportAlignmentHorizontal;

typedef enum _DGSpreadSheetExportExportAlignmentVertical
{
    DGSpreadSheetExportExportAlignmentVerticalAutomatic,
    DGSpreadSheetExportExportAlignmentVerticalTop,
    DGSpreadSheetExportExportAlignmentVerticalCenter,
    DGSpreadSheetExportExportAlignmentVerticalBottom,
    DGSpreadSheetExportExportAlignmentVerticalJustify,
    DGSpreadSheetExportExportAlignmentVerticalDistributed,
    DGSpreadSheetExportExportAlignmentVerticalJustifyDistributed
} DGSpreadSheetExportExportAlignmentVertical;

typedef enum _DGSpreadSheetExportExportAlignmentReadingOrder
{
    DGSpreadSheetExportExportAlignmentReadingOrderContext,
    DGSpreadSheetExportExportAlignmentReadingOrderRightToLeft,
    DGSpreadSheetExportExportAlignmentReadingOrderLeftToRight
} DGSpreadSheetExportExportAlignmentReadingOrder;

typedef enum _DGSpreadSheetExportExportBorderPosition
{
    DGSpreadSheetExportExportBorderPositionLeft,
    DGSpreadSheetExportExportBorderPositionTop,
    DGSpreadSheetExportExportBorderPositionRight,
    DGSpreadSheetExportExportBorderPositionBottom,
    DGSpreadSheetExportExportBorderPositionDiagonalLeft,
    DGSpreadSheetExportExportBorderPositionDiagonalRight
} DGSpreadSheetExportExportBorderPosition;

typedef enum _DGSpreadSheetExportExportBorderLineStyle
{
    DGSpreadSheetExportExportBorderLineStyleNone,
    DGSpreadSheetExportExportBorderLineStyleContinuous,
    DGSpreadSheetExportExportBorderLineStyleDash,
    DGSpreadSheetExportExportBorderLineStyleDot,
    DGSpreadSheetExportExportBorderLineStyleDashDot,
    DGSpreadSheetExportExportBorderLineStyleDashDotDot,
    DGSpreadSheetExportExportBorderLineStyleSlantDashDot,
    DGSpreadSheetExportExportBorderLineStyleDouble
} DGSpreadSheetExportExportBorderLineStyle;

typedef enum _DGSpreadSheetExportExportInteriorPattern
{
    DGSpreadSheetExportExportInteriorPatternNone,
    DGSpreadSheetExportExportInteriorPatternSolid,
    DGSpreadSheetExportExportInteriorPatternGray75,
    DGSpreadSheetExportExportInteriorPatternGray50,
    DGSpreadSheetExportExportInteriorPatternGray25,
    DGSpreadSheetExportExportInteriorPatternGray125,
    DGSpreadSheetExportExportInteriorPatternGray0625,
    DGSpreadSheetExportExportInteriorPatternHorzStripe,
    DGSpreadSheetExportExportInteriorPatternVertStripe,
    DGSpreadSheetExportExportInteriorPatternReverseDiagStripe,
    DGSpreadSheetExportExportInteriorPatternDiagStripe,
    DGSpreadSheetExportExportInteriorPatternDiagCross,
    DGSpreadSheetExportExportInteriorPatternThickDiagCross,
    DGSpreadSheetExportExportInteriorPatternThinHorzStripe,
    DGSpreadSheetExportExportInteriorPatternThinVertStripe,
    DGSpreadSheetExportExportInteriorPatternThinReverseDiagStripe,
    DGSpreadSheetExportExportInteriorPatternThinDiagStripe,
    DGSpreadSheetExportExportInteriorPatternThinHorzCross,
    DGSpreadSheetExportExportInteriorPatternThinDiagCross
} DGSpreadSheetExportExportInteriorPattern;

typedef enum _DGSpreadSheetExportExportFontUnderline
{
    DGSpreadSheetExportExportFontUnderlineNone,
    DGSpreadSheetExportExportFontUnderlineSingle,
    DGSpreadSheetExportExportFontUnderlineDouble,
    DGSpreadSheetExportExportFontUnderlineSingleAccounting,
    DGSpreadSheetExportExportFontUnderlineDoubleAccounting
} DGSpreadSheetExportExportFontUnderline;

typedef enum _DGSpreadSheetExportExportFontVerticalAlign
{
    DGSpreadSheetExportExportFontVerticalAlignNone,
    DGSpreadSheetExportExportFontVerticalAlignSubscript,
    DGSpreadSheetExportExportFontVerticalAlignSuperscript
} DGSpreadSheetExportExportFontVerticalAlign;

typedef enum _DGSpreadSheetExportExportFontFamily
{
    DGSpreadSheetExportExportFontFamilyAutomatic,
    DGSpreadSheetExportExportFontFamilyDecorative,
    DGSpreadSheetExportExportFontFamilyModern,
    DGSpreadSheetExportExportFontFamilyRoman,
    DGSpreadSheetExportExportFontFamilyScript,
    DGSpreadSheetExportExportFontFamilySwiss
} DGSpreadSheetExportExportFontFamily;

#pragma mark - DGSpreadSheetExportExport

@class DGSpreadSheetExportExportStyle;

@interface DGSpreadSheetExportExport : NSObject

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
- (int)addStyle:(DGSpreadSheetExportExportStyle *)style;
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

#pragma mark - DGSpreadSheetExportExportAlignment

@interface DGSpreadSheetExportExportAlignment : NSObject

@property (assign, nonatomic) DGSpreadSheetExportExportAlignmentHorizontal horizontal;
@property (assign, nonatomic) DGSpreadSheetExportExportAlignmentVertical vertical;
@property (assign, nonatomic) NSUInteger indent;
@property (assign, nonatomic) DGSpreadSheetExportExportAlignmentReadingOrder readingOrder;
@property (assign, nonatomic) double rotate;
@property (assign, nonatomic) BOOL shrinkToFit;
@property (assign, nonatomic) BOOL verticalText;
@property (assign, nonatomic) BOOL wrapText;

@end

#pragma mark - DGSpreadSheetExportExportBorder

@interface DGSpreadSheetExportExportBorder : NSObject

- (id)initWithPosition:(DGSpreadSheetExportExportBorderPosition)position;
- (id)initWithPosition:(DGSpreadSheetExportExportBorderPosition)position andColor:(UIColor *)color;
- (id)initWithPosition:(DGSpreadSheetExportExportBorderPosition)position andColor:(UIColor *)color andLineStyle:(DGSpreadSheetExportExportBorderLineStyle)lineStyle;
- (id)initWithPosition:(DGSpreadSheetExportExportBorderPosition)position andColor:(UIColor *)color andLineStyle:(DGSpreadSheetExportExportBorderLineStyle)lineStyle andWeight:(double)weight;

@property (assign, nonatomic) DGSpreadSheetExportExportBorderPosition position;
@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) DGSpreadSheetExportExportBorderLineStyle lineStyle;
@property (assign, nonatomic) double weight;

@end

#pragma mark - DGSpreadSheetExportExportInterior

@interface DGSpreadSheetExportExportInterior : NSObject

@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) DGSpreadSheetExportExportInteriorPattern pattern;
@property (strong, nonatomic) UIColor *patternColor;

@end

#pragma mark - DGSpreadSheetExportExportFont

@interface DGSpreadSheetExportExportFont : NSObject

@property (assign, nonatomic) BOOL bold;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSString *fontName;
@property (assign, nonatomic) BOOL italic;
@property (assign, nonatomic) BOOL outline;
@property (assign, nonatomic) BOOL shadow;
@property (assign, nonatomic) double size;
@property (assign, nonatomic) BOOL strikeThrough;
@property (assign, nonatomic) DGSpreadSheetExportExportFontUnderline underline;
@property (assign, nonatomic) DGSpreadSheetExportExportFontVerticalAlign verticalAlign;
@property (assign, nonatomic) NSUInteger charSet;
@property (assign, nonatomic) DGSpreadSheetExportExportFontFamily family;

@end

#pragma mark - DGSpreadSheetExportExportStyle

@interface DGSpreadSheetExportExportStyle : NSObject

@property (strong, nonatomic) NSString *numberFormat;
@property (strong, nonatomic) DGSpreadSheetExportExportAlignment *alignment;
@property (strong, nonatomic) NSMutableArray *borders;
@property (strong, nonatomic) DGSpreadSheetExportExportInterior *interior;
@property (strong, nonatomic) DGSpreadSheetExportExportFont *font;

@end
