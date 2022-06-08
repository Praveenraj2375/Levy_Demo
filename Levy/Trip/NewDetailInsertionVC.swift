//
//  NewDetailInsertionVC.swift
//  Levy
//
//  Created by Praveenraj T on 08/03/22.
//

import UIKit

protocol NewDetailInsertionVCDelegate{
    func insertIntoTableView()
}


class NewDetailInsertionVC: UIViewController {
    static let NameCharactersLimit = 20
    var maxCharacterInTextField = NewDetailInsertionVC.NameCharactersLimit
    
    var delegate:NewDetailInsertionVCDelegate?
    weak var presentingGroupVC:GroupDetailedViewController?
    let groupDetailDBDelegate:GroupDetailDBDelegate = UseCase()
    var groupID:Int?
    
    lazy var selectedDateString = String()
    lazy var selectedDate = Date()
    let scrollView = UIScrollView()
    
    
    lazy var  dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.attributedText = createMandatoryText(for: "Trip Name")
        return label
    }()
    
    lazy var nameCharecterCountLabel:UILabel = {
        let label = UILabel()
        label.text = "0/\(maxCharacterInTextField)"
        label.textColor = .secondaryLabel
        return label
    }()
    
    lazy var dateLabel:UILabel = {
        let label = UILabel()
        label.text = "Trip Start Date "
        return label
    }()
    
    lazy var nameTextField:UITextField = {
        let textField = UITextField()
        textField.placeholder = " Enter Trip Name"
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.clearButtonMode = .whileEditing
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.leftViewMode = .always
        
        return textField
    }()
    
    lazy var doneBarButton:UIBarButtonItem = {
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTapped))
        done.isEnabled  = false
        return done
    }()
    
    lazy var minDateComponent:DateComponents = {
        var datecomp = DateComponents()
        datecomp.year = 2010
        datecomp.month = 1
        datecomp.day = 1
        return datecomp
    }()
    
    lazy var datePickerView : UIDatePicker = {
        var datePick = UIDatePicker()
        datePick.setDate(Date(), animated: false)
        datePick.minimumDate = Calendar.current.date(from:minDateComponent)
        datePick.maximumDate = Date(timeIntervalSinceNow: 60*60*24*365)
        datePick.datePickerMode = .date
        
        if #available(iOS 14.0, *) {
            datePick.preferredDatePickerStyle = .compact
        }

        return datePick
    }()
    
    let containerView = UIView()
    
    lazy var calenderButton:UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = myThemeColor
        button.setImage(UIImage(systemName:"calendar"), for: .normal)
        return button
    }()
    
    lazy var dateTextField:UITextField = {
        let textField = UITextField()
        textField.textColor = myThemeColor
        textField.text = dateFormatter.string(from:  datePickerView.date)
        return textField
    }()
    
    var pickerToolbar:UIToolbar?
    
    lazy var dateLabelBottom = dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
    
    init(){
        super.init(nibName: nil, bundle:nil)
    }
    
    init(groupID:Int){
        super.init(nibName: nil, bundle: nil)
        self.groupID = groupID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.isUserInteractionEnabled = true
        
        title = "New Trip"
        selectedDateString = dateFormatter.string(from: datePickerView.date)
        selectedDate = datePickerView.date
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidTapped))
        
        self.isModalInPresentation = true
        configureScrollView()
        configureNameLabel()
        configureCharecterCountLabel()
        configureNameTextField()
        configureDateLabel()

        if #available(iOS 14.0, *){
            configureDatePicker()
        }else{
            configureCalenderButton()
            configureWheelDatePicker()
        }
        
        configureUIForKeyboardInteraction()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
        
    }
   
    func configureUIForKeyboardInteraction(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
   
   
    @objc func calenderDidTapped(){
        dateTextField.becomeFirstResponder()
    }
    
    
    func configureCalenderButton(){
        containerView.addSubview(calenderButton)

        calenderButton.addTarget(self, action: #selector(calenderDidTapped), for: .touchUpInside)
        calenderButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calenderButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -10),
            calenderButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor)
        ])
    }
    
    func  configureWheelDatePicker(){
        
        containerView.addSubview(dateTextField)
        datePickerView.addTarget(self, action: #selector(dateDidChanged), for: .valueChanged)
        
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateTextField.topAnchor.constraint(lessThanOrEqualTo: dateLabel.topAnchor),
            dateTextField.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            dateTextField.leadingAnchor.constraint(greaterThanOrEqualTo: dateLabel.trailingAnchor, constant: 20),
            dateTextField.trailingAnchor.constraint(equalTo: calenderButton.leadingAnchor,constant: -10),
        ])
        
        
        configurePickerToolBar()
        
        dateTextField.inputView = datePickerView
        dateTextField.inputAccessoryView = pickerToolbar
    }
    
    func configurePickerToolBar(){
        pickerToolbar = UIToolbar()
        pickerToolbar?.autoresizingMask = .flexibleHeight
        pickerToolbar?.barTintColor = UIColor.systemBlue
//        pickerToolbar?.isTranslucent = false
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(cancelBtnClicked(_:)))
        cancelButton.tintColor = UIColor.white
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBtnClicked(_:)))
        doneButton.tintColor = UIColor.white
        pickerToolbar?.items = [cancelButton, flexSpace, doneButton]
    }
    
   
    @objc func cancelBtnClicked(_ button: UIBarButtonItem?) {
        dateTextField.resignFirstResponder()
    }
        
    @objc func doneBtnClicked(_ button: UIBarButtonItem?) {
        dateTextField.resignFirstResponder()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        dateTextField.text = dateFormatter.string(from: datePickerView.date)
        selectedDateString = dateFormatter.string(from: datePickerView.date)
        selectedDate = datePickerView.date
    }
    
    func configureScrollView(){
        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 10),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollViewDidTapped))
        scrollView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true
        
        
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor,constant: 10),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor)
        ])
        
    }
    
    @objc func scrollViewDidTapped(){
        nameTextField.resignFirstResponder()
        datePickerView.resignFirstResponder()
        dateTextField.resignFirstResponder()
        presentedViewController?.dismiss(animated: true)

    }
    
    func configureNameLabel(){
        containerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor,constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: 10),
            nameLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configureCharecterCountLabel(){
        containerView.addSubview(nameCharecterCountLabel)
        
        nameCharecterCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameCharecterCountLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            nameCharecterCountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            nameCharecterCountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 10),
        ])
    }
    
    func configureNameTextField(){
        containerView.addSubview(nameTextField)
        nameTextField.delegate = self
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,constant: 5),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            nameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureDateLabel(){
        containerView.addSubview(dateLabel)
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            dateLabelBottom
        ])
    }
    
    func configureDatePicker(){
        containerView.addSubview(datePickerView)
        datePickerView.addTarget(self, action: #selector(dateDidChanged), for: .valueChanged)
        
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePickerView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8.0),
            datePickerView.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            datePickerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -10)
        ])
    }
    
    @objc  func cancelButtonDidTapped(){
        nameTextField.resignFirstResponder()
        if doneBarButton.isEnabled{
            let alerSheet = UIAlertController(title: nil, message: "Are you sure you want to discard this new trip?", preferredStyle: .actionSheet)
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
        }
        else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc  func doneButtonDidTapped(){
        nameTextField.resignFirstResponder()
        let tripDetailDelgate:TripListDelegate = UseCase()
        guard let tripName = nameTextField.text else{
            print("trip name field text retrivel error @ NewDetailInsertionVC")
            return
        }
        
        guard let newTrip = tripDetailDelgate.insertNewTripIntoDB(tripName: tripName, date: selectedDateString, groupID: groupID ?? 0) else {
            print("*** Error: newtrip unwrap error - NewDetailInsertionVC")
            let actionSheet = UIAlertController(title: "Error", message: "Not able to insert new Value into DB", preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            actionSheet.popoverPresentationController?.sourceView = self.view
            let xOrigin = 0
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            actionSheet.popoverPresentationController?.sourceRect = popoverRect
            actionSheet.popoverPresentationController?.permittedArrowDirections = .up

            present(actionSheet,animated: true)
            return
        }
        
        if groupID != nil && groupID != 0{
            let tripDetailDBDelegate:TripDetailDBDelegate = UseCase()
            let friendsInGroup = groupDetailDBDelegate.getFriendsInGroup(for: groupID!)
        
            for friend in friendsInGroup{
             let _ =   tripDetailDBDelegate.insertIntoFriendsInTrip(value: FriendsInTrip(tripID: newTrip.tripID, friendID: friend.friendID, friendName: " ", friendPhoneNumber: " "))
            }
        }
        presentingGroupVC?.bringDataForUI()
        delegate?.insertIntoTableView()
        isNewTripAdded = true
        dismiss(animated: true, completion: nil)
    }
    
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
      
    
    @objc func dateDidChanged(){
        datePickerView.resignFirstResponder()

        let old = selectedDate.timeIntervalSince1970
        let picked = datePickerView.date.timeIntervalSince1970
        if old != picked{
            presentedViewController?.dismiss(animated: true)
        }
        
        selectedDateString = dateFormatter.string(from: datePickerView.date)
        selectedDate = datePickerView.date
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.resignFirstResponder()
        presentedViewController?.dismiss(animated: true)
    }
    
}

extension NewDetailInsertionVC : UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
  
        guard let currentText = textField.text as NSString? else{
            return true
        }
        let replacementString = currentText.replacingCharacters(in: range, with: string)
        if replacementString.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            doneBarButton.isEnabled = false
        }
        else{
            doneBarButton.isEnabled = true
        }
        
        let result = replacementString.count <= maxCharacterInTextField
        if result{
            nameCharecterCountLabel.text = "\(replacementString.count)/\(maxCharacterInTextField)"
        }
        else{
            guard let text = textField.text else{
                return false
            }
            nameCharecterCountLabel.text = "\(text.count)/\(maxCharacterInTextField)"
        }
        return result
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            doneBarButton.isEnabled = false
        }
        else{
            doneBarButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if doneBarButton.isEnabled{
            doneButtonDidTapped()
            return true
        }
        else{
            return false
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        nameCharecterCountLabel.text = "0/\(maxCharacterInTextField)"
        doneBarButton.isEnabled = false
        return true
    }
}

extension NewDetailInsertionVC:UIAdaptivePresentationControllerDelegate{
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        cancelButtonDidTapped()
    }
}
