//
//  CameraViewController.swift
//  StickrCamera
//
//  Created by Michael A on 2017-10-30.
//  Copyright © 2017 AI Labs. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    
    @IBOutlet weak var photoCollectionImageView: UIImageView!
    
    @IBOutlet weak var switchCameraButton: UIButton!
    
    @IBOutlet weak var flashButton: UIButton!
    
    @IBOutlet weak var topContainerView: UIView!
    
    @IBOutlet weak var capturePhotoButton: UIButton!
    
    @IBOutlet weak var cameraView: UIView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var editLabel: UILabel!
    
    @IBOutlet weak var moreButton: UIButton!
    
    private let session = AVCaptureSession()
    
    private var previewLayer:AVCaptureVideoPreviewLayer?
    
    private var isCameraAccessGiven = false
    
    private var isPhotoLibraryAccessGiven = false
    
    private var isFlashOn = false
    
    private var cameraDeviceInput: AVCaptureDeviceInput!
    
    private let sessionQueue = DispatchQueue(label: "SessionQueue")
    
    private let photoOutput = AVCapturePhotoOutput()
    
    private var previewImageView:UIImageView?
    
    private var previewImage:UIImage?
    
    private var selectedStickerImage:UIImage?
    
    private var selectedFilterImage:UIImage?
    
    private var imageOrientation:UIImageOrientation = .right
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInDualCamera],mediaType: .video,position: .unspecified)
    
    private let filterCollectionCellIdentifier = "FilterCell"
    
    private let addStickerVCSegueIdentifier = "ShowStickerVC"
    
    private let filterVCSegueIdentifier = "ShowFilterVC"
    
    private lazy var cancelButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var saveButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 14)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var stickerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stickers", for: .normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 18)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.setImage(#imageLiteral(resourceName: "sticker_icon"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        button.addTarget(self, action: #selector(didTapStickerButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Filters", for: .normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 18)
        button.setImage(#imageLiteral(resourceName: "blur_Icon"), for: .normal)
        button.tintColor = .black
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didFilterButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private var isRotating = false
    
    private var identity = CGAffineTransform.identity
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.selectedStickerImage = nil
        self.selectedFilterImage = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    private func requestCameraAccess() {
        print("requesting access....")
        self.capturePhotoButton.isEnabled = false
        self.switchCameraButton.isEnabled = false
        
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (granted) in
            guard let _self = self else {return}
            _self.isCameraAccessGiven = granted
            if _self.isCameraAccessGiven {
                self?.startConfiguration()
                DispatchQueue.main.async {
                    _self.capturePhotoButton.isEnabled = true
                    _self.switchCameraButton.isEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    _self.requestCameraAccessAlertView()
                }
            }
        })
    }
    
    private func requestCameraAccessAlertView() {
        let messageView = CustomMessageBox(frame: view.frame)
        let attributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17)]
        let attributedTitle = NSMutableAttributedString(string: "Open Settings", attributes: attributes)
        messageView.alertTitleLabel.text = "Stickr Cam needs permission to use camera"
        messageView.actionButton.setAttributedTitle(attributedTitle, for: .normal)
        messageView.messageViewCameraVCDelegate = self
        view.addSubview(messageView)
    }
    
    private func requestPhotoAccessAlertView() {
        let messageView = CustomMessageBox(frame: view.frame)
        let attributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17)]
        messageView.alertTitleLabel.text = "Stickr Cam doesn't have permission to use the photos"
        let attributedTitle = NSMutableAttributedString(string: "Open Settings", attributes: attributes)
        messageView.actionButton.setAttributedTitle(attributedTitle, for: .normal)
        messageView.messageViewCameraVCDelegate = self
        view.addSubview(messageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthStatus {
        case .authorized:
            self.isCameraAccessGiven = true
            self.startConfiguration()
            break
        case .denied:
            self.isCameraAccessGiven = false
            break
        case .notDetermined:
            self.isCameraAccessGiven = false
            break
        default:
            break
        }
        
        let photoAuthStatus = PHPhotoLibrary.authorizationStatus()
        if photoAuthStatus == .authorized {
            isPhotoLibraryAccessGiven = true
        } else if photoAuthStatus == .denied {
            isPhotoLibraryAccessGiven = false
        } else if photoAuthStatus == .notDetermined {
            isPhotoLibraryAccessGiven = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isCameraAccessGiven {
            requestCameraAccess()
        }
        
        if !isPhotoLibraryAccessGiven {
            requestPhotoAccess()
            photoCollectionImageView.isUserInteractionEnabled = false
        } else {
            self.getPhotos()
            photoCollectionImageView.isUserInteractionEnabled = true
        }
    }
    
    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                self.isPhotoLibraryAccessGiven = true
                self.getPhotos()
                DispatchQueue.main.async {
                    self.photoCollectionImageView.isUserInteractionEnabled = true
                }
                break
            case .notDetermined, .denied:
                self.isPhotoLibraryAccessGiven = false
                DispatchQueue.main.async {
                    self.requestPhotoAccessAlertView()
                }
                break
            default:
                break
            }
        }
    }
    
    private func getPhotos() {
        if isPhotoLibraryAccessGiven {
            DispatchQueue.global(qos: .background).async {
                let allPhotos = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
                let imageManager = PHImageManager()
                let imageOptions = PHImageRequestOptions()
                guard let firstPhotoAsset = allPhotos.lastObject else { print("failed to get image"); return}
                
                DispatchQueue.main.async { [weak self] in
                    guard let _self = self else {return}
                    let size = _self.photoCollectionImageView.frame.size
                    imageManager.requestImage(for: firstPhotoAsset, targetSize: size, contentMode: .aspectFill, options: imageOptions, resultHandler: { (image, nil) in
                        guard let image = image else {
                            print("Could not retreive image")
                            return
                        }
                        DispatchQueue.main.async {
                            _self.photoCollectionImageView.image = image
                        }
                    })
                }
            }
        }
    }
    
    private func saveImageToPhotoLibrary(completionHandler:(Bool)->()) {
        guard let previewImageView = self.previewImageView, let keyWindow = UIApplication.shared.keyWindow else {
            completionHandler(false)
            return
        }
        
        let topDarkOverlay = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60))
        topDarkOverlay.backgroundColor = .black
        topContainerView.addSubview(topDarkOverlay)
        
        let bottomDarkOverlay = UIView(frame: CGRect(x: 0, y: keyWindow.frame.height - 100, width: view.frame.width, height: 100))
        bottomDarkOverlay.backgroundColor = .black
        keyWindow.addSubview(bottomDarkOverlay)
        
        previewImageView.frame = CGRect(x: 0, y: -40, width: keyWindow.frame.width, height: keyWindow.frame.height - 100 - 40)
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(previewImageView.bounds.size, false, scale) // reconsider size property for your screenshot
        keyWindow.layer.render(in: UIGraphicsGetCurrentContext()!)
        print(previewImageView.layer.frame.size,
              previewImageView.bounds.size)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(screenshot!, self, nil, nil)
        
        previewImageView.removeFromSuperview()
        topDarkOverlay.removeFromSuperview()
        bottomDarkOverlay.removeFromSuperview()
        completionHandler(true)
    }
    
    private func handleCameraToggle() {
        UIView.animate(withDuration: 0.5, animations: {
            self.switchCameraButton.transform =  CGAffineTransform(rotationAngle: CGFloat.pi)
        }, completion: { _ in
            self.switchCameraButton.transform = CGAffineTransform(rotationAngle: 0)
        })
        
        sessionQueue.async {
            let currentVideoDevice = self.cameraDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
                self.imageOrientation = .right
                
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInWideAngleCamera
                self.imageOrientation = .leftMirrored
            }
            
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    self.session.removeInput(self.cameraDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        self.session.addInput(videoDeviceInput)
                        self.cameraDeviceInput = videoDeviceInput
                        
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        
                    } else {
                        self.session.addInput(self.cameraDeviceInput)
                    }
                    self.session.commitConfiguration()
                } catch {
                    print("Error occured while creating video device input: \(error)")
                }
            }
        }
    }
    
    @IBAction func toggleFrontOrBackCamera(_ sender: Any) {
        handleCameraToggle()
    }
    
    @objc
    private func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(focusMode: .continuousAutoFocus, exposureMode: .continuousAutoExposure, atPoint: devicePoint, monitorSubjectAreaChange: false)
    }
    
    private func startConfiguration() {
        if !isCameraAccessGiven {
            return
        }
        
        DispatchQueue.main.async {
            self.capturePhotoButton.isEnabled = true
            self.switchCameraButton.isEnabled = true
        }
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            // Choose the back dual camera if available, otherwise default to a wide angle camera.
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                defaultVideoDevice = frontCameraDevice
            }
            
            guard let captureDev = defaultVideoDevice  else {
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: captureDev)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.cameraDeviceInput = videoDeviceInput
                
                previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer?.videoGravity = .resizeAspectFill
                DispatchQueue.main.async {
                    self.previewLayer?.frame = CGRect(x: 0, y: 0, width: self.cameraView.frame.width, height: self.cameraView.frame.height)
                    self.previewLayer?.masksToBounds = true
                    self.cameraView.layer.addSublayer(self.previewLayer!)
                }
                session.commitConfiguration()
                session.startRunning()
                
            } else {
                print("Could not add video device input to the session")
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            session.commitConfiguration()
            return
        }
        // Add outputs
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        }
        session.commitConfiguration()
    }
    
    @IBAction func capturePhotoButtonTapped(_ sender: Any) {
        sessionQueue.async {
            DispatchQueue.main.async {
                guard let keyWindow = UIApplication.shared.keyWindow else {
                    return
                }
                let darkOverLayView = UIView()
                darkOverLayView.backgroundColor = .black
                darkOverLayView.frame = keyWindow.frame
                darkOverLayView.alpha = 0
                keyWindow.addSubview(darkOverLayView)
                
                if !self.isCameraAccessGiven {
                    return
                }
                self.handlePhotoCapture()
                UIView.animate(withDuration: 0.25, animations: {
                    darkOverLayView.alpha = 1
                    
                }) { (success) in
                    UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
                        darkOverLayView.alpha = 0
                        
                    }, completion: nil)
                }
                self.showEditingTools()
            }
        }
    }
    
    private func handlePhotoCapture() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
        }
        
        if self.cameraDeviceInput.device.isFlashAvailable {
            if isFlashOn {
                photoSettings.flashMode = .on
            } else {
                photoSettings.flashMode = .off
            }
        }
        self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc private func didTapCameraScreen(_ gestureRecognizer:UITapGestureRecognizer) {
        guard let devicePoint = previewLayer?.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view)) else {
            return
        }
        let locationOnScreen = gestureRecognizer.location(in: self.view)
        
        let focusView = UIImageView()
        focusView.image = #imageLiteral(resourceName: "focus")
        let size =  CGSize(width: 86, height: 75)
        focusView.frame = CGRect(origin: locationOnScreen, size: size)
        self.previewLayer?.addSublayer(focusView.layer)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            
        }) { (sucess) in
            focusView.layer.removeFromSuperlayer()
        }
        focus(focusMode: .autoFocus, exposureMode: .autoExpose, atPoint: devicePoint, monitorSubjectAreaChange: true)
    }
    
    private func focus(focusMode:AVCaptureDevice.FocusMode, exposureMode:AVCaptureDevice.ExposureMode, atPoint devicePoint:CGPoint, monitorSubjectAreaChange:Bool) {
        sessionQueue.async {
            let currentDevice = self.cameraDeviceInput.device
            do {
                try currentDevice.lockForConfiguration()
                
                if currentDevice.isFocusPointOfInterestSupported && currentDevice.isFocusModeSupported(focusMode) {
                    currentDevice.focusPointOfInterest = devicePoint
                    currentDevice.focusMode = focusMode
                }
                if currentDevice.isExposurePointOfInterestSupported && currentDevice.isExposureModeSupported(exposureMode) {
                    currentDevice.exposurePointOfInterest = devicePoint
                    currentDevice.exposureMode = exposureMode
                }
                currentDevice.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                currentDevice.unlockForConfiguration()
            }
            catch let err {
                print(err.localizedDescription)
            }
        }
    }
    
    @objc
    private func didTapPhotoCollectionImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { [weak self] in
            self?.photoCollectionImageView.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
        }) { [weak self] (_) in
            self?.photoCollectionImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    @objc
    private func didTapChangeCameraScreen(_ gesture:UITapGestureRecognizer) {
        handleCameraToggle()
    }
    
    @IBAction func flashButtonTapped(_ sender: Any) {
        isFlashOn = !isFlashOn
        if isFlashOn {
            flashButton.setImage(#imageLiteral(resourceName: "flash_icon"), for: .normal)
        } else {
            flashButton.setImage(#imageLiteral(resourceName: "flash_icon_off"), for: .normal)
        }
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        let moreVC = MoreViewController()
        present(moreVC, animated: true, completion: nil)
    }
    
    @objc
    private func handleSave() {
        if !isPhotoLibraryAccessGiven {
            let messageView = CustomMessageBox(frame: view.frame)
            let attributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17)]
            let attributedTitle = NSMutableAttributedString(string: "Open Settings", attributes: attributes)
            messageView.alertTitleLabel.text = "Stickr Cam doesn't have permission to use the photos"
            messageView.actionButton.setAttributedTitle(attributedTitle, for: .normal)
            messageView.messageViewCameraVCDelegate = self
            view.addSubview(messageView)
            return
        }
        if let previewLayer = self.previewLayer {
            previewLayer.opacity = 1
        }
        saveImageToPhotoLibrary(completionHandler: { (success) in
            if success {
                let messageView = CustomMessageBox(frame: view.frame)
                messageView.alertTitleLabel.text = "Successfully Saved Photo to Library"
                let attributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17)]
                let attributedTitle = NSMutableAttributedString(string: "Okay Done", attributes: attributes)
                messageView.actionButton.setAttributedTitle(attributedTitle, for: .normal)
                messageView.cancelButton.isHidden = true
                messageView.messageViewCameraVCDelegate = self
                view.addSubview(messageView)
                
            } else {
                print("error saving")
                if let previewLayer = self.previewLayer {
                    previewLayer.opacity = 1
                }
                
                let messageView = CustomMessageBox(frame: view.frame)
                messageView.alertTitleLabel.text = "Error Saving Photo to Library, Please Retry"
                messageView.cancelButton.isHidden = true
                let attributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 17)]
                let attributedTitle = NSMutableAttributedString(string: "Okay", attributes: attributes)
                messageView.actionButton.setAttributedTitle(attributedTitle, for: .normal)
                view.addSubview(messageView)
            }
        })
    }
    
    private func showEditingTools() {
        cancelButton.isHidden = false
        moreButton.isHidden = true
        editLabel.isHidden = false
        saveButton.isHidden = false
        flashButton.isHidden = true
        capturePhotoButton.isHidden = true
        switchCameraButton.isHidden = true
        photoCollectionImageView.isHidden = true
        setupEditingViews()
    }
    
    @objc
    private func handleCancel() {
        if let previewLayer = self.previewLayer {
            previewLayer.opacity = 1
        }
        cancelButton.isHidden = true
        moreButton.isHidden = false
        flashButton.isHidden = false
        saveButton.isHidden = true
        editLabel.isHidden = true
        capturePhotoButton.isHidden = false
        switchCameraButton.isHidden = false
        photoCollectionImageView.isHidden = false
        stickerButton.isHidden = true
        filterButton.isHidden = true
        previewImageView?.removeFromSuperview()
    }
    
    @objc
    private func didTapStickerButton() {
        performSegue(withIdentifier: addStickerVCSegueIdentifier, sender: self)
    }
    
    @objc
    private func didFilterButton() {
        performSegue(withIdentifier: filterVCSegueIdentifier, sender: self)
    }
    
    private func setupViews() {
        photoCollectionImageView.layer.cornerRadius = 5
        photoCollectionImageView.layer.masksToBounds = true
        photoCollectionImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPhotoCollectionImage)))
        let changeFocusGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCameraScreen(_:)))
        changeFocusGesture.numberOfTapsRequired = 1
        cameraView.addGestureRecognizer(changeFocusGesture)
        
        let changeCameraGesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeCameraScreen(_:)))
        changeCameraGesture.numberOfTapsRequired = 2
        cameraView.addGestureRecognizer(changeCameraGesture)
        
        topContainerView.addSubview(saveButton)
        saveButton.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: topContainerView.rightAnchor, rightConstant: -10, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        saveButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        
        topContainerView.addSubview(cancelButton)
        cancelButton.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: topContainerView.leftAnchor, leftConstant: 10, rightAnchor: nil, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        cancelButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
    }
    
    private func setupEditingViews() {
        containerView.addSubview(stickerButton)
        stickerButton.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: containerView.leftAnchor, leftConstant: 30, rightAnchor: nil, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 110)
        stickerButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        stickerButton.isHidden = false
        
        containerView.addSubview(filterButton)
        filterButton.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: containerView.rightAnchor, rightConstant: -30, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 110)
        filterButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        filterButton.isHidden = false
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard let photoSampleBuffer = photoSampleBuffer else {return}
        guard let previewPhotoSampleBuffer = previewPhotoSampleBuffer else {return}
        guard let jpegData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else { return }
        
        let previewImage = UIImage(data: jpegData)?.cgImage
        let finalImage = UIImage(cgImage: previewImage!, scale: 1.0, orientation: imageOrientation)
        
        previewImageView = UIImageView(image: finalImage)
        previewImageView?.contentMode = .scaleAspectFill
        previewImageView?.clipsToBounds = true
        
        cameraView.addSubview(previewImageView!)
        previewImageView?.anchorConstraints(topAnchor: cameraView.topAnchor, topConstant: 0, leftAnchor: cameraView.leftAnchor, leftConstant: 0, rightAnchor: cameraView.rightAnchor, rightConstant: 0, bottomAnchor: containerView.topAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        self.previewImage = finalImage
    }
}

