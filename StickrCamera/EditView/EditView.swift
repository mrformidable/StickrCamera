//
//  EditView.swift
//  StickrCamera
//
//  Created by Michael A on 2017-11-02.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit

protocol EditViewDelegate: class {
    func didTapCancelButton()
    func didTapDoneButton()
    func sliderValueDidChange(_ value:Float)
}

class EditContainerView: UIView {
    
   private let editLabel:UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "Brightness"
        return lb
    }()
    
   private lazy var cancelEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var doneEditButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        return button
    }()
    
     lazy var editSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.value = 0
        slider.minimumValue = -1
        slider.maximumValue = 1
        slider.minimumTrackTintColor = .black
        slider.maximumTrackTintColor = UIColor.groupTableViewBackground
        slider.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: UIControlEvents.valueChanged)
        return slider
    }()
    
    weak var delegate:EditViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
   @objc private func didTapCancelButton() {
        print("cancel button tappped")
        delegate?.didTapCancelButton()
    }
    
    @objc private func didTapDoneButton() {
        print("edit button tappped")
        delegate?.didTapDoneButton()
    }
    
    @objc private func sliderDidChangeValue(_ sender:UISlider) {
        delegate?.sliderValueDidChange(sender.value)
    }
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(editLabel)
        addSubview(cancelEditButton)
        addSubview(doneEditButton)
        addSubview(editSlider)
        
        editLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        editLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        editLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        cancelEditButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        cancelEditButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        
        doneEditButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        doneEditButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        
        editSlider.topAnchor.constraint(equalTo: editLabel.bottomAnchor, constant: 5).isActive = true
        editSlider.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        editSlider.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        editSlider.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}









