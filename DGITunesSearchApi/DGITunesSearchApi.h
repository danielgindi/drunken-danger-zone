//
//  DGITunesSearchApi.h
//  DGITunesSearchApi
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

#import <Foundation/Foundation.h>

/*! @brief The name of the object returned by the search request. 
    @return track, collection, artist*/
#define kDGITunesSearchResultKey_WrapperType @"wrapperType"

/*! @brief The Recording Industry Association of America (RIAA) parental advisory for the content returned by the search request. 
 For more information, see http://itunes.apple.com/WebObjects/MZStore.woa/wa/parentalAdvisory. 
    @return explicit (explicit lyrics, possibly explicit album cover), cleaned (explicit lyrics "bleeped out"), notExplicit (no explicit lyrics). For example: "trackExplicitness":"notExplicit" */
#define kDGITunesSearchResultKey_Explicitness @"explicitness"

/*! @brief The kind of content returned by the search request.
 @return book, album, coached-audio, feature-movie, interactive- booklet, music-video, pdf podcast, podcast-episode, software-package, song, tv- episode, artist. For example: song.*/
#define kDGITunesSearchResultKey_Kind @"kind"

/*! @brief The name of the track, song, video, TV episode, and so on returned by the search request.
 @return For example: "Banana Pancakes". */
#define kDGITunesSearchResultKey_TrackName @"trackName"

/*! @brief The name of the artist returned by the search request.
 @return For example: Jack Johnson. */
#define kDGITunesSearchResultKey_ArtistName @"artistName"

/*! @brief The name of the album, TV season, audiobook, and so on returned by the search request.
 @return For example: "In Between Dreams".*/
#define kDGITunesSearchResultKey_CollectionName @"collectionName"

/*! @brief The name of the album, TV season, audiobook, and so on returned by the search request, with objectionable words *'d out. Note: Artist names are never censored.
 @return For example: "S**t Happens". */
#define kDGITunesSearchResultKey_CensoredName @"censoredName"

/*! @brief A URL for the artwork associated with the returned media type, sized to 100x100 pixels or 60x60 pixels.	
    @return Only returned when artwork is available. For example: "http://a1.itunes.apple.com/jp/r10/Music/y2005/m06/d03/h05/s05.oazjtxkw.100x100-75.jpg". */
#define kDGITunesSearchResultKey_ArtworkUrl100 @"artworkUrl100"
#define kDGITunesSearchResultKey_ArtworkUrl60 @"artworkUrl60"

/*! @brief A URL for the content associated with the returned media type. You can click the URL to view the content in the iTunes Store.	@return For example: "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewAlbum?i=68615807&id=68615813&s=143462". */
#define kDGITunesSearchResultKey_ViewUrl @"viewURL"

/*! @brief A URL referencing the 30-second preview file for the content associated with the returned media type. 
    @return Only returned when media type is track. For example: "http://a392.itunes.apple.com/jp/r10/Music/y2005/m06/d03/h05/05.zdzqlufu.p.m4p". */
#define kDGITunesSearchResultKey_PreviewUrl @"previewUrl"

/*! @brief The returned track's time in milliseconds.
    @return Only returned when media type is track */
#define kDGITunesSearchResultKey_TrackTimeMillis @"trackTimeMillis"

/*! @return Example: 909253 */
#define kDGITunesSearchResultKey_ArtistId @"artistId"

/*! @return Example: 120954021 */
#define kDGITunesSearchResultKey_CollectionId @"collectionId"

/*! @return Example: 120954025 */
#define kDGITunesSearchResultKey_TrackId @"trackId"

/*! @return Example: "Sing-a-Longs and Lullabies for the Film Curious George" */
#define kDGITunesSearchResultKey_CollectionCensoredName @"collectionCensoredName"

/*! @return Example: "Upside Down" */
#define kDGITunesSearchResultKey_TrackCensoredName @"trackCensoredName"

/*! @return Example: "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewArtist?id=909253" */
#define kDGITunesSearchResultKey_ArtistViewUrl @"artistViewUrl"

/*! @return Example: "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewAlbum?i=120954025&id=120954021&s=143441" */
#define kDGITunesSearchResultKey_CollectionViewUrl @"collectionViewUrl"

/*! @return Example: "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewAlbum?i=120954025&id=120954021&s=143441" */
#define kDGITunesSearchResultKey_TrackViewUrl @"trackViewUrl"

/*! @return Example: 10.99 */
#define kDGITunesSearchResultKey_CollectionPrice @"collectionPrice"

/*! @return Example: 0.99 */
#define kDGITunesSearchResultKey_TrackPrice @"trackPrice"

/*! @return Example: "notExplicit" */
#define kDGITunesSearchResultKey_CollectionExplicitness @"collectionExplicitness"

/*! @return Example: "notExplicit" */
#define kDGITunesSearchResultKey_TrackExplicitness @"trackExplicitness"

/*! @return Example: 1 */
#define kDGITunesSearchResultKey_DiscCount @"discCount"

