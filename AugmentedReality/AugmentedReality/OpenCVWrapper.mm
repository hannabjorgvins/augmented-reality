
#include "OpenCVWrapper.h"

#include <opencv2/opencv.hpp>
#include <opencv2/aruco.hpp>
#include <opencv2/imgcodecs/ios.h>

#include <stdio.h>

@implementation OpenCVWrapper : NSObject

cv::Mat cameraMat;
cv::Mat distortionCoeffs;
cv::Mat objPoints;

+ (NSArray*)getTransformationMatrixBetweenObjectPointsAndImage: (UIImage*) image {
    std::cout << cameraMat << std::endl;
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
        return @[[NSNumber numberWithFloat: viewMatrix.at<float>(0, 0)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(1, 0)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(2, 0)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(3, 0)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(0, 1)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(1, 1)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(2, 1)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(3, 1)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(0, 2)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(1, 2)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(2, 2)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(3, 2)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(0, 3)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(1, 3)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(2, 3)],
                 [NSNumber numberWithFloat: viewMatrix.at<float>(3, 3)]];
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
    objPoints = createMatrixFromArray(objectPoints, 3, 4);
}

cv::Mat createMatrixFromArray(NSArray* array, int m, int n) {
    cv::Mat matrix = cv::Mat::zeros(m, n, CV_32F);
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
            matrix.at<float>(i, j) = [[array objectAtIndex: (i * n) + j] floatValue];
        }
    }
    return matrix;
}

cv::Mat solvePnPForImagePoints(std::vector<cv::Point2f> imagePoints) {
    cv::Mat rvec, tvec;
    cv::solvePnP(objPoints, imagePoints, cameraMat, distortionCoeffs, rvec, tvec);
    
    cv::Mat rotationMatrix = cv::Mat::zeros(4, 4, CV_32F);
    cv::Rodrigues(rvec, rotationMatrix);
    
    cv::Mat viewMatrix = cv::Mat::zeros(4, 4, CV_32F);
    viewMatrix.at<float>(3, 3) = 1.0;
    for (int i = 0; i < 3; ++i) {
        for (int j = 0; j < 3; ++j) {
            viewMatrix.at<float>(i, j) = rotationMatrix.at<float>(i, j);
        }
        viewMatrix.at<float>(i, 3) = tvec.at<float>(i, 0);
    }
    
    cv::Mat axisInversion = cv::Mat::zeros(4, 4, CV_32F);
    axisInversion.at<float>(0, 0) =  1.0f;
    axisInversion.at<float>(1, 1) = -1.0f;
    axisInversion.at<float>(2, 2) = -1.0f;
    axisInversion.at<float>(3, 3) =  1.0f;
    viewMatrix = axisInversion * viewMatrix;
    
    return viewMatrix;
}

@end