//
//  OfflinePhotoViewerViewController.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 7. 23..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import UIKit

class OfflinePhotoViewerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    let itemsPerRow: CGFloat = 3
    
    let photoManager = PhotoManager.sharedManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let naviController = self.navigationController {
            naviController.setNavigationBarHidden(true, animated: animated)
        }
        
        photoCollectionView.reloadData()
    }
    
    //MARK:- UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "offlineDetail")
        if let vc = viewController as? OfflinePhotoDetailViewController {
            let calcIndex = indexPath.section * Int(itemsPerRow) + indexPath.row
            vc.beginPhotoIndex = calcIndex
            if let naviVC = self.navigationController {
                naviVC.pushViewController(vc, animated: true)
            } else {
                self.present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK:- UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoManager.downloadPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photo", for: indexPath)
        if let cell = cell as? OfflinePhotoCollectionViewCell {
//            cell.imageURL = photoManager.documentPhotos()[indexPath.row]
            let calcIndex = indexPath.section * Int(itemsPerRow) + indexPath.row
            if let imageURL = photoManager.downloadPhotos[calcIndex].saveFileURL() {
                cell.imageView.image = UIImage(contentsOfFile: imageURL.path)
            }
        }
        
        return cell
    }
    
    //MARK:- UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
