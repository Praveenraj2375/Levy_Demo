//
//  ViewController.swift
//  demoImagePicker
//
//  Created by Praveenraj T on 15/04/22.
//

import UIKit

struct APIResponse:Codable{
    var total:Int
    var total_pages:Int
    var results:[Results]
}

struct Results:Codable{
    let id:String
    let urls:URLS
}
struct URLS:Codable{
    let regular:String
}


class PickerViewController: UIViewController {
    
    let fetchImageAPIDelegate:FetchImageAPIDelegate = UseCase()
    var  timer :Timer?
    
    lazy var emptyCollectionView :ViewForEmptyTableview = {
        let view = ViewForEmptyTableview()
        view.primaryLabel.text = "No images found"
        view.actionButton.setTitle("Reload", for: .normal)
        view.actionButton.addTarget(self, action: #selector(refreshButtonDidTapped), for: .touchUpInside)
        return view
    }()
    
    
    var isErrorDidShownToUser = false
    let layout = UICollectionViewFlowLayout()
    
    lazy var collectionView:UICollectionView = {
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.footerReferenceSize = CGSize(width: 300, height: 50)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        return collectionView
    }()
    var groupImagePickerDelegate:GroupImagePickerDelegate?
    var apiResponse = APIResponse(total: 0, total_pages: 1, results: [])
    
    lazy var searchController:UISearchController = {
        let searchCont = UISearchController()
        searchCont.searchBar.autocapitalizationType = .none
        searchCont.hidesNavigationBarDuringPresentation = false
        searchCont.obscuresBackgroundDuringPresentation = false
        searchCont.definesPresentationContext = true
        searchCont.searchBar.placeholder = "Search Images"
        searchCont.searchBar.showsCancelButton = false
        
        searchCont.searchResultsUpdater = self
        return searchCont
        
    }()
    
    var searchText = String()
    var pageNumber  = Int(1)
    var urlString = "https://api.unsplash.com/search/photos?query=sea&page=1&per_page=20&client_id=strJluv11SbPdQB_y7w272NXnW5pmeQ7toyYdOk-bIQ"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureSearchController()
        fetchImage(searchFor: "random")
        
        configureCollectionView()
        configureNavigationBar()
        
    }
    
    func configureNavigationBar(){
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(navigationBarButtonDidTapped))
    }
    
    func configureSearchController(){
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    @objc func refreshButtonDidTapped(){
        fetchImage(searchFor: searchText)
    }
    
    func fetchImage(searchFor searchText:String,page:Int = 1){
        var isHaveNetworkConnection = true
        isConnectedToInternet(onCompletion: {isConnected in
            isHaveNetworkConnection = isConnected
            if !isConnected{
                if !self.isErrorDidShownToUser{
                    DispatchQueue.main.async {
                        throwWarningToUser(viewController: self, title: "Cellular data is Turned Off", errorMessage: "Turn on cellular data or use Wi-Fi to access data.")
                        self.isErrorDidShownToUser = true
                    }
                }
            }
        })
        
        if !isHaveNetworkConnection{
            return
        }
        
        if page == 1{
            apiResponse.total_pages = 1
            apiResponse.total = 0
            apiResponse.results = []
        }
        else{
            if let cell = collectionView.cellForItem(at: IndexPath(item: apiResponse.results.count-1, section: 0)) as? ImagePickerCollectionViewCell{
                if cell.imageView.image == nil{
                    return
                }}
        }
        
        self.fetchImageAPIDelegate.fetchImage(
            searchFor: searchText,
            page: page,
            totalPages:  self.apiResponse.total_pages,
            totalResult: self.apiResponse.total,
            previousResult: self.apiResponse.results.count,
            onCompletion: {[weak self]error,data in
                guard let data = data ,error == nil else {
                    DispatchQueue.main.async {
                        if error != nil{
                            self?.didNetworkErrorOccured(error: error!)
                        }
                    }
                    return
                }
                
                self?.apiResponse.total = data.total
                self?.apiResponse.total_pages = data.total_pages
                DispatchQueue.main.async {
                    if page == 1{
                        self?.apiResponse.results = []
                        self?.apiResponse.results.append(contentsOf:  data.results)
                    }else{
                        self?.apiResponse.results.append(contentsOf: data.results)
                    }
                    self?.collectionView.reloadData()
                }
            })
    }

    
    func configureCollectionView(){
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        collectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: ImagePickerCollectionViewCell.Identifier)
        
        collectionView.register(CollectionViewFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
    }
    
    @objc func navigationBarButtonDidTapped(){
        imageCache.removeAllObjects()
        presentingViewController?.dismiss(animated: true)
        dismiss(animated: true)
    }
    
}

