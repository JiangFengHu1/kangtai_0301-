//
//
/**
 * Copyright (c) www.bugull.com
 */
//
//

#import <Foundation/Foundation.h>
#import "SocketOperation.h"
//需要自行判断是否连上外网
#define RemoteServiceInstance [RemoteService sharedInstance]

@protocol RemoteDelegate <NSObject>

- (void)remoteConnectFinished:(BOOL)succeed key:(NSData *)key;

- (void)remoteDisconnected:(NSString *)msg;

- (void)remoteDidConnectDevice:(Device *)device;

@end

@interface RemoteService : NSObject

+ (RemoteService *)sharedInstance;


//- (void)startHeartBeat:(NSString *)type;
//UDP链接
- (BOOL)connect;
//链接设备
- (void)connectDevices;
//
- (void)connectDevice:(Device *)device;
//断开链接
- (void)disconnect;
//是否断开
- (BOOL)isConnected;

//判断设备是否离线
- (BOOL)isConnectedDevice:(Device *)device;
//刷新设备状态
- (void)refreshConnectStatus:(Device *)device;
//移除设备
- (void)removeDevice:(Device *)device;

//发送数据方法
- (SocketOperation *)sendProtocol:(NSData *)protocol complete:(Complete)complete;
#pragma mark-

#pragma mark-0x01 GPIO
- (void)setGPIOCloseOrOpenWithDeciceMac:(NSData *)data index:(BOOL)indx deviceType:(NSString *)type;
#pragma mark-

- (void)queryGPIOEventToMac:(NSData *)mac deviceType:(NSString *)type;

#pragma mark-0x03 GPIO
- (void)setGPIOaleamWithDeciceMac:(NSData *)mac index:(BOOL)indx socketType:(BOOL)type  flag:(UInt8)flag Hour:(UInt8)hour min:(UInt8)min numberTaks:(UInt8)task key:(NSData *)key deviceType:(NSString *)Type;

#pragma mark-

#pragma mark-0x04 GPIO

- (void)getGPIOTimerInfoDeviceMac:(NSData *)mac deviceType:(NSString *)type;

#pragma mark-

#pragma mark-0x0D 433

- (void)set433CloseOrOpenWithDeciceMac:(NSData *)data index:(BOOL)indx adderss:(NSData *)adders type:(NSString *)type timerDic:(NSDictionary *)dic;

#pragma mark-

#pragma mark-0x05 GPIO
- (void)deleteGPIOTimerDeviceMac:(NSData *)mac Num:(UInt8)number deviceType:(NSString *)type;




#pragma mark-
#pragma mark-0x62

- (void)getDeviceInfoToMac:(NSData *)mac deviceType:(NSString *)type;

#pragma mark-
#pragma mark-0x65


- (void)firmwareUpgradeToMac:(NSData *)mac WithUrlLen:(UInt8)len WithUrl:(NSData *)urlData key:(NSData *)key deviceType:(NSString *)type;

#pragma mark-
#pragma mark-0x83 U口
-(void)subscribetoeventsWith:(BOOL)isOpen WithMac:(NSData *)mac with:(UInt8)cmd deviceType:(NSString *)type;

#pragma mark-
#pragma mark-0x84 U口上线离线
- (void)queryEquipmentOnlineWithMac:(NSData *)mac deviceType:(NSString *)type;
//#pragma mark-
//#pragma mark-0x85 U口
//- (void)deviceOnlineWithmac:(NSData *)mac Withopen:(BOOL)isopen;

#pragma mark-
#pragma mark-0x86 U口

- (void)getFirwareVersionNumberMAC:(NSData *)mac deviceType:(NSString *)type;

#pragma mark-0x09 防盗
- (void)setAbseceWithDeciceMac:(NSData *)data index:(BOOL)indx FromStateData:(NSData *)from ToData:(NSData *)ToData key:(NSData *)key deviceType:(NSString *)type;


#pragma mark-0x0A 防盗查询
- (void)getQueryTheftModeDeciceremoteMac:(NSData *)data key:(NSData *)key deviceType:(NSString *)type;

#pragma mark-0x08 设置定时
- (void)setGPIOCountdownWithDeciceMac:(NSData *)mac index:(BOOL)indx socketType:(BOOL)type  flag:(UInt8)flag Hour:(UInt8)hour min:(UInt8)min numberTaks:(UInt8)task key:(NSData *)key deviceType:(NSString *)Type;
#pragma mark-0x09 查询倒计时
- (void)getGPIOCountdownDeviceMac:(NSData *)mac deviceType:(NSString *)type orderType:(NSString *)order;

#pragma mark - 0x0B 电量查询
- (void)getQueryDeviceWattInfoWithRemoteMac:(NSData *)data key:(NSData *)key;

- (void)getTCPstate;
- (void)seceedTCPToserver;
@end
