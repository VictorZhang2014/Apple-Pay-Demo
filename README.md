# Apple-Pay-Demo
This is a Apple Pay Demo . If you download it and run it before you must apply yourself Merchant ID.

步骤：
1.检测设备和系统是否支持Apple Pay

2.检测是否支持这几种卡的支付方式  Amex , MasterCard, Visa , 银联卡, 中国境内这几种就够用了，如果需要其他的类型，还可以进行添加

3.生成一个支付请求的对象，有merchant标识符，币种，国家码等信息

4.如果需要可以设置账单和货物的配送方式，我们给给定几种类型供用户选择

5.构建商品标签和价格，包括折扣价，最后计算需要支付的价格

6.弹出支付控制器面板，选择，并支付
  代理事件，返回成功支付等信息

