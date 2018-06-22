//
//  WQBannerView.swift
//  WQBanner
//
//  Created by CampbellQi on 2018/6/22.
//  Copyright © 2018年 CampbellQi. All rights reserved.
//

import UIKit

class WQBannerView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    //MARK: Properties
    //点击某张图片回调
    var pickedBlock: ((_ index: Int) -> Void)?
    //定时器
    private var timer: Timer!
    //cell标识
    private let cellId = "WQBannerCell"
    //处理后的imageUrls
    private var dataSource: [String]!
    //滚动未知
    private var currentIndex = 0

    //数据源
    var imageUrls: [String]! {
        didSet{
            self.pageControl.numberOfPages = imageUrls.count
            
            //处理数据源
            dataSource = imageUrls
            dataSource.insert(imageUrls!.last!, at: 0)
            dataSource.append(imageUrls!.first!)
            
            self.collectionView.reloadData()
            self.layoutIfNeeded()
            self.collectionView.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            
            currentIndex = 1
        }
    }
    //滚动时间间隔
    var autoScrollDuration: Double! {
        didSet{
            self.timer = Timer.init(timeInterval: autoScrollDuration, target: self, selector: #selector(timeRepeat), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer, forMode: RunLoopMode.defaultRunLoopMode)
        }
    }
    
    //MARK: Life Circles
    //按照frame方式初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    //按xib初始化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutIfNeeded()
        //设置layout
        //布局
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal //横向滚动
        layout.itemSize = CGSize.init(width: self.frame.width, height: self.frame.height)
        self.collectionView.setCollectionViewLayout(layout, animated: false)
    }
    //MARK: Functions
    //通用初始化方法
    func commonInit() {
        //bunding
        let topView = Bundle.main.loadNibNamed("WQBannerView", owner: self, options: nil)![0] as! UIView
        topView.frame = self.bounds
        self.addSubview(topView)
        //注册cell
        let nib = UINib.init(nibName: cellId, bundle: Bundle.main)
        self.collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        
        //监听app到前后台(timer停止/进行)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    @objc func applicationEnterBackground() {
        if let _ = timer{
            self.timer.invalidate()
            self.timer = nil
        }
    }
    @objc func applicationEnterForeground() {
        if let _ = timer{
            self.timer.invalidate()
            self.timer = nil
        }
        
        self.timer = Timer.init(timeInterval: autoScrollDuration, target: self, selector: #selector(timeRepeat), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    //时间重复方法
    @objc func timeRepeat() {
        self.collectionView.scrollToItem(at: IndexPath.init(row: currentIndex+1, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        
//        timer.invalidate()
        //动画结束执行
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
             self.scrollEnded(index: self.currentIndex+1)
        }
       
    }
    //手动，自动滚动结束后执行
    func scrollEnded(index: Int) {
        if index == 0 {
            self.collectionView.scrollToItem(at: IndexPath.init(row: dataSource.count-2, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            self.pageControl.currentPage = imageUrls.count-1
            self.currentIndex = dataSource.count-2
        }else if index == dataSource.count-1 {
            self.collectionView.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            self.pageControl.currentPage = 0
            self.currentIndex = 1
        }else {
            self.pageControl.currentPage = index-1
            self.currentIndex = index
        }
    }
}

extension WQBannerView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var index = indexPath.row-1
        if indexPath.row == 0 {
            index = self.imageUrls.count - 1
        }else if indexPath.row == self.dataSource.count - 1 {
            index = 0
        }
        self.pickedBlock?(index)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! WQBannerCell
        //设置image(如果是网络图片，在此处调用图片加载方法)
        cell.contentIV.image = UIImage.init(named: self.dataSource[indexPath.row])
        return cell
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x / scrollView.frame.width
        self.scrollEnded(index: Int(x))
    }
    //拖动后重新计时滚动，防止计时不准确
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.timer.invalidate()
        self.timer = nil
        
        self.timer = Timer.init(timeInterval: autoScrollDuration, target: self, selector: #selector(timeRepeat), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
}
