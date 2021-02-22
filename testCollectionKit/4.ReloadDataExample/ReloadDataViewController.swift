//
//  ReloadDataViewController.swift
//  CollectionKit
//
//  Created by yansong li on 2017-09-04.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class ReloadDataViewController: UIViewController {
    var currentMax: Int = 5
    
    @IBOutlet weak var collectionView: CollectionView!
    var provider: Provider? {
      get { return collectionView.provider }
      set { collectionView.provider = newValue }
    }

    let dataSource = ArrayDataSource<Int>(data: Array(0..<5)) { (_, data) in
        return "\(data)"
    }

    
    
    @IBAction func addButton(_ sender: Any) {
        add()
    }
    @objc func add() {
        dataSource.data.append(currentMax)
        currentMax += 1
        // NOTE: Call reloadData() directly will make collectionView update immediately, so that contentSize
        // of collectionView will be updated.
        collectionView.reloadData()
        collectionView.scrollTo(edge: .bottom, animated:true)
    }
  

  

    override func viewDidLoad() {
        super.viewDidLoad()
   
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 54, right: 10)

        provider = BasicProvider(
            dataSource: dataSource,
            viewSource: { (view: SquareView, data: Int, index: Int) in
                view.backgroundColor = UIColor(hue: CGFloat(data) / 30,
                                       saturation: 0.68,
                                       brightness: 0.98,
                                       alpha: 1)
        view.text = "\(data)"
      },
      sizeSource: { (index, data, _) in
        return CGSize(width: 80, height: data % 3 == 0 ? 120 : 80)
      },
      layout: FlowLayout(lineSpacing: 15,
                         interitemSpacing: 15,
                         justifyContent: .spaceAround,
                         alignItems: .center,
                         alignContent: .center),
      animator: ScaleAnimator(),
      tapHandler: { [weak self] context in
        self?.dataSource.data.remove(at: context.index)
      }
    )
  }

   

  
}

