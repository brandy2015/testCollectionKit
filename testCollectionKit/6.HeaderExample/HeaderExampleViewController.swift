//
//  HeaderExampleViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2018-06-09.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class HeaderExampleViewController: UIViewController {
    
    @IBOutlet weak var collectionView: CollectionView!
    var provider: Provider? {
      get { return collectionView.provider }
      set { collectionView.provider = newValue }
    }

    @IBAction func toggleBTN(_ sender: Any) {
        toggleSticky()
    }
    
     

  var headerComposer: ComposedHeaderProvider<UILabel>!

  override func viewDidLoad() {
    super.viewDidLoad()
 
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)

    let sections: [Provider] = (1...10).map { _ in
      return BasicProvider(
        dataSource: ArrayDataSource(data: Array(1...6)),
        viewSource: ClosureViewSource(viewUpdater: { (view: SquareView, data: Int, index: Int) in
          view.backgroundColor = UIColor(hue: CGFloat(index) / 10,
                                         saturation: 0.68, brightness: 0.98, alpha: 1)
          view.text = "\(data)"
        }),
        sizeSource:  { (index, data, maxSize) -> CGSize in
          return CGSize(width: 80, height: 80)
        },
        layout: FlowLayout(spacing: 10, justifyContent: .spaceAround, alignItems: .center)
          .inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
      )
    }

    let provider = ComposedHeaderProvider(
      headerViewSource: { (view: UILabel, data, index) in
          view.backgroundColor = UIColor.darkGray
          view.textColor = .white
          view.textAlignment = .center
          view.text = "Header \(data.index)"
      },
      headerSizeSource: { (index, data, maxSize) -> CGSize in
        return CGSize(width: maxSize.width, height: 40)
      },
      sections: sections
    )

    self.headerComposer = provider
    self.provider = provider
  }

  @objc func toggleSticky() {
    headerComposer.isSticky = !headerComposer.isSticky
  }
}
