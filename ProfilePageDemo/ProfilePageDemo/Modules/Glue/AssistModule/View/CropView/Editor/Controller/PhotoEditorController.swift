//
//  PhotoEditorController.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/23.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

protocol PhotoEditorControllerDelegate: AnyObject {
    
    func photoEditorDidCancel(_ editor: PhotoEditorController)
    func photoEditor(_ editor: PhotoEditorController, didFinishEditing photo: UIImage, isEdited: Bool, stack: PhotoEditingStack)
}

final class PhotoEditorController: AnyImageViewController {
        
    private let cropView = UIView()
    private lazy var contentView: PhotoEditorContentView = {
        let view = PhotoEditorContentView(frame: self.view.bounds, image: image, context: context)
        view.presetFitFrame = self.presetFitFrame
        return view
    }()
    
    private var image: UIImage = UIImage()
    private let resource: EditorPhotoResource
    private let options: EditorPhotoOptionsInfo
    private let context: PhotoEditorContext
    private let blurContext = CIContext()
    private weak var delegate: PhotoEditorControllerDelegate?
    private var lastOperationTime: TimeInterval = 0
    
    private var presetFitFrame = CGRect.zero

    private lazy var cropOptionView: EditorCropToolView = {
        let view = EditorCropToolView.init(frame: .init(x: 0, y: self.view.height, width: self.view.width, height: 220), options: options)
        return view
    }()
    
    private lazy var cropMenuView: MediaCropMenu = {
        let cropOption = self.options.cropOptions.at(self.stack.edit.cropData.cropOptionIdx)
        return MediaCropMenu.init(frame: .zero, source: self.options.source, cropOptions: options.cropOptions, editor: self.options.mediaEditor, presetSize: cropOption, presetRange: self.options.mediaEditor?.timeRange)
    }()
    
    private lazy var stack: PhotoEditingStack = {
        let stack = PhotoEditingStack(identifier: options.cacheIdentifier)
        stack.delegate = self
        return stack
    }()
    
    init(photo resource: EditorPhotoResource, options: EditorPhotoOptionsInfo, delegate: PhotoEditorControllerDelegate, fitFrame: CGRect) {
        self.resource = resource
        self.options = options
        self.context = .init(options: options)
        self.delegate = delegate
        self.presetFitFrame = fitFrame
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindAction()
        loadData()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    private func loadData() {
        resource.loadImage { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.image = image
                self.setup()
            case .failure(let error):
                if error == .cannotFindInLocal {
                    self.showWaitHUD()
                    return
                }
                _print("Fetch image failed: \(error.localizedDescription)")
                self.delegate?.photoEditorDidCancel(self)
            }
        }
    }
    
