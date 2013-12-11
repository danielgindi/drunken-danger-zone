//
//  DGToneGenerator.m
//  DGToneGenerator
//
//  Created by Daniel Cohen Gindi on 5/4/12.
//  Copyright (c) 2011 Daniel Cohen Gindi. All rights reserved.
//
//  https://github.com/danielgindi/drunken-danger-zone
//

#import "DGToneGenerator.h"
#import <AudioToolbox/AudioToolbox.h>

@interface DGToneGenerator ()
{
    AudioComponentInstance toneAudioUnit;
    BOOL isPlaying;
    double sineMultiplierPerSample, sineMultiplierPerSample_2nd;
    double samplesPerSine, samplesPerSine_2nd;
    double samplePosInSine, samplePosInSine_2nd;
	BOOL hasSecondSine;
}
@end

@implementation DGToneGenerator

void DGToneGenerator_InterruptionListener(void *inClientData, UInt32 inInterruptionState);

OSStatus DGToneGenerator_RenderTone(
                                  void *inRefCon, 
                                  AudioUnitRenderActionFlags 	*ioActionFlags, 
                                  const AudioTimeStamp          *inTimeStamp, 
                                  UInt32 						inBusNumber, 
                                  UInt32 						inNumberFrames, 
                                  AudioBufferList               *ioData);

- (id)init
{
    if ((self = [super init]))
    {
        _sampleRate = 44100;
        _frequency = 440;
        _secondFrequency = -1;
        _amplitude = 0.5f;
		_manageAudioSession = YES;
		
		[self updateSine];
    }
    return self;
}

- (void)dealloc
{
    [self stop];
    AudioSessionSetActive(NO);
	if (toneAudioUnit)
	{
		AudioUnitUninitialize(toneAudioUnit);
	}
}

- (void)setAmplitude:(double)amplitude
{
    if (amplitude < 0.0) amplitude = 0.0;
    else if (amplitude > 1.0) amplitude = 1.0f;
    _amplitude = amplitude;
}

#pragma mark - DGToneGenerator Methods

- (void)preInit
{
    if (toneAudioUnit) return;
	
	[self setupAudioUnit];
}

