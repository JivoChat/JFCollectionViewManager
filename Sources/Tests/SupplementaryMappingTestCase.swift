//
//  SupplementaryMappingTestCase.swift
//  DTCollectionViewManager
//
//  Created by Denys Telezhkin on 30.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTCollectionViewManager

class SupplementaryMappingTestCase: XCTestCase {
    
    var controller: DTSupplementaryTestCollectionController!
    
    override func setUp() {
        super.setUp()
        controller = DTSupplementaryTestCollectionController()
        let _ = controller.view
        controller.manager.memoryStorage.configureForCollectionViewFlowLayoutUsage()
    }
    
    func verifyHeader() {
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at:  indexPath(0, 0))
        XCTAssertTrue(view is NibHeaderFooterView)
    }
    
    func verifyFooter() {
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at:  indexPath(0, 0))
        XCTAssertTrue(view is NibHeaderFooterView)
    }
    
    func testHeaderMappingFromHeaderFooterView()
    {
        controller.manager.registerHeader(NibHeaderFooterView.self)
        verifyHeader()
    }
    
    func testFooterMappingFromHeaderFooterView()
    {
        controller.manager.registerFooter(NibHeaderFooterView.self)
        verifyFooter()
    }
    
    func testRegisterNibNamedForHeaderClass()
    {
        controller.manager.registerHeader(NibHeaderFooterView.self) { mapping in
            mapping.xibName = "RandomNameHeaderFooterView"
        }
        verifyHeader()
    }
    
    func testRegisterNibNamedForFooterClass()
    {
        controller.manager.registerFooter(NibHeaderFooterView.self) { mapping in
            mapping.xibName = "RandomNameHeaderFooterView"
        }
        verifyFooter()
    }
    
    func testRegisterSupplementaryClassForKind()
    {
        controller.manager.registerSupplementary(NibHeaderFooterView.self, ofKind: UICollectionView.elementKindSectionFooter)
        verifyFooter()
    }
    
    func testRegisterNibNamedForSupplementaryClass()
    {
        controller.manager.registerSupplementary(NibHeaderFooterView.self, ofKind: UICollectionView.elementKindSectionFooter) { mapping in
            mapping.xibName = "RandomNameHeaderFooterView"
        }
        verifyFooter()
    }
    
    func testRegisterNiblessSupplementaryClass() {
        controller.manager.registerSupplementary(NiblessHeaderFooterView.self, ofKind: UICollectionView.elementKindSectionHeader)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at:  indexPath(0, 0))
        XCTAssertTrue(view is NiblessHeaderFooterView)
    }
    
    func testRegisterNiblessHeader() {
        controller.manager.registerHeader(NiblessHeaderFooterView.self)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionHeaderModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at:  indexPath(0, 0))
        XCTAssertTrue(view is NiblessHeaderFooterView)
    }
    
    func testRegisterNiblessFooter() {
        controller.manager.registerFooter(NiblessHeaderFooterView.self)
        (controller.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = CGSize(width: 320, height: 50)
        controller.manager.memoryStorage.setSectionFooterModels([1])
        controller.manager.memoryStorage.setItems([1])
        controller.collectionView?.performBatchUpdates(nil, completion: nil)
        
        let view = controller.manager.collectionDataSource?.collectionView(controller.collectionView!, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, at:  indexPath(0, 0))
        XCTAssertTrue(view is NiblessHeaderFooterView)
    }
}