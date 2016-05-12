
#include "OpenCVWrapper.h"

#include <opencv2/opencv.hpp>
#include <opencv2/aruco.hpp>
#include <opencv2/imgcodecs/ios.h>

#include <stdio.h>
#include <math.h>

@implementation OpenCVWrapper : NSObject

cv::Mat cameraMat;
cv::Mat distortionCoeffs;
std::vector<cv::Point3f> objPoints;

+ (NSArray*)getTransformationMatrixBetweenObjectPointsAndImage: (UIImage*) image {
    cv::Mat imgWithAlpha;
    UIImageToMat(image, imgWithAlpha);
    
    cv::Mat img;
    cv::cvtColor(imgWithAlpha, img, CV_BGRA2BGR);
    
    std::vector< int > markerIds;
    std::vector< std::vector<cv::Point2f> > markerCorners, rejectedCandidates;
    cv::aruco::DetectorParameters parameters;
    cv::aruco::Dictionary dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_ARUCO_ORIGINAL);
    cv::aruco::detectMarkers(img, dictionary, markerCorners, markerIds, parameters, rejectedCandidates);
    
    if (!markerCorners.empty()) {
        cv::Mat viewMatrix = solvePnPForImagePoints(markerCorners[0]);
        return @[[NSNumber numberWithFloat: viewMatrix.at<double>(0, 0)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(1, 0)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(2, 0)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(3, 0)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(0, 1)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(1, 1)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(2, 1)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(3, 1)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(0, 2)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(1, 2)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(2, 2)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(3, 2)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(0, 3)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(1, 3)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(2, 3)],
                 [NSNumber numberWithFloat: viewMatrix.at<double>(3, 3)]];
    }
    
    return @[];
}

+ (void)setCameraMatrix: (NSArray*) cameraMatrix {
    cameraMat = createMatrixFromArray(cameraMatrix, 3, 3);
}

+ (void)setDistortionCoefficients: (NSArray*) distortionCoefficients {
    distortionCoeffs = createMatrixFromArray(distortionCoefficients, 1, 5);
}

+ (void)setObjectPoints: (NSArray*) objectPoints {
    objPoints.push_back(cv::Point3f([[objectPoints objectAtIndex: 0] doubleValue],
                                    [[objectPoints objectAtIndex: 4] doubleValue],
                                    [[objectPoints objectAtIndex: 8] doubleValue]));
    objPoints.push_back(cv::Point3f([[objectPoints objectAtIndex: 1] doubleValue],
                                    [[objectPoints objectAtIndex: 5] doubleValue],
                                    [[objectPoints objectAtIndex: 9] doubleValue]));
    objPoints.push_back(cv::Point3f([[objectPoints objectAtIndex: 2] doubleValue],
                                    [[objectPoints objectAtIndex: 6] doubleValue],
                                    [[objectPoints objectAtIndex: 10] doubleValue]));
    objPoints.push_back(cv::Point3f([[objectPoints objectAtIndex: 3] doubleValue],
                                    [[objectPoints objectAtIndex: 7] doubleValue],
                                    [[objectPoints objectAtIndex: 11] doubleValue]));
}

cv::Mat createMatrixFromArray(NSArray* array, int m, int n) {
    cv::Mat matrix = cv::Mat::zeros(m, n, CV_64F);
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
            matrix.at<double>(i, j) = [[array objectAtIndex: (i * n) + j] doubleValue];
        }
    }
    return matrix;
}

cv::Mat solvePnPForImagePoints(std::vector<cv::Point2f> imagePoints) {
    cv::Mat rvec, tvec;
    cv::solvePnP(objPoints, imagePoints, cameraMat, distortionCoeffs, rvec, tvec);
    
    cv::Mat rotationMatrix;
    cv::Rodrigues(rvec, rotationMatrix);
    
    rotationMatrix = rotationMatrix.t();
    tvec = -rotationMatrix * tvec;
    
    cv::Mat transformationMatrix = cv::Mat::zeros(4, 4, CV_64F);
    transformationMatrix.at<double>(3, 3) = 1.0;
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            transformationMatrix.at<double>(i, j) = rotationMatrix.at<double>(i, j);
        }
        transformationMatrix.at<double>(i, 3) = tvec.at<double>(i, 0);
    }
    
    cv::Mat axisInversion = cv::Mat::zeros(4, 4, CV_64F);
    axisInversion.at<double>(0, 0) =  1.0f;
    axisInversion.at<double>(1, 1) = -1.0f;
    axisInversion.at<double>(2, 2) = -1.0f;
    axisInversion.at<double>(3, 3) =  1.0f;
    transformationMatrix = transformationMatrix * axisInversion;
    
    return transformationMatrix;
}

@end