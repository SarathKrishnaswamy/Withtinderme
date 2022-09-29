//
//  PaymentViewController.swift
//  Spark me
//
//  Created by Sarath Krishnaswamy on 06/07/22.
//

//import UIKit
//import Razorpay
//
//class PaymentViewController: UIViewController, RazorpayPaymentCompletionProtocol {
//
//
//
//    // typealias Razorpay = RazorpayCheckout
//
//    var razorpay: RazorpayCheckout!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.showPaymentForm()
//    }
//
//
//    func onPaymentError(_ code: Int32, description str: String) {
//        print(str)
//    }
//
//    func onPaymentSuccess(_ payment_id: String) {
//        print(payment_id)
//    }
//
//
//    internal func showPaymentForm(){
//        let options: [String:Any] = [
//                    "amount": "100", //This is in currency subunits. 100 = 100 paise= INR 1.
//                    "currency": "INR",//We support more that 92 international currencies.
//                    "description": "purchase description",
//                    "order_id": "order_DBJOWzybf0sJbb",
//                    "image": "https://url-to-image.png",
//                    "name": "business or product name",
//                    "prefill": [
//                        "contact": "9797979797",
//                        "email": "foo@bar.com"
//                    ],
//                    "theme": [
//                        "color": "#F37254"
//                    ]
//                ]
//        razorpay.open(options)
//    }
//}
