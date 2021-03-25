//
//  MessagesViewController.swift
//  CollectionKitExample
//
//  Created by YiLun Zhao on 2016-02-12.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class MessageDataProvider: ArrayDataSource<Message> {
  init() {
    super.init(data: testMessages, identifierMapper: { (_, data) in
      return data.identifier
    })
  }
}

class MessageLayout: SimpleLayout {
  override func simpleLayout(context: LayoutContext) -> [CGRect] {
    var frames: [CGRect] = []
    var lastMessage: Message?
    var lastFrame: CGRect?
    let maxWidth: CGFloat = context.collectionSize.width
    
    for i in 0..<context.numberOfItems {
      let message = context.data(at: i) as! Message
      var yHeight: CGFloat = 0
      var xOffset: CGFloat = 0
      var cellFrame = MessageCell.frameForMessage(message, containerWidth: maxWidth)
      if let lastMessage = lastMessage, let lastFrame = lastFrame {
        if message.type == .image &&
          lastMessage.type == .image && message.alignment == lastMessage.alignment {
          if message.alignment == .left && lastFrame.maxX + cellFrame.width + 2 < maxWidth {
            yHeight = lastFrame.minY
            xOffset = lastFrame.maxX + 2
          } else if message.alignment == .right && lastFrame.minX - cellFrame.width - 2 > 0 {
            yHeight = lastFrame.minY
            xOffset = lastFrame.minX - 2 - cellFrame.width
            cellFrame.origin.x = 0
          } else {
            yHeight = lastFrame.maxY + message.verticalPaddingBetweenMessage(lastMessage)
          }
        } else {
          yHeight = lastFrame.maxY + message.verticalPaddingBetweenMessage(lastMessage)
        }
      }
      cellFrame.origin.x += xOffset
      cellFrame.origin.y = yHeight
      
      lastFrame = cellFrame
      lastMessage = message
      
      frames.append(cellFrame)
    }

    return frames
  }
}

class MessageAnimator: WobbleAnimator {
  var dataSource: MessageDataProvider?
  weak var sourceView: UIView?
  var sendingMessage = false

  override func insert(collectionView: CollectionView, view: UIView, at index: Int, frame: CGRect) {
    super.insert(collectionView: collectionView, view: view, at: index, frame: frame)
    guard let messages = dataSource?.data,
      let sourceView = sourceView,
      collectionView.hasReloaded,
      collectionView.isReloading else { return }
    if sendingMessage && index == messages.count - 1 {
      // we just sent this message, lets animate it from inputToolbarView to it's position
      view.frame = collectionView.convert(sourceView.bounds, from: sourceView)
      view.alpha = 0
      view.yaal.alpha.animateTo(1.0)
      view.yaal.bounds.animateTo(frame.bounds, stiffness: 400, damping: 40)
    } else if collectionView.visibleFrame.intersects(frame) {
      if messages[index].alignment == .left {
        let center = view.center
        view.center = CGPoint(x: center.x - view.bounds.width, y: center.y)
        view.yaal.center.animateTo(center, stiffness:250, damping: 20)
      } else if messages[index].alignment == .right {
        let center = view.center
        view.center = CGPoint(x: center.x + view.bounds.width, y: center.y)
        view.yaal.center.animateTo(center, stiffness:250, damping: 20)
      } else {
        view.alpha = 0
        view.yaal.scale.from(0).animateTo(1)
        view.yaal.alpha.animateTo(1)
      }
    }
  }
}

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: CollectionView!
    var provider: Provider? {
      get { return collectionView.provider }
      set { collectionView.provider = newValue }
    }

  var loading = false

  let dataSource = MessageDataProvider()
  let animator = MessageAnimator()
   
    
    @IBOutlet weak var newMessageButton: UIButton!
    @IBAction func newMessageButton(_ sender: Any) {
        send( )//lightBlue
        
    }
    
    
    
  override var canBecomeFirstResponder: Bool {
    return true
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
    view.clipsToBounds = true
    
 
    
    collectionView.delegate = self
    collectionView.contentInset = UIEdgeInsets(top: 30, left: 10, bottom: 54, right: 10)
    collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: 54, right: 0)

    let textMessageViewSource = ClosureViewSource(viewUpdater: { (view: TextMessageCell, data: Message, at: Int) in
      view.message = data
    })
    let imageMessageViewSource = ClosureViewSource(viewUpdater: { (view: ImageMessageCell, data: Message, at: Int) in
      view.message = data
    })
    animator.sourceView = newMessageButton
    animator.dataSource = dataSource
    let provider = BasicProvider(
      dataSource: dataSource,
      viewSource: ComposedViewSource(viewSourceSelector: { data in
        switch data.type {
        case .image:
          return imageMessageViewSource
        default:
          return textMessageViewSource
        }
      })
    )
    let visibleFrameInsets = UIEdgeInsets(top: -200, left: 0, bottom: -200, right: 0)
    provider.layout = MessageLayout().insetVisibleFrame(by: visibleFrameInsets)
    provider.animator = animator
    self.provider = provider
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
     
    
    let isAtBottom = collectionView.contentOffset.y >= collectionView.offsetFrame.maxY - 10
    if !collectionView.hasReloaded {
      collectionView.reloadData() {
        return CGPoint(x: self.collectionView.contentOffset.x,
                       y: self.collectionView.offsetFrame.maxY)
      }
    }
    if isAtBottom {
      if collectionView.hasReloaded {
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x,
                                                y: collectionView.offsetFrame.maxY), animated: true)
      } else {
        collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x,
                                                y: collectionView.offsetFrame.maxY), animated: true)
      }
    }
  }
}

