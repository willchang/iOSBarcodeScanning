//
//  RootViewController.m
//  BarcodeScannerTest
//
//  Created by William Chang on 2014-09-04.
//  Copyright (c) 2014 William Chang. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController()
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UILabel *captureLabel;
@property (nonatomic, strong) UIView *highlightView;
@end

@implementation RootViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"iOS Barcode Scanning";
	
	self.session = [[AVCaptureSession alloc] init];
	
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	NSError *error = nil;
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (deviceInput && error == nil) {
		[self.session addInput:deviceInput];
	} else {
		NSLog(@"Failed to create device input.");
	}
	
	self.output = [[AVCaptureMetadataOutput alloc] init];
	[self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
	[self.session addOutput:self.output];
	self.output.metadataObjectTypes = [self.output availableMetadataObjectTypes];
	
	self.previewView = [[UIView alloc] init];
	self.previewView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:self.previewView];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewView
														  attribute:NSLayoutAttributeWidth
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeWidth
														 multiplier:0.8
														   constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewView
														  attribute:NSLayoutAttributeHeight
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeWidth
														 multiplier:0.8
														   constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewView
														  attribute:NSLayoutAttributeCenterX
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeCenterX
														 multiplier:1.0
														   constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewView
														  attribute:NSLayoutAttributeCenterY
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeCenterY
														 multiplier:1.0
														   constant:0.0]];
	
	self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
	self.previewLayer.frame = self.previewView.bounds;
	self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.previewView.layer addSublayer:self.previewLayer];
	
	self.captureLabel = [[UILabel alloc] init];
	self.captureLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.captureLabel.textAlignment = NSTextAlignmentCenter;
	[self.view addSubview:self.captureLabel];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureLabel
														  attribute:NSLayoutAttributeCenterX
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
														  attribute:NSLayoutAttributeCenterX
														 multiplier:1.0
														   constant:0.0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.captureLabel
														  attribute:NSLayoutAttributeTop
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.previewView
														  attribute:NSLayoutAttributeBottom
														 multiplier:1.0
														   constant:8.0]];
	
	[self.session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
	NSMutableString *string = [NSMutableString string];
	
	CGRect lastBounds = CGRectZero;
	AVMetadataObject *lastObject = nil;
	
	for (AVMetadataObject *object in metadataObjects) {
		[string appendFormat:@"%@\n", object.type];
		
		if ([object isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
			lastObject = [self.previewLayer transformedMetadataObjectForMetadataObject:object];
		}
		lastBounds = object.bounds;
	}
	
	self.captureLabel.text = string;
	
	if (self.highlightView == nil) {
		self.highlightView = [[UIView alloc] init];
		self.highlightView.backgroundColor = [UIColor clearColor];
		self.highlightView.layer.borderColor = [[UIColor greenColor] CGColor];
		self.highlightView.layer.borderWidth = 1.0f;
		[self.previewView addSubview:self.highlightView];
	}
	
	self.highlightView.hidden = ([metadataObjects count] == 0);
	self.highlightView.frame = lastObject.bounds;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	self.previewLayer.frame = self.previewView.bounds;
}

@end