extension PickerViewController:UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if apiResponse.results.count == 0{
            collectionView.backgroundView = emptyCollectionView
        }else{
            collectionView.backgroundView = nil
        }
        
        return apiResponse.results.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImagePickerCollectionViewCell.Identifier,
            for: indexPath) as? ImagePickerCollectionViewCell
        guard let cell = cell else{
            let cell = UICollectionViewCell()
            cell.backgroundColor = .blue
            return cell
        }
        
        
        if apiResponse.results.count-1 >= indexPath.item{
            getAndSetImage(for: indexPath)
        }
        return cell
    }
    
    func getAndSetImage(for indexPath:IndexPath){
        var isHaveNetworkConnection = true
        isConnectedToInternet(onCompletion: {isConnected in
            isHaveNetworkConnection = isConnected
            if !isConnected{
                if !self.isErrorDidShownToUser{
                    DispatchQueue.main.async {
                        throwWarningToUser(viewController: self, title: "Cellular data is Turned Off", errorMessage: "Turn on cellular data or use Wi-Fi to access data.")
                        self.isErrorDidShownToUser = true
                    }
                }
            }
        })
        
        if !isHaveNetworkConnection{
            return
        }
        
        let urlString = apiResponse.results[indexPath.item].urls.regular
        
        let networkDelegate:NetworkHelperDelegate = UseCase()
        networkDelegate.getImage(for: urlString,searchText:searchText, cache: imageCache as? NSCache<AnyObject,AnyObject>, onCompletion: {image,error,searchText,isFromCache in
            if error != nil{
                DispatchQueue.main.async{
                    if !self.isErrorDidShownToUser{
                        throwWarningToUser(viewController: self, title: "Error", errorMessage: error!.errorDescription!)
                        self.isErrorDidShownToUser = true
                    }
                }
            }else{
                if searchText != self.searchText && self.searchText != "random"{
                    print("old search text")
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell{
                        cell.imageView.image = nil
                    }
                    if indexPath.item < self.apiResponse.results.count {
                        self.getAndSetImage(for:indexPath)
                    }
                    return
                }
                self.didGetImage(for: indexPath, image: image)
                if let cachedImage = isFromCache{
                    if !cachedImage{
                    self.isErrorDidShownToUser = false}
                }
            }
        })
    }
    
    private func didGetImage(for indexPath:IndexPath,image:UIImage?){
        collectionView.backgroundView = nil
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell else{
            print("cell not visible")
            return
        }
        cell.activityIndicator.stopAnimating()
        
        guard let image = image else {
            cell.imageView.image = UIImage(systemName: "person.2.square.stack.fill")
            return
        }
        
        if apiResponse.results.count - 1 >= indexPath.item{
            imageCache.setObject(image, forKey: apiResponse.results[indexPath.item].urls.regular as AnyObject)
        }else{
            print("error")
        }
        cell.imageView.image = image
        if indexPath.item == apiResponse.results.count - 1{
            if apiResponse.total > apiResponse.results.count{
                pageNumber += 1
                fetchImage(searchFor: searchText, page: pageNumber)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 190, height: 190)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell else{
            return
        }
        if cell.imageView.image == nil{
            DispatchQueue.main.async {
                throwWarningToUser(viewController: self, title: "Error", errorMessage: "The image is not loaded yet.Please wait until the image is loaded or select another image")}
            return
        }
        groupImagePickerDelegate?.updateImageUrlString(with: apiResponse.results[indexPath.item].urls.regular)
        imageCache.removeAllObjects()
        
        presentedViewController?.dismiss(animated: true)
        dismiss(animated: true)
    }
    
    @objc func footerRefreshDidTapped(){
        if let cell = collectionView.cellForItem(at: IndexPath(item: apiResponse.results.count-1, section: 0)) as? ImagePickerCollectionViewCell{
            if !cell.isHaveImage(){
                fetchImage(searchFor: searchText, page: pageNumber)
                collectionView.reloadData()
            }else{
                if apiResponse.total > apiResponse.results.count{
                    pageNumber += 1
                    fetchImage(searchFor: searchText, page: pageNumber)
                    collectionView.reloadData()
                }
            }
        }else{
            fetchImage(searchFor: searchText, page: pageNumber)
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionFooter{
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! CollectionViewFooter
            footer.refreshButton.addTarget(self, action: #selector(footerRefreshDidTapped), for: .touchUpInside)
            if apiResponse.total == 0 {
                if searchController.isActive{
                    //footer.configure(with: "No Result Found")
                    footer.refreshButton.isHidden = true
                    footer.refreshButton.isEnabled = false
                }
                footer.refreshButton.isHidden = true
                footer.refreshButton.isEnabled = false
                return footer
            }else if apiResponse.results.count == apiResponse.total {
                collectionView.backgroundView = nil
                if apiResponse.total > 8{
                footer.configure(with: "No More Results Found....!")
                }
                footer.refreshButton.isHidden = true
                footer.refreshButton.isEnabled = false
                return footer
            }else if apiResponse.results.count < apiResponse.total {
                collectionView.backgroundView = nil
                footer.configure(with: "Loading...!")
                footer.refreshButton.isHidden = false
                footer.refreshButton.isEnabled = true
                return footer
            }else{
                collectionView.backgroundView = nil
                footer.configure(with: "")
                footer.refreshButton.isHidden = true
                footer.refreshButton.isEnabled = false
                return footer
            }
        }
        return UICollectionReusableView(frame: .zero)
    }
}


extension PickerViewController:UIScrollViewDelegate,UISearchBarDelegate,UISearchResultsUpdating{
    func resetTimer(){
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else{
            return
        }
        if text.isEmpty{
            return
        }
        
        searchText = text
        resetTimer()
        
        if apiResponse.total > 0{
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            collectionView.backgroundView = nil
            collectionView.layoutIfNeeded()
        }
        let fire = Date().addingTimeInterval(0.5)
        self.timer = Timer(fire: fire, interval: 1.0, repeats: false, block: { _ in
            self.pageNumber = 1
            self.apiResponse.total_pages = 1
            if self.apiResponse.total > 0{
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                self.collectionView.reloadItems(at: [IndexPath(indexes: 0...10)])
                self.collectionView.layoutIfNeeded()
            }
            self.fetchImage(searchFor: self.searchText,page: self.pageNumber)
        })
        
        RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.common)
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let currentText = searchController.searchBar.text else {
            return
        }
        let text = currentText.trimmingCharacters(in: CharacterSet.whitespaces)
        searchText = text.replacingOccurrences(of: " ", with: "+")
        pageNumber = 1
        apiResponse.total_pages = 1
        if apiResponse.total > 0{
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            collectionView.layoutIfNeeded()
        }
        fetchImage(searchFor: searchText,page: pageNumber)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        pageNumber = 1
        apiResponse.total_pages = 1
        searchText = "random"
        if apiResponse.total > 0{
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            collectionView.layoutIfNeeded()
        }
        fetchImage(searchFor: searchText,page: pageNumber)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == 1 && searchController.isActive{
            searchController.searchBar.becomeFirstResponder()
        }
        
        
        
        if indexPath.item == apiResponse.results.count  - 1 {
            if let cell = collectionView.cellForItem(at: IndexPath(item: apiResponse.results.count  - 2 , section: 0)) as? ImagePickerCollectionViewCell{
                if cell.imageView.image == nil{
                    return
                }
                
            }
            if let cell = collectionView.cellForItem(at: indexPath) as? ImagePickerCollectionViewCell{
                if cell.imageView.image == nil{
                    return
                }
                
            }
            pageNumber += 1
            fetchImage(searchFor: searchText,page: pageNumber)
            
        }
    }
}


extension PickerViewController{
    func didNetworkErrorOccured(error:Error){
        var errorTitle = ""
        var errorMsg = ""
        switch (error as NSError).code{

        case URLError.timedOut.rawValue:
            errorTitle = "Poor Internet Connection"
            errorMsg = "Seems your network connection is slow. Please try after some time"//\nLevy_FetchImage"

        case URLError.notConnectedToInternet.rawValue:
            errorTitle = "No Internet Connection"
            errorMsg = "Please Turn on cellular data or wifi to access images "//\nLevy_FetchImage"

        case URLError.networkConnectionLost.rawValue:
            errorTitle = "Something went wrong"
            errorMsg = "Please try again later...\nHostConnectionLost "

        default:
            errorTitle = "Something went wrong"
            errorMsg = "Please try again later"//\nFetchImage"
        }
        if !(self.isErrorDidShownToUser ){
            DispatchQueue.main.async {
            throwWarningToUser(viewController: self, title: errorTitle, errorMessage: errorMsg)
            self.isErrorDidShownToUser = true
            }
        }
    }
}
