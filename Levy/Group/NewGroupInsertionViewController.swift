//
//  NewGroupInsertionViewController.swift
//  Levy
//
//  Created by Praveenraj T on 29/03/22.
//

import UIKit

protocol GroupImagePickerDelegate:AnyObject{
    func updateImageUrlString(with urlString:String)
}

class NewGroupInsertionViewController: UIViewController {
    
    private let memberCountLabelSuffix = " Friends Added"
    
    private var maxCharacterInNameTextField = 40
    private let maxCharacterInDescriptionTextField = 100
    private let imageViewSize = CGFloat(150)
    private let selectedFriedsTableVC = SelectedFriendsListFromContact()

    
    private var isNameTextFieldContainText = false
    private var isDescriptionFieldContainText = false
    
    private var selectedFriendsFromContact = [ContactDetail]()
    
    private let tripDetailDBDelegate : TripDetailDBDelegate = UseCase()
    private let groupDBDelegate : GroupDBDelegate  = UseCase()
    weak var updateGroupListDelegate : UpdateGroupListDelegate?
    
    private lazy var pre1 = NSPredicate(format: "phoneNumbers.@count>0  ")
    private lazy var arrayOfIdentifier = [String]()
    private lazy var pre2 = NSCompoundPredicate(notPredicateWithSubpredicate: NSPredicate(format: "identifier IN %@",argumentArray: [arrayOfIdentifier]))
    private lazy var predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [pre1,pre2])
    
    private var defalutImageURL = ""
    private lazy var groupImageURLString = defalutImageURL
    private var defaultImage:UIImage  {
        get{
            if #available(iOS 14.0, *){
                return UIImage(systemName: "photo.circle")!
            }
            else{
                return UIImage(systemName: "photo")!
            }
        }
        
    }
    private let addFriendButtonImage = UIImage(systemName: "person.crop.circle.badge.plus")

    private let scrollView = UIScrollView()

    private let containerView = UIView()
    private let imageContainerView = UIView()
    
    private lazy var imageView :UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.image = defaultImage
        
        imageView.layer.cornerRadius = imageViewSize/2
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageViewDidTapped))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    private let removeImageButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "multiply.circle.fill"), for: .normal)
        button.tintColor = .secondaryLabel
        return button
    }()
    
    private lazy var addImageButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Image", for: .normal)
        button.backgroundColor = .clear
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        
        button.titleLabel?.textAlignment = .left
        
        return button
        
    }()

    private lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.attributedText = createMandatoryText(for: "Group Name ")
        label.setContentHuggingPriority(UILayoutPriority(249), for: .vertical)
        return label
    }()
    
    private lazy var nameCharecterCountLabel:UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = "0/\(maxCharacterInNameTextField)"
        label.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        return label
    }()
    
    private lazy var nameTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = " Enter Group Name"
        textField.clearButtonMode = .whileEditing

        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.leftViewMode = .always
        return textField
    }()
    
    private lazy var descriptionLabel:UILabel = {
        let label = UILabel()
        label.attributedText = createMandatoryText(for: "Group Description ")
        label.setContentHuggingPriority(UILayoutPriority(249), for: .vertical)
        return label
    }()
    
    private lazy var descriptionCharecterCountLabel:UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = "0/\(maxCharacterInDescriptionTextField)"
        label.setContentHuggingPriority(UILayoutPriority(249), for: .horizontal)
        return label
    }()
    
    private lazy var descriptionTextView:UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.layer.borderColor = UIColor.systemGray.cgColor
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1
        
        return textView
    }()
    
    private lazy var addFriendButton:UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        
        button.setAttributedTitle(createMandatoryText(for: "Add Friends "), for: .normal)
        button.setImage(addFriendButtonImage, for: .normal)
        
        if #available(iOS 15.0, *){
            var config = UIButton.Configuration.borderless()
            config.imagePlacement = .trailing
            config.imagePadding = 10
            button.configuration = config
        }else{
            button.semanticContentAttribute = .forceRightToLeft
        }
        
        return button
    }()
    
    private lazy var memberCountLabel:UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
                
    private lazy var doneBarButton:UIBarButtonItem = {
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTapped))
        done.isEnabled  = false
        return done
    }()
    
    let selectedFriendsTableView:SelfSizingTableView = {
        let tableView = SelfSizingTableView()
        tableView.isScrollEnabled = false
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.systemTeal.cgColor
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "New Group"
        isModalInPresentation = true
        
        scrollView.delegate = self
        
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTapped))
        
        configureScrollView()
        configureImageView()
        configureAddImageButton()
        configureNameLabel()
        configureNameCharecterCountLabel()
        configureNameTextField()
        configureDescriptionLabel()
        configureDescriptionCharecterCountLabel()
        configureDescriptionTextField()
        configureAddFriendButton()
        configureMemberCountLabel()
        configureSelectedFriendsTableView()

        setMemberCountLabelText()
        
        updateUIConstraintWhileKeyboardAppearing()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    private func updateUIConstraintWhileKeyboardAppearing(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    private func configureScrollView(){
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewDidTapped))
        scrollView.addGestureRecognizer(tap)
        scrollView.isUserInteractionEnabled = true
        
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor,constant: 10),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor)

        ])
        containerView.isUserInteractionEnabled = true
        
    }
    
    private func configureImageView(){
        containerView.addSubview(imageContainerView)
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageContainerView.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 10),
            imageContainerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageContainerView.heightAnchor.constraint(equalToConstant: imageViewSize),
            imageContainerView.widthAnchor.constraint(equalToConstant: imageViewSize)
        ])
        
        imageContainerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor,constant: 0),
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: imageViewSize),
            imageView.widthAnchor.constraint(equalToConstant: imageViewSize)
        ])
        
      imageView.isUserInteractionEnabled = true
        
        imageContainerView.addSubview(removeImageButton)
        removeImageButton.isHidden = true
        removeImageButton.isEnabled = false
        
        removeImageButton.translatesAutoresizingMaskIntoConstraints = false
        removeImageButton.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -(imageViewSize/4)+10).isActive = true
        removeImageButton.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: imageViewSize/4-10).isActive = true
        removeImageButton.addTarget(self, action: #selector(willRemoveImage), for: .touchUpInside)
    }
    
    private func configureAddImageButton(){
        containerView.addSubview(addImageButton)
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor,constant: 5),
            addImageButton.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            addImageButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        addImageButton.addTarget(self, action: #selector(imageViewDidTapped), for: .touchUpInside)
    }
    
    @objc private  func willRemoveImage(){
        imageView.image =  defaultImage
        addImageButton.setTitle("Add Image", for: .normal)
        removeImageButton.isHidden = true
        removeImageButton.isEnabled = false
        groupImageURLString = defalutImageURL
    }
    
    private func configureNameLabel(){
        containerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: addImageButton.bottomAnchor,constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10)
        ])
    }
    
    private func configureNameCharecterCountLabel(){
        containerView.addSubview(nameCharecterCountLabel)
        nameCharecterCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameCharecterCountLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            nameCharecterCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nameCharecterCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 50)
        ])
    }
    
    private func configureNameTextField(){
        containerView.addSubview(nameTextField)
        nameTextField.delegate = self
        nameTextField.isUserInteractionEnabled = true
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: 10),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            nameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureDescriptionLabel(){
        containerView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10)
        ])
    }
    
    private func configureDescriptionCharecterCountLabel(){
        containerView.addSubview(descriptionCharecterCountLabel)
        descriptionCharecterCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionCharecterCountLabel.topAnchor.constraint(equalTo: descriptionLabel.topAnchor),
            descriptionCharecterCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            descriptionCharecterCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: descriptionLabel.trailingAnchor, constant: 50)
        ])
    }
    
    private func configureDescriptionTextField(){
        containerView.addSubview(descriptionTextView)
        descriptionTextView.delegate = self
        descriptionTextView.isUserInteractionEnabled = true
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            descriptionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func configureAddFriendButton(){
        containerView.addSubview(addFriendButton)
        addFriendButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addFriendButton.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20),
            addFriendButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        addFriendButton.addTarget(self, action: #selector(addFriendButtonDidTapped), for: .touchUpInside)
    }
    
    private func configureMemberCountLabel(){
        containerView.addSubview(memberCountLabel)
        memberCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            memberCountLabel.centerXAnchor.constraint(equalTo: addFriendButton.centerXAnchor),
            memberCountLabel.topAnchor.constraint(equalTo: addFriendButton.bottomAnchor,constant: 5),
            memberCountLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -10)
        ])
    }
    
    private  func setMemberCountLabelText(){
        var string = ""
        switch arrayOfIdentifier.count{
        case 0 : string = "No Friends Added"
        case 1 : string = "1 Friend Added"
        default : string = arrayOfIdentifier.count.description+memberCountLabelSuffix
        }
        
        memberCountLabel.text = string
    }
    
    private func configureSelectedFriendsTableView(){
        containerView.addSubview(selectedFriendsTableView)
        selectedFriendsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        selectedFriendsTableView.topAnchor.constraint(equalTo: memberCountLabel.bottomAnchor,constant: 10).isActive = true
        selectedFriendsTableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        selectedFriendsTableView.safeAreaLayoutGuide.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        selectedFriendsTableView.safeAreaLayoutGuide.widthAnchor.constraint(equalTo: containerView.widthAnchor,constant: -4).isActive = true
        
        selectedFriendsTableView.dataSource = self
        selectedFriendsTableView.delegate = self
        
        selectedFriendsTableView.register(SelectedFriendsListCell.self, forCellReuseIdentifier: SelectedFriendsListCell.identifier)
    }
    
    
    @objc private  func keyboardWillShow(notification:NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }
    
    @objc private  func keyboardWillHide(notification:NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    @objc private  func scrollViewDidTapped(){
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    @objc private  func imageViewDidTapped(){
        let pickerView = PickerViewController()
        pickerView.title = "Pick an Image"
        pickerView.groupImagePickerDelegate = self
        present(UINavigationController(rootViewController: pickerView), animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        scrollViewDidTapped()
    }
    
}

extension NewGroupInsertionViewController:UITableViewDataSource,UITableViewDelegate,RemoveFriendsFromSelectedFreindsDelegate{
    func removeFriend(at cell: UITableViewCell) {
        if let index = selectedFriendsTableView.indexPath(for: cell) {
            let deletedFriendID =  selectedFriendsFromContact[index.row].identifier
            selectedFriendsFromContact.removeAll(where: {$0.identifier == deletedFriendID})
            arrayOfIdentifier.removeAll(where: {$0 == deletedFriendID})
            selectedFriendsTableView.deleteRows(at: [index], with: .automatic)
            selectedFriendsTableView.layoutIfNeeded()
            setMemberCountLabelText()
        }else{
            print("***Error cell not found")
        }
        
        if isNameTextFieldContainText && isDescriptionFieldContainText && !arrayOfIdentifier.isEmpty{
            doneBarButton.isEnabled = true
        }
        else{
            doneBarButton.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectedFriendsFromContact.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectedFriendsListCell.identifier) as? SelectedFriendsListCell
        guard let cell = cell else{
            print("*** Error: while unwrapping cell @ friendslistVCForSplit")
            return UITableViewCell()
        }
        cell.setNameLable(with: selectedFriendsFromContact[indexPath.row].name)
        cell.setPhoneNumberLabel(with: selectedFriendsFromContact[indexPath.row].telephone)
        cell.removeFriendsFromSelectedFreindsDelegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        let action = UIContextualAction(style: .destructive, title: "Delete") {_,_,completion in
            guard let cell = self.selectedFriendsTableView.cellForRow(at: indexPath) as? SelectedFriendsListCell else{
                return
            }
            cell.deleteButtonDidTapped()
            completion(true)
        }
        let swipe =  UISwipeActionsConfiguration(actions: [action])
        return swipe
    }
    
}

//extension NewGroupInsertionViewController:ShowFriendsDelegate{
//    func updateFriends(list: [ContactDetail]) {
//        selectedFriendsFromContact = []
//        selectedFriendsFromContact.append(contentsOf: list)
//        arrayOfIdentifier = []
//        arrayOfIdentifier = selectedFriendsFromContact.map({$0.identifier})
//        setMemberCountLabelText()
//
//        if isNameTextFieldContainText && isDescriptionFieldContainText && !arrayOfIdentifier.isEmpty{
//            doneBarButton.isEnabled = true
//        }
//        else{
//            doneBarButton.isEnabled = false
//        }
//    }
//}

extension NewGroupInsertionViewController{
    @objc private   func doneButtonDidTapped(){
        descriptionTextView.resignFirstResponder()
        nameTextField.resignFirstResponder()
        guard let groupName = nameTextField.text else{
            return
        }
        guard let groupDescription = descriptionTextView.text else{
            return
        }
        var group = GroupDetails(groupID: 0, groupName: groupName, groupDescription:groupDescription , amount: 0)
        group.groupImageURLString = groupImageURLString
        guard let insertedGroupID = groupDBDelegate.insertIntoGroupDetails(group: group) else{
            return
        }
        group.groupID = insertedGroupID
        
        for friend in selectedFriendsFromContact{
            insertFriendIntoDB(contact: friend, groupID: insertedGroupID)
        }
        updateGroupListDelegate?.updateGroupList()
        
        dismiss(animated: true)
        
    }
    
    @objc private  func cancelButtonDidTapped(){
        nameTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        
        if (nameTextField.text?.isEmpty ?? true) && (descriptionTextView.text?.isEmpty ?? true) && (arrayOfIdentifier.count == 0) && imageView.image == defaultImage
        {
            dismiss(animated: true, completion: nil)
            
        }
        else{
            let actionSheet = UIAlertController(title: nil, message: "Are you sure you want to discard this new group detail?", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            actionSheet.popoverPresentationController?.sourceView = self.view
            let xOrigin = 0
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            actionSheet.popoverPresentationController?.sourceRect = popoverRect
            actionSheet.popoverPresentationController?.permittedArrowDirections = .up
            
            present(actionSheet,animated: true)
        }
    }
    
    @objc private  func addFriendButtonDidTapped(){
        let contactPicker = customContactPicker()
        contactPicker.updateFriendsDelegate = self
        contactPicker.title = "Add Friends To Group"
        contactPicker.preSelectedArrayOfIdentifier = selectedFriendsFromContact.map({$0.identifier})
        present(UINavigationController(rootViewController: contactPicker),animated: true)
    }
}

extension NewGroupInsertionViewController:UpdateFriendsDelegate{
    func updateFriends(friends: [ContactDetail]) {
        for friend in friends{
            if let index = selectedFriendsFromContact.firstIndex(where: {$0.name > friend.name}) {
                insertNewFriend(at: index, friend: friend)
            }else{
                insertNewFriend(at: selectedFriendsFromContact.count, friend: friend)
            }
        }
        arrayOfIdentifier = selectedFriendsFromContact.map({$0.identifier})
        setMemberCountLabelText()
        if isNameTextFieldContainText && isDescriptionFieldContainText && !arrayOfIdentifier.isEmpty{
            doneBarButton.isEnabled = true
        }
        else{
            doneBarButton.isEnabled = false
        }
        
    }
    
    func insertNewFriend(at index:Int,friend:ContactDetail){
        selectedFriendsFromContact.insert(friend, at: index)
        selectedFriendsTableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        selectedFriendsTableView.layoutIfNeeded()
    }
    
}

extension NewGroupInsertionViewController{
    
    func insertFriendIntoDB(contact: ContactDetail,groupID:Int) {
        let newFriend = FriendWiseExpense(
            friendID: contact.identifier,
            name: contact.name,
            phoneNumber:contact.telephone,
            totalReturn: 0)
        
        guard let _ = tripDetailDBDelegate.inserIntoFriendWiseExpense(friend: newFriend)
        else{
            print("*** Error-insertion DB - TripDetailedViewController")
            return
        }
        groupDBDelegate.insertIntoFriendsInGroup(friend: FriendsInGroup(groupID: groupID, friendID: contact.identifier))
    }
}

extension NewGroupInsertionViewController:UITextFieldDelegate{
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == nameTextField{
        nameCharecterCountLabel.text = "0/\(maxCharacterInNameTextField)"
        }
        doneBarButton.isEnabled = false
        nameTextField.text = ""
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if isNameTextFieldContainText && isDescriptionFieldContainText && selectedFriendsFromContact.count > 0
        {doneBarButton.isEnabled = true }
        else{doneBarButton.isEnabled = false }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let currentText = textField.text as NSString? else{
            return true
        }
        let replacementString = currentText.replacingCharacters(in: range, with: string)
        if replacementString.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            isNameTextFieldContainText = false
            doneBarButton.isEnabled = false
        }
        else{
            isNameTextFieldContainText = true
            if isDescriptionFieldContainText && selectedFriendsFromContact.count > 0{
                doneBarButton.isEnabled = true
            }
            else{
                doneBarButton.isEnabled = false
            }
        }
        
        let result = replacementString.count <= maxCharacterInNameTextField
        if result{
            nameCharecterCountLabel.text = "\(replacementString.count)/\(maxCharacterInNameTextField)"
        }
        return result
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(textField.text?.isEmpty ?? true){
            textField.resignFirstResponder()
            descriptionTextView.becomeFirstResponder()
            return true
        }
        return false
    }
}

extension NewGroupInsertionViewController:UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentText = textView.text as NSString? else{
            return true
        }
        let replacementString = currentText.replacingCharacters(in: range, with: text)
        
        if replacementString.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            isDescriptionFieldContainText = false
            doneBarButton.isEnabled = false
        }
        else{
            isDescriptionFieldContainText = true
            if isNameTextFieldContainText && selectedFriendsFromContact.count > 0{
                doneBarButton.isEnabled = true
            }else{
                doneBarButton.isEnabled = false
            }
        }
        
        let result = replacementString.count <= maxCharacterInDescriptionTextField
        if result{
            descriptionCharecterCountLabel.text = "\(replacementString.count)/\(maxCharacterInDescriptionTextField)"
        }
        else{
            guard let text = textView.text else{
                return false
            }
            descriptionCharecterCountLabel.text = "\(text.count)/\(maxCharacterInDescriptionTextField)"
        }
        
        return result
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if isNameTextFieldContainText && isDescriptionFieldContainText && selectedFriendsFromContact.count > 0{
            doneBarButton.isEnabled = true
            
        }else{doneBarButton.isEnabled = false }
    }
}

extension NewGroupInsertionViewController:UIAdaptivePresentationControllerDelegate{
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        cancelButtonDidTapped()
    }
}

extension NewGroupInsertionViewController:GroupImagePickerDelegate{
    func updateImageUrlString(with urlString: String) {
        if !urlString.isEmpty{
            groupImageURLString = urlString}
        removeImageButton.isEnabled = true
        removeImageButton.isHidden = false
        addImageButton.setTitle("Edit", for: .normal)
        //        configureImage(for: imageView, with: urlString)
        getAndSetImage(for: urlString)
    }
    
    func getAndSetImage(for url:String){
        let networkDelegate:NetworkHelperDelegate = UseCase()
        networkDelegate.getImage(for: url, searchText: "", cache: imageCache as? NSCache<AnyObject,AnyObject>, onCompletion: {image,error,_,isFromCache  in
            if error != nil{
                DispatchQueue.main.async {
                    throwWarningToUser(viewController: self, title: "Error", errorMessage: error!.errorDescription!)
                }
                
            }else{
                DispatchQueue.main.async { [self] in
                    imageView.image = image
                }
            }
        })
    }
}

