//
//  CarouselViewController.swift
//  BFWControls
//
//  Created by Tom Brodhurst-Hill on 16/03/2016.
//  Copyright © 2016 BareFeetWare.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

open class CarouselViewController: UICollectionViewController {
    
    // MARK: - Variables
    
    @IBInspectable open var controlInsetBottom: CGFloat = 0.0
    
    /// Looped from last back to first page.
    @IBInspectable open var looped: Bool = false
    
    // MARK: - Static content
    
    /// Cell identifiers for finite static content.
    @IBInspectable open var cell0Identifier: String?
    @IBInspectable open var cell1Identifier: String?
    @IBInspectable open var cell2Identifier: String?
    @IBInspectable open var cell3Identifier: String?
    @IBInspectable open var cell4Identifier: String?
    @IBInspectable open var cell5Identifier: String?
    @IBInspectable open var cell6Identifier: String?
    @IBInspectable open var cell7Identifier: String?
    
    /// Name of plist file containing cell identifiers for long static content.
    @IBInspectable open var dataSourcePlistName: String?
    
    /// Override in subclass for dynamic content or use default implementation for static content.
    open var cellIdentifiers: [String]? {
        return plistDict?[Key.cellIdentifiers] as? [String] ?? ibCellIdentifiers
    }
    
    fileprivate struct Key {
        static let cellIdentifiers = "cellIdentifiers"
    }
    
    fileprivate var ibCellIdentifiers: [String] {
        return [cell0Identifier,
                cell1Identifier,
                cell2Identifier,
                cell3Identifier,
                cell4Identifier,
                cell5Identifier,
                cell6Identifier,
                cell7Identifier
            ].flatMap { $0 }
    }
    
    fileprivate var plistDict: [String: AnyObject]? {
        return Bundle.main.path(forResource: dataSourcePlistName, ofType: "plist").flatMap {
            NSDictionary(contentsOfFile: $0) as? [String: AnyObject]
        }
    }
    
    // MARK: - Override in subclass for dynamic content
    
    /// Override in subclass for dynamic content or use default implementation for static content.
    open var pageCount: Int {
        return cellIdentifiers?.count ?? 0
    }
    
    /// Override in subclass for dynamic content or use default implementation for static content.
    open override func collectionView(_ collectionView: UICollectionView,
                                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let page = self.page(for: indexPath)
        let cellIdentifier = cellIdentifiers![page]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        return cell
    }
    
    // MARK: - Variables
    
    open var currentPage: Int {
        return loopedPage(forPage: Int(round(currentPageFloat)))
    }
    
    open var currentPageFloat: CGFloat {
        let page = currentCellItem - (shouldLoop ? 1 : 0)
        return page < 0 || pageCount == 0 ? CGFloat(pageCount) + page : page.truncatingRemainder(dividingBy: CGFloat(pageCount))
    }
    
    open lazy var pageControl: UIPageControl = {
        /* If this carousel is embedded as a container in another view controller, find a page control already
         existing in that view controller, otherwise create a new one.
         */
        let pageControl = self.view.superview?.superview?.subviews.first { subview in
            subview is UIPageControl
            } as? UIPageControl ?? UIPageControl()
        pageControl.numberOfPages = self.pageCount
        pageControl.sizeToFit()
        return pageControl
    }()
    
    // MARK: - Private variables
    
    fileprivate var collectionViewSize: CGSize?
    
    fileprivate var shouldLoop: Bool {
        return looped && pageCount > 1
    }
    
    fileprivate var currentCellItem: CGFloat {
        return collectionViewSize.map { size in collectionView!.contentOffset.x / size.width } ?? 0
    }
    
    // MARK: - Actions
    
    fileprivate func addPageControl() {
        if pageControl.superview == nil {
            collectionView?.addSubview(pageControl)
            pageControl.sizeToFit()
        }
        pageControl.addTarget(self,
                              action: #selector(changed(pageControl:)),
                              for: .valueChanged)
        pageControl.numberOfPages = pageCount
    }
    
    @IBAction open func changed(pageControl: UIPageControl) {
        scroll(toPage: pageControl.currentPage, animated: true)
    }
    
    fileprivate func updatePageControl(shouldUpdateCurrentPage: Bool = true) {
        if let collectionViewSize = collectionViewSize {
            if pageControl.superview == collectionView {
                pageControl.frame.origin.x = (collectionViewSize.width - pageControl.frame.width) / 2 + collectionView!.contentOffset.x
                pageControl.frame.origin.y = collectionViewSize.height - pageControl.frame.height + collectionView!.contentOffset.y - controlInsetBottom
            }
            pageControl.numberOfPages = pageCount
            if shouldUpdateCurrentPage {
                pageControl.currentPage = currentPage
            }
        }
    }
    
    open func scroll(toPage page: Int, animated: Bool) {
        let loopPage = loopedPage(forPage: page)
        let scrolledPage = loopPage + (shouldLoop ? 1 : 0)
        let indexPath = IndexPath(item: scrolledPage, section: 0)
        collectionView?.scrollToItem(at: indexPath,
                                     at: .centeredHorizontally,
                                     animated: animated)
        updatePageControl()
    }
    
    // MARK: - Functions
    
    fileprivate func loopedPage(forPage page: Int) -> Int {
        return page < 0 || pageCount == 0 ? pageCount + page : page % pageCount
    }
    
    open func page(for indexPath: IndexPath) -> Int {
        var page = (indexPath as NSIndexPath).row
        if shouldLoop {
            page -= 1
            page = loopedPage(forPage: page)
        }
        return page
    }
    
    // MARK: - UIViewController
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0.0
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addPageControl()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Resize cell size to fit collectionView if bounds change.
        if collectionViewSize != collectionView?.bounds.size {
            collectionViewSize = collectionView?.bounds.size
            collectionView?.reloadData()
            scroll(toPage: pageControl.currentPage, animated: false)
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension CarouselViewController {
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView,
                                      numberOfItemsInSection section: Int) -> Int
    {
        return pageCount + (shouldLoop ? 2 : 0)
    }
    
}

extension CarouselViewController: UICollectionViewDelegateFlowLayout {
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return collectionView.frame.size
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0.0
    }
    
}

// MARK: - UIScrollViewDelegate

extension CarouselViewController {
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            updatePageControl(shouldUpdateCurrentPage: collectionViewSize ?? CGSize.zero == scrollView.frame.size)
        }
    }
    
    open override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if shouldLoop {
            scroll(toPage: currentPage, animated: false)
        }
    }
    
}