    private func setup() {
        view.backgroundColor = UIColor.black
        view.addSubview(contentView)
        
        cropOptionView.delegate = self
        view.addSubview(cropOptionView)
        
        cropView.backgroundColor = .black
        cropView.clipsToBounds = true
        cropView.layer.cornerRadius = 8
        cropView.isHidden = true
        view.addSubview(cropView)
        
        // 编辑层
        contentView.snp.makeConstraints { (maker) in
            maker.left.right.top.equalTo(0)
            maker.bottom.equalTo(view.snp.bottom).offset(-250)
        }
        
        stack.originImage = image
        stack.originImageViewBounds = contentView.imageView.bounds
        
        cropMenuView.frame = CGRect(x: 0, y: self.view.height, width: self.view.width, height: 246)
        cropMenuView.onSizeChange = { [weak self] option in
            let index = self?.options.cropOptions.firstIndex(of: option) ?? 0
            self?.context.action(.cropUpdateOption(option))
        }
        cropMenuView.onSave = { [weak self] in
            self?.context.action(.cropDone)
        }
        cropMenuView.onClear = { [weak self] in
            self?.context.action(.cropCancel)
        }
        cropMenuView.onRangeCroped = { [weak self] range in
            // range 已经保存到edt中 无需处理
            
        }
        cropMenuView.onMenuIndexChange = { [weak self] index in
            guard let self = self, let preview = self.options.videoAssociatedView, let videoSize = self.options.mediaEditor?.videoSize else {
                return
            }
            if index == 0 {
                self.contentView.isHidden = false
                self.cropView.isHidden = true
                self.contentView.readdVideoAssociatedView()
            } else {
                self.contentView.isHidden = true
                self.cropView.isHidden = false
                self.cropView.addSubview(preview)
                let rect = CGRect(x: 0, y: self.view.safeAreaInsets.top, width: self.view.width, height: self.view.height - self.view.safeAreaInsets.top - 250)
                self.cropView.frame = rect.aspectFitSize(ratio: videoSize.width / videoSize.height)
                preview.frame = self.cropView.bounds
            }
        }
        self.view.addSubview(cropMenuView)
        
        self.contentView.updateView(with: self.stack.edit) { [weak self] in
            guard let self = self else { return }
            self.contentView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let _ = self.context.action(.toolOptionChanged(.crop))
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut) {
                    
                    self.cropMenuView.bottom = self.view.height
                    
                } completion: { _ in
                    
                }

            }
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension PhotoEditorController: EditorCropToolViewDelegate {
    
    func cropToolView(_ toolView: EditorCropToolView, didClickCropOption option: EditorCropOption) -> Bool {
        return context.action(.cropUpdateOption(option))
    }
    
    func cropToolViewCancelButtonTapped(_ cropToolView: EditorCropToolView) {
        let _ = context.action(.cropCancel)
    }
    
    func cropToolViewDoneButtonTapped(_ cropToolView: EditorCropToolView) {
        let _ = context.action(.cropDone)
    }
    
    func cropToolViewResetButtonTapped(_ cropToolView: EditorCropToolView) {
        context.action(.cropReset)
    }
    
    func cropToolViewRotateButtonTapped(_ cropToolView: EditorCropToolView) -> Bool {
        return context.action(.cropRotate)
    }
    
}

// MARK: - Private
extension PhotoEditorController {
    
    /// 获取最终的图片
    private func getResultImage() -> UIImage? {
        stack.cropRect = contentView.cropContext.cropRealRect
        let tmpScale = contentView.scrollView.zoomScale
        let tmpOffset = contentView.scrollView.contentOffset
        let tmpContentSize = contentView.scrollView.contentSize
        contentView.scrollView.zoomScale = contentView.scrollView.minimumZoomScale
        stack.cropImageViewFrame = contentView.imageView.frame
        contentView.scrollView.zoomScale = tmpScale
        contentView.scrollView.contentOffset = tmpOffset
        contentView.scrollView.contentSize = tmpContentSize
        
        // 由于 TextView 的位置是基于放大后图片的位置，所以在输出时要改回原始比例计算坐标位置
        let textScale = stack.originImageViewBounds.size.width / contentView.imageView.bounds.width
        contentView.calculateFinalFrame(with: textScale)
        
        return stack.output()
    }
    
    /// 存储编辑记录
    private func saveEditPath() {
        if options.cacheIdentifier.isEmpty { return }
        stack.save()
    }
    
}

// MARK: - Crop
extension PhotoEditorController {
    
    /// 准备开始裁剪
    private func willBeginCrop() {
        contentView.scrollView.isScrollEnabled = true
        contentView.cropLayerLeave.isHidden = true
        contentView.deactivateAllTextView()
        let image = contentView.imageView.screenshot(self.image.size)
        contentView.cropLayerLeave.isHidden = false
        contentView.canvas.isHidden = true
        contentView.mosaic?.isHidden = true
        contentView.hiddenAllTextView()
        contentView.imageView.image = image
    }
    
