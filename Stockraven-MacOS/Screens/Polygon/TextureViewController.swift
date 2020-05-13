//
//  TextureViewController.swift
//  StockRaven
//
//  Created by Robert Canton on 2020-04-28.
//  Copyright © 2020 Robert Canton. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class TextureViewController:ASViewController<ASDisplayNode>, ASTableDelegate, ASTableDataSource {
    
    
    var stocks:[PolygonStock]
    
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    var tableView:UITableView {
        return tableNode.view
    }
    
    init() {
        stocks = StockManager.shared.stocks
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
        
     }

     required init?(coder aDecoder: NSCoder) {
       fatalError("storyboards are incompatible with truth and beauty")
     }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGroupedBackground
        appearance.shadowImage = UIImage()
        
        
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.label
        
        navigationItem.title = "Raven"
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
        //view.addSubview(tableView)
       // tableView.constraintToSuperview()
        //tableNode.reloadData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.addObserver(self, selector: #selector(reload), type: .stocksUpdated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reload() {
        stocks = StockManager.shared.stocks
        tableNode.reloadData()
    }
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let stock = stocks[indexPath.row]
        let node = StockCellNode(stock: stock)
        return node
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
        
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        StockManager.shared.moveStock(at: sourceIndexPath.row, to: destinationIndexPath.row)
        self.stocks = StockManager.shared.stocks
    }

}

extension TextureViewController: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {

        if session.localDragSession != nil { // Drag originated from the same app.
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }

        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
}
