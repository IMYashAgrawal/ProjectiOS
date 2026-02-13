//
//  EditHeightViewController.swift
//  HealthSharing
//
//  Created by Mohd Kushaad on 02/02/26.
//

import UIKit


class EditHeightViewController: UIViewController {

    var currentHeight: Int! = Int(DataManager.shared.currentUser!.heightCm)
    var onSave: (() -> Void)? //this helps in telling editprofile vc that data is updated when saved is pressed
    
    @IBOutlet weak var heightPicker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setViewControllerSizeAndData()
        
        heightPicker.delegate = self
        heightPicker.dataSource = self
    }
    
    // MARK: - My Functions
    
    
    func setViewControllerSizeAndData() {
        //setting size
        if let sheet = self.sheetPresentationController {
            
            // define size to quarter of screen
            let quarterDetent = UISheetPresentationController.Detent.custom(identifier: .init("quarter")) { context in
                // 25% of total height
                return max(context.maximumDetentValue * 0.5, 250)
            }
            //Apply the size
            sheet.detents = [quarterDetent]
            
            //shows grabber on the view
            sheet.prefersGrabberVisible = true
            //Ensure it stays at quarter size and doesn't expand to full screen
            sheet.largestUndimmedDetentIdentifier = .init("quarter")
            
            //setting this nil, make the weightpicker vc close when tap outside of its boundary
            sheet.largestUndimmedDetentIdentifier = nil
            //sets the background vc as uninteractive
            self.isModalInPresentation = false
        }
        
        //setting data
        heightPicker.selectRow(currentHeight-124, inComponent: 0, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // current weight is fetched form the data model
        setViewControllerSizeAndData()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let newHeight = heightPicker.selectedRow(inComponent: 0) + 124
        if newHeight != currentHeight {
            //update value
            DataManager.shared.currentUser?.heightCm = Double(newHeight)
            currentHeight = newHeight
        }
        self.onSave?()
        dismiss(animated: true)
    }
    
}

extension EditHeightViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        100
    }
    
}

extension EditHeightViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.textAlignment = .center
        
        label.font = .systemFont(ofSize: 26, weight: .regular)
        label.textColor = .label
        
        let value = 124 + row
        let unit = "cm"
        label.text = "\(value) \(unit)"
        
        return label
    }
    
}
