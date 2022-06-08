//
//  NewFriendViewController.swift
//  customContactPIcker
//
//  Created by Praveenraj T on 19/04/22.
//

import UIKit

protocol NewContactDelegate:AnyObject{
    func willAddFriend(friend:ContactDetail)
}

class NewContactViewController: UIViewController {

    let scrollView = UIScrollView()

    var newContactDelegate:NewContactDelegate?
    let tripDetailDBDelegate : TripDetailDBDelegate = UseCase()
    
    lazy var nameLabel:UILabel = {
        let label = UILabel()
        let required = NSMutableAttributedString(string: "* ", attributes: [.foregroundColor : UIColor.systemRed])
        required.append(NSAttributedString(string: "Contact Name"))
        label.attributedText = createMandatoryText(for: "Contact Name")
        
        return label
    }()
    
    lazy var nameTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = " Enter Contact Name"
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        
        textField.leftViewMode = .always
        
        return textField
    }()
    
    lazy var contactNumberLabel:UILabel = {
       let label = UILabel()
        let required = NSMutableAttributedString(string: "* ", attributes: [.foregroundColor : UIColor.systemRed])
        required.append(NSAttributedString(string: "Contact Number"))
        label.attributedText = createMandatoryText(for: "Contact Number")

       return label
   }()
    
    lazy var phoneNumberTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = " Enter Contact  Number"
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.keyboardType = .phonePad
        textField.delegate = self
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.leftViewMode = .always

        return textField
   }()
    let warningLabel :UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        return label
    }()
    
    lazy var doneBarButton:UIBarButtonItem = {
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTapped))
        done.isEnabled  = false
        return done
    }()
    
    let containerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        isModalInPresentation = true
        navigationController?.presentationController?.delegate = self
        
        configureScrollView()
        configureNameLabel()
        configureNameTextField()
        configurePhoneNumberNameLabel()
        configurePhoneNumerTextField()
        configureWarningLabel()
        configureNavigationBar()
        updateUIWhileKeyboardApperance()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
        
    }
    
    func configureNavigationBar(){
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTapped))
    }
    
    func updateUIWhileKeyboardApperance(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func doneButtonDidTapped(){
        scrollViewDidTapped()
        
        guard let name = nameTextField.text else{
            print("***Error while unwrapping name")
            return
        }
        guard let phoneNumber = phoneNumberTextField.text else{
            print("***Error while unwrapping phoneNumber")
            return
        }
        
        if !isPhoneNumber(numberString: phoneNumber){
            warningLabel.text = "* Invalid Contact Number"
        }else{
            let newContact = ContactDetail(
                identifier: "Levy-\(phoneNumber)-"+NSUUID().uuidString,
                name: name,
                telephone: phoneNumber)
            
            newContactDelegate?.willAddFriend(friend:newContact )
            
            let newFriend = FriendWiseExpense(
                friendID: newContact.identifier,
                name: newContact.name,
                phoneNumber:newContact.telephone,
                totalReturn: 0)
            
                guard let _ = tripDetailDBDelegate.inserIntoFriendWiseExpense(friend: newFriend)
                else{
                    print("*** Error-insertion DB - TripDetailedViewController")
                    return
                }
            dismiss(animated: true)
        }
    }

    @objc func cancelButtonDidTapped(){
        scrollViewDidTapped()
        let isNotEmpty = !(nameTextField.text?.isEmpty ?? true) || !(phoneNumberTextField.text?.isEmpty ?? true)
        if doneBarButton.isEnabled || isNotEmpty{
            let alerSheet = UIAlertController(title: nil, message: "Are you sure you want to discard  new contact details?", preferredStyle: .actionSheet)
            alerSheet.addAction(UIAlertAction(title: "Keep Editing", style: .cancel, handler: nil))
            alerSheet.addAction(UIAlertAction(title: "Discard Changes", style: .destructive, handler: {_ in
                self.dismiss(animated: true, completion: nil)
            }))
            alerSheet.popoverPresentationController?.sourceView = self.view
            let xOrigin = 0
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            alerSheet.popoverPresentationController?.sourceRect = popoverRect
            alerSheet.popoverPresentationController?.permittedArrowDirections = .up
            present(alerSheet,animated: true)
        }else{
            dismiss(animated: true)}
    }
}

extension NewContactViewController:UITextFieldDelegate{
    func isPhoneNumber( numberString:String)-> Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: numberString, options: [], range: NSRange(location: 0, length: numberString.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == numberString.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let currentText = textField.text as? NSString else{
            return true
        }
        let replacementString = currentText.replacingCharacters(in: range, with: string)
        
        if textField == nameTextField{
            if phoneNumberTextField.isContainText()  && !replacementString.isEmpty{
                doneBarButton.isEnabled = true
            }
            else{
                doneBarButton.isEnabled = false
            }
            return true
        }else{
            let allowedCharacters = CharacterSet.letters.inverted
            let characterSet = CharacterSet(charactersIn: replacementString)
            let isValidCharacter = allowedCharacters.isSuperset(of: characterSet)
            
            if !isValidCharacter{
                print("invalid phone number")
                return false
            }
            
            if nameTextField.isContainText()  && !replacementString.isEmpty{
                doneBarButton.isEnabled = true
                if isPhoneNumber(numberString: replacementString){
                    warningLabel.text = nil}
            }
            else{
                doneBarButton.isEnabled = false
            }
            return true
        }
        
    }
}

extension NewContactViewController{
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
            
        }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
}

extension NewContactViewController{
    func configureScrollView(){
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 10),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)

        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewDidTapped))
        scrollView.addGestureRecognizer(tap)
        scrollView.isUserInteractionEnabled = true
        containerView.isUserInteractionEnabled = true
        
        
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor,constant: 10),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
        ])
        
    }
    
    @objc func scrollViewDidTapped(){
        nameTextField.resignFirstResponder()
        phoneNumberTextField.resignFirstResponder()
    }
    
    func configureNameLabel(){
        containerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            nameLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configureNameTextField(){
        containerView.addSubview(nameTextField)
        nameTextField.delegate = self
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: 3),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            nameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configurePhoneNumberNameLabel(){
        containerView.addSubview(contactNumberLabel)
        contactNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contactNumberLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor,constant: 20),
            contactNumberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10),
            contactNumberLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -10),
            contactNumberLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configurePhoneNumerTextField(){
        containerView.addSubview(phoneNumberTextField)
        phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            phoneNumberTextField.topAnchor.constraint(equalTo: contactNumberLabel.bottomAnchor, constant: 3),
            phoneNumberTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            phoneNumberTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            //phoneNumberTextField.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    func configureWarningLabel(){
        containerView.addSubview(warningLabel)
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            warningLabel.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 3),
            warningLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            warningLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            warningLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            warningLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
}
extension NewContactViewController:UIAdaptivePresentationControllerDelegate{
     func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        cancelButtonDidTapped()
    }
}
