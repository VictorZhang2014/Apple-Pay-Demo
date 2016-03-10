//
//  ViewController.m
//  Apple Pay Demo
//
//  Created by Victor on 3/7/16.
//  Copyright © 2016 com.xiaoruigege. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>       //用户绑定银行卡的信息
#import <PassKit/PKPaymentAuthorizationViewController.h>       //Apple Pay的展示控件
#import <AddressBook/AddressBook.h>          //用户联系信息相关


@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate,UIWebViewDelegate>

/** 所支持的卡片类型 **/
@property (nonatomic, strong) NSArray *supportNetworks;

/** 消费的项目 **/
//@property (nonatomic, strong) NSMutableArray *summaryItems;


- (IBAction)buttonApplyPay:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)buttonApplyPay:(id)sender
{
    //检测是否支持Apple Pay
    if([self checkVersion]){
        [self transacRequest]; 
    }
}


//检测是否支持Apple Pay
- (BOOL)checkVersion
{
    if(![PKPaymentAuthorizationViewController class] || ![PKPaymentAuthorizationViewController canMakePayments]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"Apple Pay仅支持iPhone6以上的设备，和iOS9.0以上的系统。" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OKay", nil];
        [alert show];
        return NO;
    }
    

    
    //检查用户是否可进行某种卡的支付，是否支持Amex(美国证券交易所)、MasterCard、Visa与银联四种卡，根据自己项目的需要进行检测
    NSArray *supportNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, PKPaymentNetworkChinaUnionPay];
    _supportNetworks = supportNetworks;
    
#warning 当真机调试时   如果这里canMakePaymentsUsingNetworks不能通过，表示手机的钱包（wallet）还没有开通，开通后，添加一张卡，就可以使用
    if(![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:supportNetworks]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有绑定任何支付的卡片，请绑定卡片！" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OKay", nil];
        [alert show];
        return NO;
    }
    
    return YES;
}

- (void)transacRequest
{
    //1.初始化PKPaymentRequest
    //设置币种、国家码及merchant标识符等基本信息
    PKPaymentRequest *payRequest = [[PKPaymentRequest alloc] init];
    payRequest.countryCode = @"CN";                                 //国家代码
    payRequest.currencyCode = @"CNY";                               //RMB的币种代码
    payRequest.merchantIdentifier = @"merchant.com.xiaoruigege.applepaydemo";  //申请的merchantID
    payRequest.supportedNetworks = _supportNetworks;                //用户可进行支付的银行卡
    
    //设置支持的交易处理协议，3DS必须支持，EMV为可选，目前国内的话还是使用两者吧
    payRequest.merchantCapabilities = PKMerchantCapability3DS|PKMerchantCapabilityEMV;
 
    //2.设置发票配送信息和货物配送地址信息,用户设置后可以通过代理回调代理获取信息的更新
    
    //    payRequest.requiredBillingAddressFields = PKAddressFieldEmail;
    //如果需要邮寄账单可以选择进行设置，默认PKAddressFieldNone(不邮寄账单)
    //楼主感觉账单邮寄地址可以事先让用户选择是否需要，否则会增加客户的输入麻烦度，体验不好，
//    payRequest.requiredShippingAddressFields = PKAddressFieldPostalAddress|PKAddressFieldPhone|PKAddressFieldName;
     //送货地址信息，这里设置需要地址和联系方式和姓名，如果需要进行设置，默认PKAddressFieldNone(没有送货地址)
    
    
    
    
    //3.设置货物的配送方式，不需要不配置
    //设置两种配送方式
//    PKShippingMethod *freeShipping = [PKShippingMethod summaryItemWithLabel:@"包邮" amount:[NSDecimalNumber zero]];
//    freeShipping.identifier = @"freeshipping";
//    freeShipping.detail = @"6-8 天 送达";
    
    //每条账单的设置
    //账单列表使用PKPaymentSummaryItem添加描述和价格，价格使用NSDecimalNumber。
    //PKPaymentSummaryItem初始化：
    //label为商品名字或者是描述，amount为商品价格，折扣为负数，type为该条账单为最终价格还是估算价格(比如出租车价格预估)
//    PKShippingMethod *expressShipping = [PKShippingMethod summaryItemWithLabel:@"极速送达" amount:[NSDecimalNumber decimalNumberWithString:@"10.00"]];
//    expressShipping.identifier = @"expressshipping";
//    expressShipping.detail = @"2-3 小时 送达";
//    
//    payRequest.shippingMethods = @[freeShipping, expressShipping];
//    
    
    
    
    //4.购买的商品   详细条目，及总价     就是模拟一个购物商品
    //总价格
    
    //幂运算
    //10^-2 等于 0.01
    //10^2 = 100  表示10的2次方 即10 * 10 = 100
    //1275 x  10^-2 = 12.75
    NSDecimalNumber *subtotalAmount = [NSDecimalNumber decimalNumberWithMantissa:1275 exponent:-2 isNegative:NO];   //总价格 12.75
    //总价格标签
    PKPaymentSummaryItem *subtotal = [PKPaymentSummaryItem summaryItemWithLabel:@"商品价格" amount:subtotalAmount];
    
    //优惠折扣价
    NSDecimalNumber *discountAmount = [NSDecimalNumber decimalNumberWithString:@"-12.74"];      //优惠价格 -12.74
    //优惠折扣价标签
    PKPaymentSummaryItem *discount = [PKPaymentSummaryItem summaryItemWithLabel:@"优惠折扣" amount:discountAmount];
    
    //包邮价格
    NSDecimalNumber *methodsAmount = [NSDecimalNumber zero];
    //包邮价格标签
    PKPaymentSummaryItem *methods = [PKPaymentSummaryItem summaryItemWithLabel:@"包邮" amount:methodsAmount];
    
    //计算需要支付的价格
    NSDecimalNumber *totalAmount = [NSDecimalNumber zero];
    totalAmount = [totalAmount decimalNumberByAdding:subtotalAmount];
    totalAmount = [totalAmount decimalNumberByAdding:discountAmount];
    totalAmount = [totalAmount decimalNumberByAdding:methodsAmount];
    
    //最后这个是支付给谁。哈哈，快支付给我
#warning 这里的名称只是显示给用户看，钱是付给谁的
    PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"小睿阁阁工作室" amount:totalAmount];
    
    NSMutableArray *summaryItems = [NSMutableArray arrayWithArray:@[subtotal, discount, methods, total]];
    
    //summaryItems为账单列表，类型是 NSMutableArray，这里设置成成员变量，在后续的代理回调中可以进行支付金额的调整。
    payRequest.paymentSummaryItems = summaryItems;
 
    
    
    
    
    //5.显示购物信息并进行支付
    //ApplePay控件
    PKPaymentAuthorizationViewController *view = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:payRequest];
    view.delegate = self;
    [self presentViewController:view animated:YES completion:nil];
}