- (void)setupAudioUnit
{
    if (toneAudioUnit)
	{
		AudioUnitUninitialize(toneAudioUnit);
	}
    
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneAudioUnit);
	NSAssert1(toneAudioUnit, @"Error creating unit: %hd", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = DGToneGenerator_RenderTone;
	input.inputProcRefCon = (__bridge void*)self;
	err = AudioUnitSetProperty(toneAudioUnit, 
                               kAudioUnitProperty_SetRenderCallback, 
                               kAudioUnitScope_Input,
                               0, 
                               &input, 
                               sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %ld", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = _sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = 4; // four bytes per packet
	streamFormat.mFramesPerPacket = 1;	
	streamFormat.mBytesPerFrame = 4; // four bytes per frame		
	streamFormat.mChannelsPerFrame = 1;	
	streamFormat.mBitsPerChannel = 4 * 8; // four bytes (* 8 bits) per channel
	err = AudioUnitSetProperty (toneAudioUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
    
    // Stop changing parameters on the unit
    err = AudioUnitInitialize(toneAudioUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %hd", err);
}

- (void)play
{
	if (_manageAudioSession)
	{
		if (AudioSessionSetActive(YES) == kAudioSessionNotInitialized)
		{
			AudioSessionInitialize(NULL, NULL, DGToneGenerator_InterruptionListener, (__bridge void*)self);
		}
		UInt32 sessionCategory = _preventMute ? kAudioSessionCategory_MediaPlayback : kAudioSessionCategory_SoloAmbientSound;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	}
		
    if (toneAudioUnit)
    {
        [self stop];
    }
    
    [self preInit];
    
    // Start playback
    OSErr err = AudioOutputUnitStart(toneAudioUnit);
    NSAssert1(err == noErr, @"Error starting unit: %hd", err);
    
    isPlaying = YES;
}
	
- (void)stop
{
	if (_manageAudioSession)
	{
		AudioSessionSetActive(NO);
	}
	if (toneAudioUnit)
	{
		AudioOutputUnitStop(toneAudioUnit);
		AudioUnitUninitialize(toneAudioUnit);
		AudioComponentInstanceDispose(toneAudioUnit);
		toneAudioUnit = nil;
	}
    isPlaying = NO;
}

- (BOOL)isPlaying
{
    return isPlaying;
}

- (void)setDtmfFrequency:(DGToneGeneratorDtmf)dtmf
{
    switch (dtmf)
    {
        default:
        case DGToneGeneratorDtmf0:
            self.frequency = 941;
            self.secondFrequency = 1336;
            break;
        case DGToneGeneratorDtmf1:
            self.frequency = 697;
            self.secondFrequency = 1209;
            break;
        case DGToneGeneratorDtmf2:
            self.frequency = 697;
            self.secondFrequency = 1336;
            break;
        case DGToneGeneratorDtmf3:
            self.frequency = 697;
            self.secondFrequency = 1477;
            break;
        case DGToneGeneratorDtmf4:
            self.frequency = 770;
            self.secondFrequency = 1209;
            break;
        case DGToneGeneratorDtmf5:
            self.frequency = 770;
            self.secondFrequency = 1336;
            break;
        case DGToneGeneratorDtmf6:
            self.frequency = 770;
            self.secondFrequency = 1477;
            break;
        case DGToneGeneratorDtmf7:
            self.frequency = 852;
            self.secondFrequency = 1209;
            break;
        case DGToneGeneratorDtmf8:
            self.frequency = 852;
            self.secondFrequency = 1336;
            break;
        case DGToneGeneratorDtmf9:
            self.frequency = 852;
            self.secondFrequency = 1477;
            break;
        case DGToneGeneratorDtmfStar:
            self.frequency = 941;
            self.secondFrequency = 1209;
            break;
        case DGToneGeneratorDtmfPound:
            self.frequency = 941;
            self.secondFrequency = 1477;
            break;
        case DGToneGeneratorDtmfA:
            self.frequency = 697;
            self.secondFrequency = 1633;
            break;
        case DGToneGeneratorDtmfB:
            self.frequency = 770;
            self.secondFrequency = 1633;
            break;
        case DGToneGeneratorDtmfC:
            self.frequency = 852;
            self.secondFrequency = 1633;
            break;
        case DGToneGeneratorDtmfD:
            self.frequency = 941;
            self.secondFrequency = 1633;
            break;
    }
	[self updateSine];
}

- (void)setFrequency:(double)frequency
{
	_frequency = frequency;
	[self updateSine];
}

- (void)setSecondFrequency:(double)secondFrequency
{
	_secondFrequency = secondFrequency;
	[self updateSine];
}

- (void)setSampleRate:(double)sampleRate
{
	_sampleRate = sampleRate;
	BOOL wasPlaying = self.isPlaying;
	[self stop];
	[self updateSine];
	if (toneAudioUnit)
	{ // If we were already initialized... Make sure we still are
		[self setupAudioUnit];
	}
	if (wasPlaying)
	{ // If we were playing, resume playing
		[self play];
	}
}

- (void)setPreventMute:(BOOL)preventMute
{
	_preventMute = preventMute;
	if (_manageAudioSession)
	{
		UInt32 sessionCategory = _preventMute ? kAudioSessionCategory_MediaPlayback : kAudioSessionCategory_SoloAmbientSound;
		AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	}
}

- (void)updateSine
{
    const double M_2PI = 2.0 * M_PI;
    hasSecondSine = NO;
    if (self->_frequency > 0.0 && self->_secondFrequency <= 0.0)
    {
		samplesPerSine = self->_sampleRate / self->_frequency;
		sineMultiplierPerSample = M_2PI / samplesPerSine;
		while (samplePosInSine >= samplesPerSine) samplePosInSine -= samplesPerSine;
    }
    else if (self->_secondFrequency > 0.0 && self->_frequency <= 0.0)
    {
		samplesPerSine_2nd = self->_sampleRate / self->_secondFrequency;
		sineMultiplierPerSample_2nd = M_2PI / samplesPerSine_2nd;
		while (samplePosInSine_2nd >= samplesPerSine_2nd) samplePosInSine_2nd -= samplesPerSine_2nd;
    }
    else if (self->_secondFrequency > 0.0 && self->_frequency > 0.0)
    {
        hasSecondSine = YES;
		samplesPerSine = self->_sampleRate / self->_frequency;
		sineMultiplierPerSample = M_2PI / samplesPerSine;
		samplesPerSine_2nd = self->_sampleRate / self->_secondFrequency;
		sineMultiplierPerSample_2nd = M_2PI / samplesPerSine_2nd;
		while (samplePosInSine >= samplesPerSine) samplePosInSine -= samplesPerSine;
		while (samplePosInSine_2nd >= samplesPerSine_2nd) samplePosInSine_2nd -= samplesPerSine_2nd;
    }
}

#pragma mark - AudioToolbox C helpers

void DGToneGenerator_InterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
    DGToneGenerator *self = (__bridge DGToneGenerator*)inClientData;
    [self stop];
}

OSStatus DGToneGenerator_RenderTone(
                    void *inRefCon, 
                    AudioUnitRenderActionFlags 	*ioActionFlags, 
                    const AudioTimeStamp 		*inTimeStamp, 
                    UInt32 						inBusNumber, 
                    UInt32 						inNumberFrames, 
                    AudioBufferList 			*ioData)

{
	DGToneGenerator *self = (__bridge DGToneGenerator *)inRefCon;
    
	double samplePosInSine = self->samplePosInSine;
	double samplePosInSine_2nd = self->samplePosInSine_2nd;
	double samplesPerSine = self->samplesPerSine;
	double samplesPerSine_2nd = self->samplesPerSine_2nd;
	double sineMultiplierPerSample = self->sineMultiplierPerSample;
	double sineMultiplierPerSample_2nd = self->sineMultiplierPerSample_2nd;
	double amplitude = self->_amplitude;
    BOOL hasSecondSine = self->hasSecondSine;
    
	// This is a mono tone generator so we only need the first buffer
	Float32 *buffer = (Float32 *)ioData->mBuffers[0].mData;
	
	// Generate the samples
	Float32 sample;
	for (UInt32 frame = 0; frame < inNumberFrames; frame++) 
	{
        if (hasSecondSine)
		{
			sample = (sin(sineMultiplierPerSample * samplePosInSine) + 
							  sin(sineMultiplierPerSample_2nd * samplePosInSine_2nd)) * amplitude;
			samplePosInSine_2nd++;
			while (samplePosInSine_2nd >= samplesPerSine_2nd) samplePosInSine_2nd -= samplesPerSine_2nd;
		}
        else 
		{
			sample = sin(sineMultiplierPerSample * samplePosInSine) * amplitude;
		}
		
		samplePosInSine++;
		while (samplePosInSine >= samplesPerSine) samplePosInSine -= samplesPerSine;
		
		buffer[frame] = sample;
    }
    
    self->samplePosInSine = samplePosInSine;
    self->samplePosInSine_2nd = samplePosInSine_2nd;
    
	return noErr;
}

@end
