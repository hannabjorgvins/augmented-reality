#ifndef OPENCV_H
#define OPENCV_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

+ (NSArray*)getTransformationMatrixBetweenObjectPointsAndImage: (UIImage*) image;

+ (void)setCameraMatrix: (NSArray*) cameraMatrix;

+ (void)setDistortionCoefficients: (NSArray*) distortionCoefficients;

+ (void)setObjectPoints: (NSArray*) objectPoints;

@end

#endif // OPENCV_H
