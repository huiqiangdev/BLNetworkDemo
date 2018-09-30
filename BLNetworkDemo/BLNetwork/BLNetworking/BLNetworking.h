//
//  BLNetworking.h
//  BLFast
//
//  Created by lightning on 2018/6/27.
//  Copyright © 2018年 lightning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLNetwork.h"
@interface BLNetworking : NSObject

/**
 网络请求基础类
 */
@property (nonatomic, strong, readonly) BLNetwork *network;

/**
 当前正在执行的任务组
 */
@property (nonatomic, strong, readonly) NSArray *currentRunTasks;


/**
 当前调用的类  做暂时Hud用
 */
@property (nonatomic, weak) UIViewController *viewController;

+ (instancetype)defaultNetwork;


/**
 Get请求

 @param apiName api名称
 @param parameters 参数
 @param responseBlock 成功回调
 @param failureBlck 失败
 @return 当前任务
 */
- (NSURLSessionDataTask *)GETRequestWithApiName:(NSString *)apiName
                                     parameters:(id)parameters
                                  responesBlock:(void(^)(id response))responseBlock
                                   failuerBlcok:(void(^)(NSError *error))failureBlck;


/**
 Post请求

 @param apiName 链接
 @param parameters 参数
 @param responseBlock 成功回调
 @param failureBlck 失败
 @return 任务
 */
- (NSURLSessionDataTask *)POSTRequestWithApiName:(NSString *)apiName
                                      parameters:(id)parameters
                                   responesBlock:(void(^)(id response))responseBlock
                                    failuerBlcok:(void(^)(NSError *error))failureBlck;
/**
 Get  Http请求 供前端和客户端公用
 
 @param apiName api名称
 @param parameters 参数
 @param responseBlock 成功回调
 @param failureBlck 失败
 @return 当前任务
 */
- (NSURLSessionDataTask *)GETHttpRequestWithApiName:(NSString *)apiName
                                     parameters:(id)parameters
                                  responesBlock:(void(^)(id response))responseBlock
                                   failuerBlcok:(void(^)(NSError *error))failureBlck;


/**
 Post Http请求 供前端和客户端公用
 
 @param apiName 链接
 @param parameters 参数
 @param responseBlock 成功回调
 @param failureBlck 失败
 @return 任务
 */
- (NSURLSessionDataTask *)POSTHttpRequestWithApiName:(NSString *)apiName
                                      parameters:(id)parameters
                                   responesBlock:(void(^)(id response))responseBlock
                                    failuerBlcok:(void(^)(NSError *error))failureBlck;

/**
 Get 发送其他链接的URL 非变啦URl
 
 @param url url地址
 @param parameters 参数
 @param responseBlock 成功回调
 @param failureBlck 失败
 @return 当前任务
 */
- (NSURLSessionDataTask *)GETOtherRequestWithUrl:(NSString *)url
                                         parameters:(id)parameters
                                      responesBlock:(void(^)(id response))responseBlock
                                       failuerBlcok:(void(^)(NSError *error))failureBlck;

/**
 POST发送其他链接的URL 非变啦URl

 @param url url地址
 @param parameters 参数
 @param responseBlock 成功回到
 @param failureBlck 失败回调
 @return 任务
 */
- (NSURLSessionDataTask *)POSTOtherRequestWithUrl:(NSString *)url
                                          parameters:(id)parameters
                                       responesBlock:(void(^)(id response))responseBlock
                                        failuerBlcok:(void(^)(NSError *error))failureBlck;



/**
 图片上传

 @param image 图片、或者是图片data
 @param apiName api地址
 @param keyName 服务器处理文件的字段
 @param progressBlock 进度回调
 @param responseBlock 成功回调
 @param failureBlck 失败回调
 @return 任务
 */
- (NSURLSessionDataTask *)uploadImageWithImage:(id)image
                                       apiName:(NSString *)apiName
                                       keyName:(NSString *)keyName
                                      progress:(void(^)(NSProgress *progress))progressBlock
                                 responesBlock:(void(^)(id response))responseBlock
                                  failuerBlcok:(void(^)(NSError *error))failureBlck;

/**
 @param file 文件数据 NSData类型
 @param fileSuffix 文件后缀,必须指定
 */

/**
 上传文件

 @param apiName api地址
 @param file 文件数据流
 @param parameters 参数
 @param name  服务器处理字段
 @param fileSuffix 文件后缀
 @param mimeType 数据类型
 @param progressBlock 进度
 @param responseBlock 成功回调
 @param failureBlck 失败回到
 @return 当前任务
 */
- (NSURLSessionDataTask *)uploadFileWithApiName:(NSString *)apiName
                                           file:(NSData *)file
                                     parameters:(id)parameters
                                           name:(NSString *)name
                                     fileSuffix:(NSString *)fileSuffix
                                       mimeType:(NSString *)mimeType
                                       progress:(void(^)(NSProgress *progress))progressBlock
                                  responesBlock:(void(^)(id response))responseBlock
                                   failuerBlcok:(void(^)(NSError *error))failureBlck;


/**
 下载

 @param apiName api地址
 @param destination 下载地址
 @param progressBlock 进度回调
 @param completionBlock 完成回调
 */
- (void)downloadWithApiName:(NSString *)apiName
                destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                   progress:(void (^)(NSProgress *downloadProgress))progressBlock
          completionHandler:(void(^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionBlock;


/**
 组任务

 @param configurations 构建任务数组
 @param notify 完成回调的block
 */
- (void)groupTaskWithConfiguration:(NSArray <BLGroupTaskConfiguration *> *)configurations
                       groupNotify:(void(^)(void))notify;
/**
 取消所有操作
 */
- (void)cancelAllCurrentRunTask;
@end
