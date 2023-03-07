//
//  KeyboardViewController.swift
//  AIMEKeyboard
//
//  Created by Galvin Gao on 3/6/23.
//

import ChatGPTSwift
import UIKit

enum CompletionStatus {
    case idle
    case running
    case completed
    case aborted
}

class KeyboardViewController: UIInputViewController {
    @IBOutlet var nextKeyboardButton: UIButton!
    var openAiModel: OpenAiModel = .init(api: ChatGPTAPI(apiKey: "apiKey"))

    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    lazy var btnStart: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 5
        btn.setTitle("Start", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(self.onBtnStartPressed(target:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var btnAbort: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 5
        btn.setTitle("Abort", for: .normal)
        btn.backgroundColor = .systemRed
        btn.tintColor = .white
        return btn
    }()
    
    lazy var lblStatus: UILabel = {
        let view = UILabel()
        view.text = "Idle."
        view.minimumScaleFactor = 0.5
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 12)
        return view
    }()
    
    var status: CompletionStatus = .idle {
        didSet {
            switch self.status {
            case .idle:
                self.lblStatus.text = "Idle."
            case .running:
                self.lblStatus.text = "Running..."
            case .completed:
                self.lblStatus.text = "Completed."
            case .aborted:
                self.lblStatus.text = "Aborted."
            }
        }
    }
    
    @objc
    func onBtnStartPressed(target: UIButton) {
        Task {
            status = .running
            await openAiModel.sendText(textDocumentProxy.documentContextBeforeInput ?? "") { segment in
                self.textDocumentProxy.insertText(segment)
            }
            status = .completed
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        let barHeight: CGFloat = 48
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.view.addSubview(self.btnAbort)
        self.btnAbort.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -8).isActive = true
        self.btnAbort.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8).isActive = true
        self.btnAbort.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
        self.btnAbort.widthAnchor.constraint(equalToConstant: 96).isActive = true
        self.btnAbort.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.btnStart)
        self.btnStart.rightAnchor.constraint(equalTo: self.btnAbort.leftAnchor, constant: -8).isActive = true
        self.btnStart.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8).isActive = true
        self.btnStart.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
        self.btnStart.widthAnchor.constraint(equalToConstant: 96).isActive = true
        self.btnStart.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.lblStatus)
        self.lblStatus.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 8).isActive = true
        self.lblStatus.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8).isActive = true
        self.lblStatus.rightAnchor.constraint(equalTo: self.btnStart.leftAnchor, constant: -8).isActive = true
        self.lblStatus.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
        self.lblStatus.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
}
