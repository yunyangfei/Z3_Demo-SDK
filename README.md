# Z3设备SDK集成说明：
[![CocoaPods](https://img.shields.io/cocoapods/v/Z3_Demo-SDK.svg?style=flat)](https://github.com/yunyangfei/Z3_Demo-SDK)

### 1.将ZXBZ3Lib文件夹拖入工程；
### 2.在TARGETS->Build Phases->Link Binary With Libraries中添加依赖库:
### libz.tbd，libiconv.tbd，CFNetwork.framework;
### 3.传入设备的视频文件需要进行转码处理，可以用FFmpeg，语法为：
### [NSString stringWithFormat:@"ffmpeg.exe!#$-i!#$%@!#$-s!#$%.fx%.f!#$-vcodec!#$libx264!#$-profile:v!#$baseline!#$-y!#$-level!#$3.1!#$-b:v!#$128KB!#$-r!#$25!#$%@", inputPath, width, height, outpath]
### 注意：Z3,Z3S视频的宽和高最大不能超过368，且都要能被16整除，否则不能播放。(Z3H的视频大小为480)
### （Demo中的视频已经进行过转码了）


