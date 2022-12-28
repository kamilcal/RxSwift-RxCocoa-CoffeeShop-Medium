//
//  LoginViewController.swift
//  CoffeeShop
//
//  Created by Göktuğ Gümüş on 23.09.2018.
//  Copyright © 2018 Göktuğ Gümüş. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let throttleInterval = 0.1
            // Bu kod sayesinde her bir input geldikten sonra 0.1sn boyunca başka bir input gelmesini bekliyor.Bu da uygulamamızın hızlı input girişlerinde gereksiz kod çalıştırmasını ve bundan dolayı oluşabilecek kitlenmeleri önlüyor.
    
    private func validateEmail(with email: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@([A-Za-z0-9.-]{2,64})+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        
        return predicate.evaluate(with: email)
    }
    
    
  @IBOutlet private weak var emailTextfield: UITextField!
  @IBOutlet private weak var passwordTextfield: UITextField!
  @IBOutlet private weak var logInButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
      let emailValid = emailTextfield
          .rx
          .text
                    //UITextField’in text değişkenine Observable bir değişken olarak ulaşabiliyoruz.
          .orEmpty
                    //textfield’in text verisi String ya da nil olabiliyor. orEmpty verinin her zaman String tipinde gelmesini sağlıyor.
          .throttle(throttleInterval, scheduler: MainScheduler.instance)
          .map { self.validateEmail(with: $0) }
                    //emailValid değişkenin Bool tipinde bir Observable değişken olmasını istediğimizden map ile girdiyi String’den Bool tipine dönüştürmemiz gerekiyor.
          .debug("emailValid", trimOutput: true)
                    //debug metodu konsoldan olayların akışını görebilmemizi sağlıyor. tercihe bağlıdır.
          .share(replay: 1)
                    //Bu Observable değişkene başka subscribe olan Observer’lar varsa share sayesinde map işlemlerinin tekrarlanmamasını sağlıyor.
      
      let passwordValid = passwordTextfield
          .rx
          .text
          .orEmpty
          .throttle(throttleInterval, scheduler: MainScheduler.instance)
          .map { $0.count >= 6 }
          .debug("passwordValid", trimOutput: true)
          .share(replay: 1)
      
      
//      Şimdi bu iki girdimizin de aynı anda doğruluğunu kontrol etmemizi sağlayan Observable bir değişken oluşturmamız gerekiyor.
      let everythingValid = Observable
          .combineLatest(emailValid, passwordValid) { $0 && $1 }
                    //CombineLatest, RxSwift’in birleştirme operatörlerinden biridir. Bu metod sayesinde birden fazla aynı tipte olan Observable değişkenleri tek bir Observable değişken altında toplayabiliyoruz.
          .debug("everythingValid", trimOutput: true)
          .share(replay: 1)
      
      everythingValid
          .bind(to: logInButton.rx.isEnabled)
          .disposed(by: disposeBag)
      
      
      
  }
  
  @IBAction private func logInButtonPressed() {
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let initialViewController = mainStoryboard.instantiateInitialViewController()!
    
    UIApplication.changeRoot(with: initialViewController)
  }
}