/*! @return Example: 1 */
#define kDGITunesSearchResultKey_DiscNumber @"discNumber"

/*! @return Example: 14 */
#define kDGITunesSearchResultKey_TrackCount @"trackCount"

/*! @return Example: 1 */
#define kDGITunesSearchResultKey_TrackNumber @"trackNumber"

/*! @return Example: 210743 */
#define kDGITunesSearchResultKey_TrackTimeMillis @"trackTimeMillis"

/*! @return Example: "USA" */
#define kDGITunesSearchResultKey_Country @"country"

/*! @return Example: "USD" */
#define kDGITunesSearchResultKey_Currency @"currency"

/*! @return Example: "Rock" */
#define kDGITunesSearchResultKey_PrimaryGenreName @"primaryGenreName"

typedef void (^DGITunesSearchResultBlock)(NSArray *results);
typedef void (^DGITunesSearchErrorBlock)(NSError *error);

@interface DGITunesSearchApi : NSObject

/*! @brief Executes an iTunes store search
 @param term The text string you want to search for. For example: jack johnson. Required.
 @param country The two-letter country code for the store you want to search. The search uses the default store front for the specified country. For example: US. The default is US. Required. See http://en.wikipedia.org/wiki/ ISO_3166-1_alpha-2 for a list of ISO Country Codes.
 @param media The media type you want to search for. For example: movie.
        Options are: movie, podcast, music, musicVideo, audiobook, shortFilm, tvShow, software, ebook, all
        The default is all.
 @param entity The type of results you want returned, relative to the specified media type. For example: movieArtist for a movie media type search.
     Options are:
     movie      : movieArtist, movie
     podcast    : podcastAuthor, podcast
     music      : musicArtist, musicTrack, album, musicVideo, mix, song
     musicVideo : musicArtist, musicVideo
     audiobook  : audiobookAuthor, audiobook
     shortFilm  : shortFilmArtist, shortFilm
     tvShow     : tvEpisode, tvSeason
     software   : software, iPadSoftware, macSoftware
     ebook      : ebook
     all        : movie, album, allArtist, podcast, musicVideo, mix, audiobook, tvSeason, allTrack
     The default is the track entity associated with the specified media type.
 @param attribute The attribute you want to search for in the stores, relative to the specified media type. For example, if you want to search for an artist by name specify entity=allArtist&attribute=allArtistTerm.
 
     In this example, if you search for term=maroon, iTunes returns "Maroon 5" in the search results, instead of all artists who have ever recorded a song with the word "maroon" in the title.
     Options are:
     movie      : actorTerm, genreIndex, artistTerm, shortFilmTerm, producerTerm, ratingTerm, directorTerm, releaseYearTerm, featureFilmTerm, movieArtistTerm, movieTerm, ratingIndex, descriptionTerm
     podcast    : titleTerm, languageTerm, authorTerm, genreIndex, artistTerm, ratingIndex, keywordsTerm, descriptionTerm
     music      : mixTerm, genreIndex, artistTerm, composerTerm, albumTerm, ratingIndex, songTerm
     musicVideo : genreIndex, artistTerm, albumTerm, ratingIndex, songTerm
     audiobook  : titleTerm, authorTerm, genreIndex, ratingIndex
     shortFilm  : genreIndex, artistTerm, shortFilmTerm, ratingIndex, descriptionTerm
     software   : softwareDeveloper
     tvShow     : genreIndex, tvEpisodeTerm, showTerm, tvSeasonTerm, ratingIndex, descriptionTerm
     all        : actorTerm, languageTerm, allArtistTerm, tvEpisodeTerm, shortFilmTerm, directorTerm, releaseYearTerm, titleTerm, featureFilmTerm, ratingIndex, keywordsTerm, descriptionTerm, authorTerm, genreIndex, mixTerm, allTrackTerm, artistTerm, composerTerm, tvSeasonTerm, producerTerm, ratingTerm, songTerm, movieArtistTerm, showTerm, movieTerm, albumTerm
 
        The default is all attributes associated with the specified media type.
 @param limit The number of search results you want the iTunes Store to return. For example: 25. The default is 50. (Specify 0 for the default)
 @param lang The language, English or Japanese, you want to use when returning search results. Specify the language using the five-letter codename. For example: en_us. The default is en_us (English).
 @param version The search result key version you want to receive back from your search. The current default is 2. (Specify 0 for the default)
 @param explicit A flag indicating whether or not you want to include explicit content in your search results. The default is YES.
 @param completion A completion block, called only on success, even if there are zero results
 @param error An error block, called whenever an invalid response returns, or there's a connection error
 */
+ (void)searchForTerm:(NSString *)term
            inCountry:(NSString *)country
                media:(NSString *)media
               entity:(NSString *)entity
            attribute:(NSString *)attribute
                limit:(int)limit
                 lang:(NSString *)lang
              version:(NSString *)version
             explicit:(BOOL)includeExplicit
           completion:(DGITunesSearchResultBlock)completionBlock
                error:(DGITunesSearchErrorBlock)errorBlock;

@end
