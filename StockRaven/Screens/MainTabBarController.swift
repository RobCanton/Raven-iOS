//
//  MainTabBarController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-21.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

enum Screen:String {
    case home = "home"
    case stock = "stock"
}

enum Action:Int {
    case add = 1
    case edit = 2
}

class MainTabBarController:UITabBarController {
    
    var screen:Screen = .home
    /*
    var toolBar:UIToolbar!
    
    var flexibleSpace:UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
    
    var addButton:UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAction))
        button.tag = Action.add.rawValue
        return button
    }
    
    var editButton:UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleAction))
        button.tag = Action.edit.rawValue
        return button
    }
    
    var newAlertButton:UIBarButtonItem {
        let button = UIBarButtonItem(title: "New Alert", style: .plain, target: nil, action: #selector(handleAction))
        button.tag = Action.add.rawValue
        return button
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*let headerView = UINib(nibName: "TickerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TickerView
        headerView.setup()
        
        view.addSubview(headerView)
        headerView.constraintToSuperview(nil, 0, nil, 0, ignoreSafeArea: false)
        headerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        headerView.constraintHeight(to: 44)
        
        headerView.tickerTapeView.start()*/
        /*
        toolBar = UIToolbar()
        view.addSubview(toolBar)
        toolBar.constraintToSuperview(nil, 0, nil, 0, ignoreSafeArea: true)
        toolBar.centerYAnchor.constraint(equalTo: tabBar.centerYAnchor).isActive = true
        
        toolBar.backgroundColor = UIColor.clear
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.barStyle = .default
        toolBar.barTintColor = UIColor.clear
        toolBar.tintColor = Theme.current.primary
        toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)*/
        //presentAlert()
        
        
    }
    
    func presentAlert() {
        let random = Double.random(in: 5...8)
        DispatchQueue.main.asyncAfter(deadline: .now() + random, execute: {
            let view: MessageView
            view = MessageView.viewFromNib(layout: .cardView)
            //view.backgroundColor = UIColor.systemBlue
            view.configureContent(title: "TSLA",
                                  body: "TSLA",
                                  iconImage: nil,
                                  iconText: nil,
                                  buttonImage: nil,
                                  buttonTitle: nil,
                                  buttonTapHandler: { _ in SwiftMessages.hide() })
            view.configureTheme(backgroundColor: UIColor.systemBlue, foregroundColor: .label)
            /*view.titleLabel?.textColor = UIColor.label
            view.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            view.bodyLabel?.textColor = UIColor.label
            view.bodyLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)*/
            view.titleLabel?.attributedText = NSAttributedString(string: "TSLA  -  720.45", attributes: [
                 NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0, weight: .bold)
            ])
            
            let attributedBodyText = NSMutableAttributedString()
//            attributedBodyText.append(NSAttributedString(string: "720.45",
//                                                         attributes: [
//                                                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0, weight: .semibold)
//            ]))
//
            attributedBodyText.append(NSAttributedString(string: "Price over 700",
                                                         attributes: [
                                                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0, weight: .regular)
            ]))
            view.bodyLabel?.attributedText = attributedBodyText
            view.button?.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            view.button?.tintColor = UIColor.white
            view.button?.backgroundColor = UIColor.clear
            view.tapHandler = { _ in
                let stock = StockManager.shared.stocks.first!
                let stockVC = StockDetailViewController(stock: stock)
                guard let first = self.viewControllers?.first as? UINavigationController else { return }
                first.pushViewController(stockVC, animated: true)
                SwiftMessages.hide()
            }
            
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .top
            config.presentationContext = .window(windowLevel: .normal)
            config.duration = .seconds(seconds: 5)
            config.interactiveHide = true
            
            SwiftMessages.show(config: config, view: view)
            self.presentAlert()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //NotificationCenter.addObserver(self, selector: #selector(screenChanged), type: .screenChanged)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //NotificationCenter.default.removeObserver(self)
    }

    /*
    @objc func screenChanged(_ notification:Notification) {
        guard let screen = notification.userInfo?["screen"] as? Screen else { return }
        print("Screen Changed: \(screen.rawValue)")
        self.screen = screen
        displayItems(for: screen, animated: true)
        
    }
    
    private func displayItems(for screen:Screen, animated:Bool=false) {
        switch screen {
        case .home:
            toolBar.setItems([
                editButton,
                flexibleSpace,
                addButton
            ], animated: animated)
            break
        case .stock:
            toolBar.setItems([
                flexibleSpace,
                newAlertButton
            ], animated: animated)
            break
        }
    }
    
    @objc func handleAction(_ button:UIBarButtonItem) {
        guard let action = Action(rawValue: button.tag) else { return }
        print("action: \(action)")
        NotificationCenter.post(.action(screen, action))
    }
    */
}