    /// 已经结束裁剪
    private func didEndCroping() {
        contentView.canvas.isHidden = false
        contentView.mosaic?.isHidden = false
        contentView.updateTextFrameWhenCropEnd()
        contentView.imageView.image = contentView.image
    }
}


// MARK: - Action

extension PhotoEditorController {
    
    private func bindAction() {
        context.didReceiveAction { [weak self] (action) in
            return self?.didReceive(action: action) ?? false
        }
    }
    
    private func didReceive(action: PhotoEditorAction) -> Bool {
        let currentTime = Date().timeIntervalSince1970
        if lastOperationTime > currentTime && action.duration > 0 {
            return false
        }
        lastOperationTime = currentTime + action.duration
        
        switch action {
        case .back:
            delegate?.photoEditorDidCancel(self)
            trackObserver?.track(event: .editorBack, userInfo: [.page: AnyImagePage.editorPhoto])
            
        case .done:
            contentView.deactivateAllTextView()
            guard let image = getResultImage() else { return false }
            switch options.editedMediaType {
            case .image:
//                setPlaceholdImage(image)
                break
            case .video:
                break
            }
            stack.setOutputImage(image)
            saveEditPath()
            
            let snap = self.view.snapshotImage(afterScreenUpdates: false)
            let imageView = UIImageView()
            imageView.image = snap
            self.view.addSubview(imageView)
            imageView.frame = self.view.bounds
            
            delegate?.photoEditor(self, didFinishEditing: image, isEdited: stack.edit.isEdited, stack: stack)
//            trackObserver?.track(event: .editorDone, userInfo: [.page: AnyImagePage.editorPhoto])
        case .toolOptionChanged(let option):
            context.toolOption = option
            toolOptionsDidChanged(option: option)
            
        case .cropUpdateOption(let option):
            contentView.setCrop(option)
            
        case .cropRotate:
            contentView.rotate()
            trackObserver?.track(event: .editorPhotoCropRotation, userInfo: [:])
            
        case .cropReset:
            contentView.cropReset()
            trackObserver?.track(event: .editorPhotoCropReset, userInfo: [:])
            
        case .cropCancel:
            trackObserver?.track(event: .editorPhotoCropCancel, userInfo: [:])
            if options.toolOptions.count == 1 {
                
                let snap = self.view.snapshotImage(afterScreenUpdates: false)
                let imageView = UIImageView()
                imageView.image = snap
                self.view.addSubview(imageView)
                imageView.frame = self.view.bounds
                
                context.action(.back)
                return true
            }
            contentView.cropCancel { [weak self] (_) in
                self?.didEndCroping()
            }
            
        case .cropDone:
//            trackObserver?.track(event: .editorPhotoCropDone, userInfo: [:])
//            backButton.isHidden = false
            contentView.cropDone { [weak self] (_) in
                guard let self = self else { return }
                self.context.action(.done)

//                self.didEndCroping()
//                if self.options.toolOptions.count == 1 {
//                    self.context.action(.done)
//                }
            }
            break
        case .cropFinish(let data):
            stack.setCropData(data)
            
        default:
            break
        }
        return true
    }
    
    
    private func toolOptionsDidChanged(option: EditorPhotoToolOption?) {
        contentView.scrollView.isScrollEnabled = option == nil
        guard let option = option else { return }
        switch option {
        case .crop:
            willBeginCrop()
            if !contentView.cropContext.didCrop {
                let opt: EditorCropOption = self.options.cropOptions.at(self.stack.edit.cropData.cropOptionIdx) ?? .free
                contentView.cropStart(with: opt)
            } else {
                contentView.cropStart()
            }
            trackObserver?.track(event: .editorPhotoCrop, userInfo: [:])
        default:
            break
        }
    }
}

extension PhotoEditorController: PhotoEditingStackDelegate {
    
    func editingStack(_ stack: PhotoEditingStack, needUpdatePreview edit: PhotoEditingStack.Edit) {
        contentView.updateView(with: edit)
    }
}
