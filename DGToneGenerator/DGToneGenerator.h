//
//  DGToneGenerator.h
//  DGToneGenerator
//
//  Created by Daniel Cohen Gindi on 5/4/12.
//  Copyright (c) 2011 Daniel Cohen Gindi. All rights reserved.
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
#import <AudioUnit/AudioUnit.h>

typedef enum _DGToneGeneratorDtmf
{
    DGToneGeneratorDtmf0,
    DGToneGeneratorDtmf1,
    DGToneGeneratorDtmf2,
    DGToneGeneratorDtmf3,
    DGToneGeneratorDtmf4,
    DGToneGeneratorDtmf5,
    DGToneGeneratorDtmf6,
    DGToneGeneratorDtmf7,
    DGToneGeneratorDtmf8,
    DGToneGeneratorDtmf9,
    DGToneGeneratorDtmfStar,
    DGToneGeneratorDtmfPound,
    DGToneGeneratorDtmfA,
    DGToneGeneratorDtmfB,
    DGToneGeneratorDtmfC,
    DGToneGeneratorDtmfD
} DGToneGeneratorDtmf;

@interface DGToneGenerator : NSObject

/*! @property manageAudioSession
    @brief Should the DGToneGenerator manage initialize, start/stop etc. the AudioSession as needed?
				Set to NO if the app manages the AudioSession in other means.
				Default YES */
@property (nonatomic, assign) BOOL manageAudioSession;

/*! @property preventMute
    @brief Should we prevent muting other sounds of the device while playing the tones?
				Only effective when manageAudioSession is YES.
                Default is NO */
@property (nonatomic, assign) BOOL preventMute;
	
/*! @property sampleRate
    @brief Default is 44100 */
@property (nonatomic, assign) double sampleRate;
	
/*! @property amplitude
    @brief Default is 0.5 */
@property (nonatomic, assign) double amplitude;
	
/*! @property frequency
    @brief Frequency to play. Default is 440 */
@property (nonatomic, assign) double frequency;
	
/*! @property secondFrequency
    @brief Another frequency to play mix together with the main frequency. Default is -1 */
@property (nonatomic, assign) double secondFrequency;

/*! @property isPlaying
    @brief Are we currently playing? */
@property (nonatomic, assign, readonly) BOOL isPlaying;

/*! Make the initial AudioToolbox load, which takes time. Use this to prevent lag on the first play call. */
- (void)preInit;

/*! Start playing the sound */
- (void)play;

/*! Stop playing */
- (void)stop;

/*! Set the frequency to play by a predefined DTMF */
- (void)setDtmfFrequency:(DGToneGeneratorDtmf)dtmf;

@end