#pragma mark - PKPaymentAuthorizationViewControllerDelegate
//
///* 送货地址回调 */
//- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
//                 didSelectShippingContact:(PKContact *)contact
//                               completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKShippingMethod *> *shippingMethods, NSArray<PKPaymentSummaryItem *> *summaryItems))completion{
//    //contact送货地址信息，PKContact类型
//    //送货信息选择回调，如果需要根据送货地址调整送货方式，比如普通地区包邮+极速配送，偏远地区只有付费普通配送，进行支付金额重新计算，可以实现该代理，返回给系统：shippingMethods配送方式，summaryItems账单列表，如果不支持该送货信息返回想要的PKPaymentAuthorizationStatus
////    completion(PKPaymentAuthorizationStatusSuccess, shippingMethods, summaryItems);
//}
//
///* 送货方式回调 */
//- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
//                  didSelectShippingMethod:(PKShippingMethod *)shippingMethod
//                               completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion{
//    //配送方式回调，如果需要根据不同的送货方式进行支付金额的调整，比如包邮和付费加速配送，可以实现该代理
//    PKShippingMethod *oldShippingMethod = [_summaryItems objectAtIndex:2];
//    PKPaymentSummaryItem *total = [_summaryItems lastObject];
//    total.amount = [total.amount decimalNumberBySubtracting:oldShippingMethod.amount];
//    
////    total.amount = [total.amount decimalNumberByAdding:shippingMethod.amount];
//    
//    [_summaryItems replaceObjectAtIndex:2 withObject:shippingMethod];
//    [_summaryItems replaceObjectAtIndex:3 withObject:total];
//    
//    completion(PKPaymentAuthorizationStatusSuccess, _summaryItems);
//}

/* 支付卡选择回调 */
//- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod completion:(void (^)(NSArray<PKPaymentSummaryItem *> * _Nonnull))completion {
////    //支付银行卡回调，如果需要根据不同的银行调整付费金额，可以实现该代理
//    completion(summaryItems);
//}

/* 付款成功苹果服务器返回信息回调，做服务器验证 */
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                      didAuthorizePayment:(PKPayment *)payment
                               completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    
    //支付凭据，发给服务端进行验证支付是否真实有效
    PKPaymentToken *payToken = payment.token;
    NSLog(@"%@",payToken);
    
    
    
//    PKContact *billingContact = payment.billingContact;     //账单信息
//    PKContact *shippingContact = payment.shippingContact;   //送货信息
//    PKContact *shippingMethod = payment.shippingMethod;     //送货方式
    
    //等待服务器返回结果后再进行系统block调用
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //模拟服务器通信
        completion(PKPaymentAuthorizationStatusSuccess);
    });
}

/* 支付完成回调 移除支付界面 */
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}
 

@end












