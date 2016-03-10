//
//  ViewController.swift
//  Apple_Pay_Demo(Swift)
//
//  Created by 张强 on 3/10/16.
//  Copyright © 2016 com.xiaoruigege. All rights reserved.
//

import UIKit
import PassKit
import AddressBookUI

class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    
    var supportNetworks: [String]?
    
    @IBAction func buyWithApplePay(sender: AnyObject) {
        //1.检测设备是否支持支付
        if(!PKPaymentAuthorizationViewController.canMakePayments()){
            let alertView = UIAlertView(title: "提示", message: "本设备或者系统不支持Apple Pay!", delegate: nil, cancelButtonTitle: "ok")
            alertView.show()
            return;
        }
        
        //2.检测手机钱包有没有添加支付卡片
        var supportNetworks = [PKPaymentNetworkAmex]
        supportNetworks.append(PKPaymentNetworkMasterCard)
        supportNetworks.append(PKPaymentNetworkVisa)
        if #available(iOS 9.2, *) {
            supportNetworks.append(PKPaymentNetworkChinaUnionPay)
        } else {
            
        }
        self.supportNetworks = supportNetworks
        if(!PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(supportNetworks)){
            let alert = UIAlertView(title: "提示", message: "请在手机上的钱包添加卡片，在来支持", delegate: nil, cancelButtonTitle: "okay")
            alert.show()
            return ;
        }
        
        
        //3.添加支付请求
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.xiaoruigege.applepaydemo"
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.currencyCode = "CNY"
        request.countryCode = "CN"
        request.supportedNetworks = self.supportNetworks!
        
        
        //4.支付 条目
        let item1_price = 9.2
        let dprice = NSDecimalNumber(string: String(item1_price))
        let item1 = PKPaymentSummaryItem(label: "韩版小西服", amount: dprice)
        
        let coupon_price = -8.9
        let dprice2 = NSDecimalNumber(string: String(coupon_price))
        let item2 = PKPaymentSummaryItem(label: "优惠折扣价", amount: dprice2)
        
        //总价
        var totalPrice = NSDecimalNumber.zero()
        totalPrice = totalPrice.decimalNumberByAdding(dprice)
        totalPrice = totalPrice.decimalNumberByAdding(dprice2)
        let item3 = PKPaymentSummaryItem(label: "小睿阁阁工作室", amount: totalPrice)
        
        request.paymentSummaryItems = [item1, item2, item3]
        
        
        
        //5.显示支付信息
        let controller = PKPaymentAuthorizationViewController(paymentRequest: request)
        controller.delegate = self
        presentViewController(controller, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //支付成功回调
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        
        dispatch_after(3, dispatch_get_main_queue()) { () -> Void in
             completion(.Success)
        }
    }
    
    //支付成功完成，并回调，移除控制器
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    
    
}