// For sending new messages
extension MessagesViewController {
  @objc func send() {
    let text = UUID().uuidString
    
    animator.sendingMessage = true
    dataSource.data.append(Message(true, content: text))
    collectionView.reloadData()
    collectionView.scrollTo(edge: .bottom, animated:true)
    animator.sendingMessage = false

    delay(1.0) {
      self.dataSource.data.append(Message(false, content: text))
      self.collectionView.reloadData()
      self.collectionView.scrollTo(edge: .bottom, animated:true)
    }
  }
}

extension MessagesViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // PULL TO LOAD MORE
    // load more messages if we scrolled to the top
    if collectionView.hasReloaded,
      scrollView.contentOffset.y < 500,
      !loading {
      loading = true
      delay(0.5) { // Simulate network request
        let newMessages = testMessages.map{ $0.copy() }
        self.dataSource.data = newMessages + self.dataSource.data
        let oldContentHeight = self.collectionView.offsetFrame.maxY - self.collectionView.contentOffset.y
        self.collectionView.reloadData() {
          return CGPoint(x: self.collectionView.contentOffset.x,
                         y: self.collectionView.offsetFrame.maxY - oldContentHeight)
        }
        self.loading = false
      }
    }
  }
}

//
//let testMessages = [
//  Message(announcement: "CollectionView"),
//  Message(false, content: "This is an advance example demostrating what CollectionView can do."),
//  Message(false, content: "Checkout the source code to see how "),
//  Message(false, content: "Nulla fringilla, dolor id congue elementum, urna diam rhoncus eros, sit amet hendrerit turpis velit eget nisl."),
//  Message(false, content: "Quisque nulla sapien, dignissim ac risus nec, vehicula commodo lectus. Suspendisse lacinia mi sit amet nulla semper sollicitudin."),
//  Message(true, content: "Test Content"),
//  Message(announcement: "Today 9:30 AM"),
//  Message(true, image: "l1"),
//  Message(true, image: "l2"),
//  Message(true, image: "l3"),
//  Message(true, content: "Suspendisse ut turpis."),
//  Message(true, content: "velit."),
//  Message(false, content: "Suspendisse ut turpis velit."),
//  Message(true, content: "Nullam placerat rhoncus erat ut placerat."),
//  Message(false, content: "Fusce cursus metus viverra erat viverra, sed efficitur magna consequat. Ut tristique magna et sapien euismod, consequat maximus ipsum varius."),
//  Message(false, content: "Nulla mattis odio a tortor fringilla pulvinar. Curabitur laoreet, velit nec malesuada finibus, massa arcu aliquam ex, a interdum justo massa eget erat. Curabitur facilisis molestie arcu id porta. Phasellus commodo rutrum mi a elementum. Etiam vestibulum volutpat sem, tincidunt auctor elit lobortis in. Pellentesque pellentesque tortor lectus, sed cursus augue porta vitae. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus."),
//  Message(false, content: "In bibendum nisl at arcu mollis volutpat vitae eu urna. Mauris sodales iaculis lorem, nec rutrum dui ullamcorper nec. Fusce nibh dolor, mollis ac efficitur condimentum, vulputate eget erat. Sed molestie neque eu blandit placerat. Fusce nec sagittis nulla. Sed aliquam elit sollicitudin egestas convallis. Vestibulum vel sem vel lectus porta tempus. Curabitur semper in nulla id lacinia. Sed consequat massa nisi, sed egestas quam facilisis id."),
//  Message(false, image: "1"),
//  Message(false, image: "2"),
//  Message(false, image: "3"),
//  Message(false, image: "4"),
//  Message(false, image: "5"),
//  Message(false, image: "6"),
//  Message(true, content: "Etiam a leo nibh. Fusce cursus metus viverra erat viverra, sed efficitur magna consequat. Ut tristique magna et sapien euismod, consequat maximus ipsum varius."),
//  Message(false, content: "Suspendisse ut turpis velit."),
//  Message(true, content: "Vivamus et fermentum diam. Suspendisse vitae tempor lectus."),
//  Message(true, content: "Duis eros eros"),
//  Message(true, status: "Delivered"),
//]
