//
//  ShoppingCart.swift
//  CoffeeShop
//
//  Created by Göktuğ Gümüş on 25.09.2018.
//  Copyright © 2018 Göktuğ Gümüş. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ShoppingCart {
  
  static let shared = ShoppingCart()
  
  var coffees: BehaviorRelay<[Coffee: Int]> = .init(value: [:])
  
  private init() {}
  
  func addCoffee(_ coffee: Coffee, withCount count: Int) {
    var tempCoffees = coffees.value
                // BehaviourSubject bir değişkenin value parametresine ulaşarak Subject’e en son emit edilen elemanı alabiliyoruz
    
    if let currentCount = tempCoffees[coffee] {
      tempCoffees[coffee] = currentCount + count
    } else {
      tempCoffees[coffee] = count
    }
    
    coffees.accept(tempCoffees)
                    // accept(:_) metoduyla BehaviourSubject tipindeki bir değişkenin içersine yeni bir eleman emit edebiliyoruz.
  }
  
  func removeCoffee(_ coffee: Coffee) {
    var tempCoffees = coffees.value
                    //Burada da ekleme yaparken kullandığımızla aynı şekilde değişkenin içindeki en son değeri alıp, gecici değişkene atıyoruz.
    tempCoffees[coffee] = nil
    
    coffees.accept(tempCoffees)
  }
  
  func getTotalCost() -> Observable<Float> {
    return coffees.map { $0.reduce(Float(0)) { $0 + ($1.key.price * Float($1.value)) }}
  }
  
  func getTotalCount() -> Observable<Int> {
    return coffees.map { $0.reduce(0) { $0 + $1.value }}
  }
  
  func getCartItems() -> Observable<[CartItem]> {
    return coffees.map { $0.map { CartItem(coffee: $0.key, count: $0.value) }}
  }
}

