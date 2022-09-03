//
//  EditorCropOptionCell.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2020/5/25.
//  Copyright © 2020-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

final class EditorCropOptionCell: UICollectionViewCell {
    
    private var option: EditorCropOption = .free
    private var selectColor: UIColor = .green
    
    override var isSelected: Bool {
        didSet {
            self.contentView.layer.borderColor = isSelected ? UIColor.hexColor("#FF8B48").cgColor : UIColor.clear.cgColor
            
        }
    }
    private lazy var imageView: UIImageView = {
       let imageV = UIImageView()
       return imageV
    }()
    private lazy var label: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = .systemFont(ofSize: 12)
        view.textColor = .white
        view.textAlignment = .center
        view.minimumScaleFactor = 0.5
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.hexColor("#FFFFFF", 0.12)
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.borderWidth = 2
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 8
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(label)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.equalTo(contentView.snp.centerX)
            make.top.equalTo(contentView.snp.top).offset(12)
        }
        label.snp.makeConstraints { maker in
            maker.bottom.equalTo(contentView.snp.bottom).offset(-8)
            maker.centerX.equalTo(contentView.snp.centerX)
        }
    }
}

// MARK: - Public
extension EditorCropOptionCell {
    
    func set(_ options: EditorPhotoOptionsInfo, option: EditorCropOption, selectColor: UIColor) {
        self.option = option
        self.selectColor = selectColor
        
        var defaultImage = UIImage.name("edit_canvas_34")
        switch option {
        case .free:
            defaultImage = UIImage.name("edit_canvas_original")
            label.text = options.theme[string: .editorFree]
        case .custom(let w, let h):
            label.text = "\(w):\(h)"
            defaultImage = UIImage.name("edit_canvas_\(w)\(h)")
        }
        if let image = defaultImage {
            self.imageView.image = image
        }
        options.theme.labelConfiguration[.cropOption]?.configuration(label)
    }
}
 
