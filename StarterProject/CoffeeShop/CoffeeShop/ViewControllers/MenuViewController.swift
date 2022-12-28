//
//  MenuViewController.swift
//  CoffeeShop
//
//  Created by Göktuğ Gümüş on 23.09.2018.
//  Copyright © 2018 Göktuğ Gümüş. All rights reserved.
//

import UIKit
import RxSwift

class MenuViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var shoppingCartButton: BadgeBarButtonItem = {
        let button = BadgeBarButtonItem(image: "cart_menu_icon", badgeText: nil, target: self, action: #selector(shoppingCartButtonPressed))
        
        button!.badgeButton!.tintColor = Colors.brown
        
        return button!
    }()
    
    private lazy var coffees: Observable<[Coffee]> = {
        let espresso = Coffee(name: "Espresso", icon: "espresso", price: 4.5)
        let cappuccino = Coffee(name: "Cappuccino", icon: "cappuccino", price: 11)
        let macciato = Coffee(name: "Macciato", icon: "macciato", price: 13)
        let mocha = Coffee(name: "Mocha", icon: "mocha", price: 8.5)
        let latte = Coffee(name: "Latte", icon: "latte", price: 7.5)
        
        return.just([espresso, cappuccino, macciato, mocha, latte])
        //[espresso, cappuccino, macciato, mocha, latte]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = shoppingCartButton
        
        configureTableView()
        
        //  MARK: - numberOfRowsInSection, numberOfSections, cellForRowAt için
        coffees
            .bind(to: tableView
                .rx
                .items(cellIdentifier: "coffeeCell", cellType: CoffeeCell.self)) { row, element, cell in
                    //Bu sayede Rx framework’ü bizim için normalde delegate kullanarak oluşturduğumuz dequeuing metodlarını kendisi çağırır.
                    cell.configure(with: element)
                    //Bu kod bloğu her yeni eleman için çalıştırılmaktadır. Row, element ve cell bilgilerine ulaşabilmemize olanak tanır
                }
                .disposed(by: disposeBag)
        
        //  MARK: - didSelectRowAt için
        tableView
            .rx
            .modelSelected(Coffee.self)
                    //Bu metod seçilen (tıklanan) cell’in modelini Observable olarak geri döndürür.
            .subscribe(onNext: { [weak self] coffee in
                self?.performSegue(withIdentifier: "OrderCofeeSegue", sender: coffee)
                
                if let selectedRowIndexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        //  MARK: - ShoppingCart

        ShoppingCart.shared.getTotalCount()
            .subscribe(onNext: { [weak self] totalOrderCount in
                self?.shoppingCartButton.badgeText =  totalOrderCount != 0 ? "\(totalOrderCount)" : nil
            })
            .disposed(by: disposeBag)
    }

    
    private func configureTableView() {
        tableView.rowHeight = 104
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
    }
    
    @objc private func shoppingCartButtonPressed() {
        performSegue(withIdentifier: "ShowCartSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let coffee = sender as? Coffee else { return }
        
        if segue.identifier == "OrderCofeeSegue" {
            if let viewController = segue.destination as? OrderCoffeeViewController {
                viewController.coffee = coffee
                viewController.title = coffee.name
            }
        }
    }
}




