//
//  ViewController.m
//  Day03-Map
//
//  Created by 千锋 on 16/3/19.
//  Copyright © 2016年 千锋. All rights reserved.
//

//mapkit 地图工具
//前缀解决命名冲突 MJ
//协议表角色 协议表能力 协议表约定
#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "CLLocation+Sino.h"

//匿名类别 没名字 私有的
@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>

@end

@implementation ViewController{
    //地图视图
    MKMapView *_mapView;
    CLLocationManager *_locationManager;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CLGeocoder *coder=[[CLGeocoder alloc]init];
    
    
    
   // 正向编码.
    [coder geocodeAddressString:@"武侯祠" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        for (CLPlacemark *pMark in placemarks) {
            NSLog(@"%@",pMark.name);
            NSLog(@"%@",pMark.location);
        }
        
    }];
    
    CLLocation *location=[[CLLocation alloc]initWithLatitude:33.333213 longitude:105.888230];
    //地理信息反向编码(经纬度->地名)
    [coder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        for (CLPlacemark *pmark in placemarks) {
            NSLog(@"%@",pmark.name);
        }
        
    }];
    
    _locationManager=[[CLLocationManager alloc]init];
    
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    _locationManager.distanceFilter=10;
    
    _locationManager.delegate=self;
    
    
    
    //请求用户对定位服务进行授权
    [_locationManager requestAlwaysAuthorization];
    
    //启动定位服务
    [_locationManager startUpdatingLocation];
   
    
    _mapView=[[MKMapView alloc]initWithFrame:self.view.bounds];
    //定义表示经纬度的结构体变量
    CLLocationCoordinate2D c2d=CLLocationCoordinate2DMake(30.6622221, 104.041367);
    //定义表示跨度的结构体变量(地图上1度约111km)
    
    MKCoordinateSpan span=MKCoordinateSpanMake(0.01, 0.01);
    
    //设置地图的显示区域
    [_mapView setRegion:MKCoordinateRegionMake(c2d,span) animated:YES];
    //设置地图上用户位置
    _mapView.showsUserLocation=YES;
    //设置地图类型 (标准、卫星、混合)
   // _mapView.mapType=MKMapTypeHybrid;
    //绑定委托
    _mapView.delegate=self;
    
    [self.view addSubview:_mapView];
    //在地图上添加长按手势识别器
    UILongPressGestureRecognizer *press=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(doLongPress:)];
    [_mapView addGestureRecognizer:press];
    
    
    
}
//检测到长按手势的回调方法
-(void)doLongPress:(UILongPressGestureRecognizer *)press{
   
    if (press.state==UIGestureRecognizerStateBegan) {
        CGPoint screenPoint=[press locationInView:_mapView];
        //将屏幕坐标转换成经纬度坐标
        CLLocationCoordinate2D c2d=[_mapView convertPoint:screenPoint toCoordinateFromView:_mapView];
        
        // sender
        //创建大头针的数据模型
        MKPointAnnotation *pinModel=[[MKPointAnnotation alloc]init];
        pinModel.coordinate=c2d;
        
        pinModel.title=@"大头";
        pinModel.subtitle=@"小头";
        
        //将模型添加到地图视图上
        [_mapView addAnnotation:pinModel];
    }
  
    
}


//定制大头针视图的方法
//有复用机制已经写好
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView *pinView=(id)[mapView dequeueReusableAnnotationViewWithIdentifier:@"PIN"];
        if (!pinView) {
            pinView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"PIN"];
            
        }
        //定制大头针视图
        pinView.animatesDrop=YES;
        
        //气泡提示
        pinView.canShowCallout=YES;
        
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.image=[UIImage imageNamed:@"QQ20160225-1"];
        imageView.layer.masksToBounds=YES;
        imageView.layer.cornerRadius=20;
        //气泡提示左侧附加视图
        
        pinView.leftCalloutAccessoryView=imageView;
        
        
        return pinView;
    }
    return nil;
  
}



- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    CLLocation *location=[locations firstObject];
    
    //定义表示跨度的结构体变量(地图上1度约111km)
    
    //由于苹果原生地图在国内使用的是高德地图数据火星坐标
    //GPS全球坐标
    //由此需要将地球坐标转换成火星坐标才能实现正确定位
    //将地球坐标转换成火星坐标
    location=[location locationMarsFromEarth];
    
    MKCoordinateSpan span=MKCoordinateSpanMake(0.01, 0.01);
    
    //设置地图的显示区域
    [_mapView setRegion:MKCoordinateRegionMake(location.coordinate,span) animated:YES];
    
    
}

- (IBAction)MapTypeChanged:(UISegmentedControl *)sender {
    _mapView.mapType=sender.selectedSegmentIndex;
}

@end
