//
//  HorizontalGalleryViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2016-06-14.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class HorizontalGalleryViewController: UIViewController {
     
    @IBOutlet weak var collectionView: CollectionView!
    var provider: Provider? {
      get { return collectionView.provider }
      set { collectionView.provider = newValue }
    }
    
    
    @IBOutlet weak var imageViewC: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let testImages: [UIImage] = [
          UIImage(named: "l1")!,
          UIImage(named: "l2")!,
          UIImage(named: "l3")!,
          UIImage(named: "1")!,
          UIImage(named: "2")!,
          UIImage(named: "3")!,
          UIImage(named: "4")!,
          UIImage(named: "5")!,
          UIImage(named: "6")!
        ]
        
        
        let testImageXs = testImages
        
         
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let visibleFrameInsets = UIEdgeInsets(top: 0, left: -100, bottom: 0, right: -100)
        
        
        provider = BasicProvider(
            dataSource: testImageXs,
            viewSource: ClosureViewSource(viewGenerator: { (data, index) -> UIImageView in
                let view = UIImageView()
                view.layer.cornerRadius = 5
                view.clipsToBounds = true
                return view
            }, viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
                view.image = data
            }),
            sizeSource: UIImageSizeSource(),
            layout: WaterfallLayout(columns: 2, spacing: 10).transposed().insetVisibleFrame(by: visibleFrameInsets),
            animator: WobbleAnimator(),
            
            tapHandler: { [weak self] context in
               
                // 这里是点按之后的处理
                self?.imageViewC.image = context.dataSource.data(at: context.index)
            }
        )
         
        
    }

}
 
