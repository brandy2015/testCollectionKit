//
//  ViewController.swift
//  testCollectionKit
//
//  Created by zhangzihao on 2021/2/22.
//

import UIKit
import CollectionKit


class ViewController: UIViewController {

    @IBOutlet weak var collectionView: CollectionView!
    
    //哈哈
    var 哈哈 = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configCollectionKit() 
    }

    func configCollectionKit() {
        let dataSource = ArrayDataSource(data: [1, 2, 3, 4])
        let viewSource = ClosureViewSource(viewUpdater: { (view: UILabel, data: Int, index: Int) in
          view.backgroundColor = .red
          view.text = "\(data)"
        })
        let sizeSource = { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
          return CGSize(width: 50, height: 50)
        }
        let provider = BasicProvider(
          dataSource: dataSource,
          viewSource: viewSource,
          sizeSource: sizeSource
        )

        //lastly assign this provider to the collectionView to display the content
        collectionView.provider = provider
    }
    
    
//    func ReloadData()  {
//        dataSource.data = [7, 8, 9]
//    }

    
//    func appendData()  {
//        dataSource.data.append(10)
//        dataSource.data.append(11)
//        dataSource.data.append(12)
//    }
}



