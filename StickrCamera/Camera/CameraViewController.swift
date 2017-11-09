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
   
    @IBOutlet weak var optionsButton: UIButton!
    
    private let session = AVCaptureSession()
    
    private var previewLayer:AVCaptureVideoPreviewLayer?
    
    private var isCameraAccessGiven = false
    
    private var isPhotoLibraryAccessGiven = false
    
    private var isFlashOn = false
    
    private var cameraDeviceInput: AVCaptureDeviceInput!
    
    private let sessionQueue = DispatchQueue(label: "SessionQueue")
    
    private let photoOutput = AVCapturePhotoOutput()
    
    private var previewImageView:UIImageView?
    
    var previewImage:UIImage?
    
    private var blackOverlayView:UIView?
    
    private var imageOrientation:UIImageOrientation = .right
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInDualCamera],mediaType: .video,position: .unspecified)
    
    private var bottomCollectionViewConstraint:NSLayoutConstraint?
    
    private let editCollectionCellIdentifier = "EditCell"
    
    private let filterCollectionCellIdentifier = "FilterCell"
    
    let editButtonImages:[UIImage] = [#imageLiteral(resourceName: "sticker_icon"),#imageLiteral(resourceName: "brightnessIcon"),#imageLiteral(resourceName: "contrast_icon"),#imageLiteral(resourceName: "temp_icon"),#imageLiteral(resourceName: "blur_Icon")]
    
    private let stickerSegueIdentifier = "ShowStickerVC"
    
    private lazy var editControlsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
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
    
    private lazy var editContainerView:EditContainerView = {
        let view = EditContainerView(frame: CGRect(x: 0, y: self.view.frame.height - 120, width: self.view.frame.width, height: 120))
        view.delegate = self
        return view
    }()
    
    private var isRotating = false
    
    private var identity = CGAffineTransform.identity
    
    private var stickerImageView:UIImageView?
    
    private var editSegment = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupEditingViews()
        requestPhotoAccess()
    }
    
    private func requestCameraAccess() {
        self.capturePhotoButton.isEnabled = false
        self.switchCameraButton.isEnabled = false
        
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
            self.isCameraAccessGiven = granted
            if self.isCameraAccessGiven {
                self.startConfiguration()
                DispatchQueue.main.async {
                    self.capturePhotoButton.isEnabled = true
                    self.switchCameraButton.isEnabled = true
                }
            }
        })
    }
    
    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                self.isPhotoLibraryAccessGiven = true
                self.getPhotos()
                break
            case .notDetermined, .denied:
                self.isPhotoLibraryAccessGiven = false
                break
            default:
                break
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthStatus {
        case .authorized:
            self.isCameraAccessGiven = true
            self.startConfiguration()
            if isCameraAccessGiven {
                print("yes access ")
            }
            break
        case .denied:
            self.isCameraAccessGiven = false
            self.requestCameraAccess()
            break
        case .notDetermined:
            self.requestCameraAccess()
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
            requestPhotoAccess()
        }
        
    }
    
    private func getPhotos() {
        if isPhotoLibraryAccessGiven {
            let allPhotos = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
            let imageManager = PHImageManager()
            let imageOptions = PHImageRequestOptions()
            guard let firstPhotoAsset = allPhotos.lastObject else {print("failed to get image"); return}
            
            DispatchQueue.main.async {
                let size = self.photoCollectionImageView.frame.size
                imageManager.requestImage(for: firstPhotoAsset, targetSize: size, contentMode: .aspectFill, options: imageOptions, resultHandler: { (image, nil) in
                    guard let image = image else {
                        print("Could not retreive image")
                        return
                    }
                    DispatchQueue.main.async {
                        self.photoCollectionImageView.image = image
                    }
                })
            }
        }
    }
    
    private func handleStickerGestures() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didBeginImageDrag(_:)))
        panGestureRecognizer.delegate = self
        stickerImageView?.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didBeginImagePinch(_:)))
        pinchGesture.delegate = self
        stickerImageView?.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(didBeginImageRotation(_:)))
        rotationGesture.delegate = self
        stickerImageView?.addGestureRecognizer(rotationGesture)
    }
    
    @objc
    private func didBeginImageDrag(_ gesture: UIPanGestureRecognizer) {
        guard let stickerImageView = self.stickerImageView else {return}
        let point = gesture.translation(in: previewImageView)
        if !isRotating {
            stickerImageView.center = CGPoint(x: stickerImageView.center.x + point.x, y: stickerImageView.center.y + point.y)
            gesture.setTranslation(.zero, in: previewImageView)
        }
        
    }
    
    @objc
    private func didBeginImagePinch(_ gesture:UIPinchGestureRecognizer) {
        guard let stickerImageView = self.stickerImageView else {return}
        if !isRotating {
            
            switch gesture.state {
            case .began:
                identity = stickerImageView.transform
            case .changed,.ended:
                stickerImageView.transform = identity.scaledBy(x: gesture.scale, y: gesture.scale)
            case .cancelled:
                break
            default:
                break
            }
        }
    }
    
    @objc
    private func didBeginImageRotation(_ gesture: UIRotationGestureRecognizer) {
        
        guard let view = gesture.view else {return}
        stickerImageView?.transform = view.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
        if gesture.state == .changed || gesture.state == .began {
            isRotating = true
        }
        if gesture.state == .ended {
            isRotating = false
        }
    }
    private func saveImageToPhotoLibrary(completionHandler:(Bool)->()) {
        
        guard let previewImageView = self.previewImageView, let layer = UIApplication.shared.keyWindow?.layer else {
            completionHandler(false)
            return
        }
        blackOverlayView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        blackOverlayView?.backgroundColor = .black
        topContainerView.addSubview(blackOverlayView!)
        
        self.previewImageView?.frame = CGRect(x: 0, y: -36, width: self.view.frame.width, height: self.view.frame.height - 120)
        //previewImageView.anchorConstraints(topAnchor: topContainerView.bottomAnchor, topConstant: 0, leftAnchor: cameraView.leftAnchor, leftConstant: 0, rightAnchor: cameraView.rightAnchor, rightConstant: 0, bottomAnchor: containerView.topAnchor, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        self.previewImageView?.contentMode = .scaleAspectFill
        self.previewImageView?.clipsToBounds = true

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(previewImageView.layer.frame.size, false, scale); // reconsider size property for your screenshot
        layer.render(in: UIGraphicsGetCurrentContext()!)
        print(previewImageView.layer.frame.size)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(screenshot!, self, nil, nil)
        
        self.previewImageView?.removeFromSuperview()
        blackOverlayView?.removeFromSuperview()
        editControlsCollectionView.isHidden = true
        bottomCollectionViewConstraint?.constant = 120
        removeEditContainer()
        completionHandler(true)
    }
    
    @IBAction func toggleFrontOrBackCamera(_ sender: Any) {
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
        if !isCameraAccessGiven {
            return
        }
        handlePhotoCapture()
        showEditingTools()
    }
    
    private func showEditingTools() {
        cancelButton.isHidden = false
        optionsButton.isHidden = true
        editLabel.isHidden = false
        saveButton.isHidden = false
        flashButton.isHidden = true
        editControlsCollectionView.isHidden = false
        bottomCollectionViewConstraint?.constant = 0
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
        print(locationOnScreen)
        
        let focusView = UIImageView()
        focusView.image = #imageLiteral(resourceName: "focus")
        let size =  CGSize(width: 86, height: 75)
        focusView.frame = CGRect(origin: locationOnScreen, size: size)
        self.previewLayer?.addSublayer(focusView.layer)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            
        }) { (sucess) in
            focusView.layer.removeFromSuperlayer()
        }
        focus(focusMode: .continuousAutoFocus, exposureMode: .continuousAutoExposure, atPoint: devicePoint, monitorSubjectAreaChange: true)
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
    }
    
    @IBAction func flashButtonTapped(_ sender: Any) {
        isFlashOn = !isFlashOn
        if isFlashOn {
            flashButton.setImage(#imageLiteral(resourceName: "flash_icon"), for: .normal)
        } else {
            flashButton.setImage(#imageLiteral(resourceName: "flash_icon_off"), for: .normal)
        }
    }
    
    @IBAction func optionsButtonTapped(_ sender: UIButton) {
    print("options tapped")
   
    }
    private func setupViews() {
        photoCollectionImageView.layer.cornerRadius = 5
        photoCollectionImageView.layer.masksToBounds = true
        photoCollectionImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPhotoCollectionImage)))
        cameraView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCameraScreen(_:))))
        
        topContainerView.addSubview(saveButton)
        saveButton.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: nil, leftConstant: 0, rightAnchor: topContainerView.rightAnchor, rightConstant: -10, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        saveButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        
        topContainerView.addSubview(cancelButton)
        cancelButton.anchorConstraints(topAnchor: nil, topConstant: 0, leftAnchor: topContainerView.leftAnchor, leftConstant: 10, rightAnchor: nil, rightConstant: 0, bottomAnchor: nil, bottomConstant: 0, heightConstant: 0, widthConstant: 0)
        cancelButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
    }
    
    private func setupEditingViews() {
        editControlsCollectionView.register(EditCollectionViewCell.self, forCellWithReuseIdentifier: editCollectionCellIdentifier)
        containerView.addSubview(editControlsCollectionView)
        
        editControlsCollectionView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
        editControlsCollectionView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
        
        bottomCollectionViewConstraint = editControlsCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 120)
        bottomCollectionViewConstraint?.isActive = true
        editControlsCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
     @objc
     private func handleCancel() {
        cancelButton.isHidden = true
        optionsButton.isHidden = false
        flashButton.isHidden = false
        saveButton.isHidden = true
        editLabel.isHidden = true
        previewImageView?.removeFromSuperview()
        blackOverlayView?.removeFromSuperview()
        editControlsCollectionView.isHidden = true
        bottomCollectionViewConstraint?.constant = 120
        removeEditContainer()
    }
    
    
    @objc
    private func handleSave() {
        saveImageToPhotoLibrary(completionHandler: { (success) in
            if success {
                print("successfully saved")
            } else {
                print("error saving")
            }
        })
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
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {

//        DispatchQueue.main.async {
//            UIView.animate(withDuration: 0.1) {
//                self.previewLayer!.opacity = 0
//            }
//        }
        
         previewLayer!.backgroundColor = UIColor.black.cgColor
         previewLayer!.opacity = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.previewLayer!.opacity = 1
        }) { (success) in
            self.previewLayer!.opacity = 1
//            darkOverlayView.removeFromSuperview()
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
        
        blackOverlayView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        blackOverlayView?.backgroundColor = .black
        cameraView.addSubview(blackOverlayView!)
        
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

extension CameraViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: editCollectionCellIdentifier, for: indexPath) as! EditCollectionViewCell
//        if let image = previewImage {
//            cell.imageView.image = image
//        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! EditCollectionViewCell
        if let image = previewImage {
            cell.imageView.image = image
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row, "is selelcted")
        switch indexPath.row {
        case 0:
            showStickerVC()
        case 1:
            DispatchQueue.global(qos: .background).async {
                let filterImage = ExposureFilter.exposureFilter(self.previewImage!)
                DispatchQueue.main.async {
                    self.previewImageView?.image = filterImage
                }
            }
            editSegment = 1
        case 2:
            let sepiaFilter = Filter(filterName: .sepia)
            sepiaFilter.inputImage(self.previewImage!)
            DispatchQueue.main.async {
                self.previewImageView?.image = sepiaFilter.outputImage()
            }
        case 3:
            editSegment = 3
        case 4:
            editSegment = 4
        default:
            break
        }
        
    }
    
    private func showStickerVC() {
        let stickerVC = StickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
        stickerVC.delegate = self
        let navVC = UINavigationController(rootViewController: stickerVC)
        present(navVC, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width / 5) - 5
        print(width)
        return CGSize(width: 70, height: 70)
    }
    
    private func showEditContainer() {
        view.addSubview(editContainerView)
    }
    
    private func removeEditContainer() {
        editContainerView.removeFromSuperview()
    }
}

extension CameraViewController: EditViewDelegate {
    func sliderValueDidChange(_ value: Float) {
    
    }
    
    func didTapDoneButton() {
        removeEditContainer()
    }
    
    func didTapCancelButton() {
        removeEditContainer()
        self.previewImageView?.image = previewImage!
        self.editContainerView.editSlider.value = 0
    }

}

extension CameraViewController: StickerViewDelegate {
    
    func didSelectSticker(_ image: UIImage) {
        self.stickerImageView = UIImageView(image: image)
        self.view.addSubview(stickerImageView!)
        self.stickerImageView?.isUserInteractionEnabled = true
        self.stickerImageView?.frame = CGRect(origin: previewImageView!.center, size: CGSize(width: 150, height: 150))
        previewImageView?.addSubview(stickerImageView!)
        handleStickerGestures()
    }
}

extension CameraViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}