extension CameraViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == filterVCSegueIdentifier {
            if let destinationVC = segue.destination as? FilterViewController {
                destinationVC.delegate = self
                guard let image = previewImage else {
                    print("preview image is nil")
                    return
                }
                if let selectedStickerImage = selectedStickerImage {
                    destinationVC.image = selectedStickerImage
                } else {
                    destinationVC.image = image
                }
            }
            
        } else if segue.identifier == addStickerVCSegueIdentifier {
            if let destinationVC = segue.destination as? AddStickerViewController {
                guard let image = previewImage else {
                    print("preview image is nil")
                    return
                }
                if let selectedFilterImage = selectedFilterImage {
                    destinationVC.image = selectedFilterImage
                } else {
                    destinationVC.image = image
                }
                destinationVC.delegate = self
            }
        }
    }
}

extension CameraViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage:UIImage?
        
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        } else if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        }
        guard let image = selectedImage else { return }
        previewImageView = UIImageView(image: image)
        previewImageView?.contentMode = .scaleAspectFill
        previewImageView?.clipsToBounds = true
        cameraView.addSubview(previewImageView!)
        self.previewImage = image
        previewImageView?.anchorConstraints(topAnchor: topContainerView.bottomAnchor, topConstant: 0, leftAnchor: cameraView.leftAnchor, leftConstant: 0, rightAnchor: cameraView.rightAnchor, rightConstant: 0, bottomAnchor: cameraView.bottomAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        dismiss(animated: true) {
            self.showEditingTools()
        }
    }
}

extension CameraViewController: AddStickerViewDelegate {
    func didSelectSticker(_ image: UIImage) {
        previewImageView?.image = image
        self.selectedStickerImage = image
    }
}

extension CameraViewController: FilterViewControllerDelegate {
    func didChooseFilter(_ image: UIImage) {
        previewImageView?.image = image
        selectedFilterImage = image
    }
}

extension CameraViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CameraViewController: CustomMessageCameraVCDelegate {
    func didTapDismissButton() { handleCancel() }
    func didTapOpenSettingsButton() {
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}












