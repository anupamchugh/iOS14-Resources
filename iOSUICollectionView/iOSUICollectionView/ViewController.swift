//
//  ViewController.swift
//  iOSUICollectionView
//
//  Created by Anupam Chugh on 28/06/20.
//

import UIKit

class ViewController: UIViewController {
    
    var items = Array(0...100).map { String($0) }
    var collectionView : UICollectionView!
    private lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        collectionView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<String,String>()
        snapshot.appendSections(["Section 1"])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
    
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<String, String> {
               
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, name in
            
            var content = cell.defaultContentConfiguration()
            content.text = name
            cell.contentConfiguration = content
        }
        
        return UICollectionViewDiffableDataSource<String, String>(
                    collectionView: collectionView,
                    cellProvider: { collectionView, indexPath, item in
                        collectionView.dequeueConfiguredReusableCell(
                            using: cellRegistration,
                            for: indexPath,
                            item: item
                        )
                    }
                )
    }
}

