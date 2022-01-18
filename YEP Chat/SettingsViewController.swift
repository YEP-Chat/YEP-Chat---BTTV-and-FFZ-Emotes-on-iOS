//
//  SettingsViewController.swift
//  YEP Chat
//
//  Created by Darren Key on 1/12/22.
//

import UIKit

class SettingsViewController: UIViewController {
    
    ///IBOutleting literally everyting on the storyboard
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var themeSegmentedControl: UISegmentedControl!
    @IBOutlet var maxMessagesKeptTextField: UITextField!
    @IBOutlet var maxMessagesKeptWhenNotScrollingTextField: UITextField!
    
    @IBOutlet var settingsLabel: UILabel!
    
    @IBOutlet var themeCard: RoundedCorners!
    @IBOutlet var themeLabel: UILabel!
    
    @IBOutlet var messagesCard: UIView!
    @IBOutlet var messagesLabel: UILabel!
    @IBOutlet var maxMessagesKeptLabel: UILabel!
    @IBOutlet var maxMessagesKeptWhenNotScrollingLabel: UILabel!
    
    
    @IBOutlet var textFontLabel: UILabel!
    @IBOutlet var textFontTextField: UITextField!
    @IBOutlet var emoteSizeLabel: UILabel!
    @IBOutlet var emoteSizeTextField: UITextField!
    @IBOutlet var lineSpacingLabel: UILabel!
    @IBOutlet var lineSpacingTextField: UITextField!
    
    var maxMessages = 0
    var maxMessagesNotScrolling = 0
    
    var textFontSize : CGFloat = 0
    var emoteSize : CGFloat = 0
    var lineSpacing : CGFloat = 0
    
    ///Light mode vs dark mode
    var themeMode = lightModeDarkMode.light
    
    ///Storing previousVC as a variable to change theme mode + aspects of the view controller
    var previousVC : ChatViewController?
    
    ///Actual previous trait collection because when the view controller is first loaded it traitCollectionDidChange is fired
    var actualPreviousTraitCollection : UITraitCollection?
    
    override func viewDidLayoutSubviews() {
        maxMessagesKeptTextField.font = maxMessagesKeptWhenNotScrollingTextField.font
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        maxMessagesKeptTextField.layer.cornerRadius = 10
        maxMessagesKeptWhenNotScrollingTextField.layer.cornerRadius = 10
        
        maxMessagesKeptTextField.font = maxMessagesKeptLabel.font
        maxMessagesKeptWhenNotScrollingTextField.font = maxMessagesKeptLabel.font
        textFontTextField.font = maxMessagesKeptLabel.font
        emoteSizeTextField.font = maxMessagesKeptLabel.font
        lineSpacingTextField.font = maxMessagesKeptLabel.font
        
        
        let font = UIFont(name: "EB Garamond", size: themeLabel.font.pointSize - 8)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        
        maxMessagesKeptTextField.delegate = self
        maxMessagesKeptWhenNotScrollingTextField.delegate = self
        textFontTextField.delegate = self
        emoteSizeTextField.delegate = self
        lineSpacingTextField.delegate = self
        
        initialSettings()
    }
    
    let whiteBackgroundColor = UIColor(hexString: "#F0F0F0")
    let blackBackgroundColor = UIColor(hexString: "#101010")
    let darkGray = UIColor(hexString: "#404040")
    
    
    ///Initialize the settings VC to stored settings
    func initialSettings(){
        themeMode = (UserDefaults.standard.object(forKey: "isLightMode") as? Bool ?? true) ? .light: .dark
        
        switch themeMode {
        case .light:
            themeSegmentedControl.selectedSegmentIndex = 0
            convertToLightMode()
        case .dark:
            themeSegmentedControl.selectedSegmentIndex = 1
            convertToDarkMode()
        }
        
        maxMessages = UserDefaults.standard.object(forKey: "maxMessages") as? Int ?? maxMessages
        maxMessagesNotScrolling = UserDefaults.standard.object(forKey: "maxMessagesNoScroll") as? Int ?? maxMessagesNotScrolling
        
        textFontSize = UserDefaults.standard.object(forKey: "textFont") as? CGFloat ?? textFontSize
        emoteSize = UserDefaults.standard.object(forKey: "emoteSize") as? CGFloat ?? emoteSize
        lineSpacing = UserDefaults.standard.object(forKey: "lineSpacing") as? CGFloat ?? lineSpacing
        
        maxMessagesKeptTextField.text = String(maxMessages)
        maxMessagesKeptWhenNotScrollingTextField.text = String(maxMessagesNotScrolling)
        textFontTextField.text = String(Double(textFontSize))
        emoteSizeTextField.text = String(Double(emoteSize))
        lineSpacingTextField.text = String(Double(lineSpacing))
    }
    
    func convertToLightMode(){
        
        themeMode = .light
        
        UserDefaults.standard.set(themeMode == .light, forKey: "isLightMode")
        
        convertPreviousVCThemeMode(themeMode: themeMode)
        
        backButton.tintColor = .black
        
        settingsLabel.textColor = .black
        
        themeCard.backgroundColor = .white
        themeLabel.textColor = .black
        
        messagesCard.backgroundColor = .white
        messagesLabel.textColor = .black
        maxMessagesKeptLabel.textColor = .black
        maxMessagesKeptWhenNotScrollingLabel.textColor = .black
        
        maxMessagesKeptTextField.textColor = .black
        maxMessagesKeptWhenNotScrollingTextField.textColor = .black
        
        textFontLabel.textColor = .black
        textFontTextField.textColor = .black
        emoteSizeLabel.textColor = .black
        emoteSizeTextField.textColor = .black
        lineSpacingLabel.textColor = .black
        lineSpacingTextField.textColor = .black
        
        view.backgroundColor = whiteBackgroundColor
    }
    
    func convertToDarkMode(){
        
        themeMode = .dark
        
        UserDefaults.standard.set(themeMode == .light, forKey: "isLightMode")
        
        convertPreviousVCThemeMode(themeMode: themeMode)
        
        backButton.tintColor = .white
        
        settingsLabel.textColor = .white
        
        themeCard.backgroundColor = darkGray
        themeLabel.textColor = .white
        
        messagesCard.backgroundColor = darkGray
        messagesLabel.textColor = .white
        maxMessagesKeptLabel.textColor = .white
        maxMessagesKeptWhenNotScrollingLabel.textColor = .white
        
        maxMessagesKeptTextField.textColor = .black
        maxMessagesKeptWhenNotScrollingTextField.textColor = .black
        
        
        textFontLabel.textColor = .white
        textFontTextField.textColor = .black
        emoteSizeLabel.textColor = .white
        emoteSizeTextField.textColor = .black
        lineSpacingLabel.textColor = .white
        lineSpacingTextField.textColor = .black
        
        
        view.backgroundColor = blackBackgroundColor
        
    }
    
    ///Convert main vc
    func convertPreviousVCThemeMode(themeMode : lightModeDarkMode){
        
        guard let previousVC = previousVC else { return}

        previousVC.themeMode = themeMode
        
        switch themeMode{
        case .light:
            previousVC.convertToLightMode()
        case .dark:
            previousVC.convertToDarkMode()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard let prevTraitCol = actualPreviousTraitCollection else {
            actualPreviousTraitCollection = self.traitCollection
            return
        }
        
        actualPreviousTraitCollection = self.traitCollection
        

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: prevTraitCol){
            print(prevTraitCol)
            ///detection of light/dark mode
            if traitCollection.userInterfaceStyle == .light {
                themeSegmentedControl.selectedSegmentIndex = 0
                convertToLightMode()
            }
            else{
                themeSegmentedControl.selectedSegmentIndex = 1
                convertToDarkMode()
            }
        }
    }
    
    @IBAction func themeChanged(_ sender: Any) {
        switch themeSegmentedControl.selectedSegmentIndex{
        case 0:
            convertToLightMode()
        case 1:
            convertToDarkMode()
        default:
            print("Massive error!")
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindSettings", sender: self)
    }
    
    func roundOptionalStringToOptionalInt(text : String?) -> Int?{
        guard let text = text else {
            return nil
        }
        guard let text = Float(text) else{
            return nil
        }
        
        return Int(text)
    }
    
    ///Max messages not ended
    @IBAction func maxMessagesEnded(_ sender: Any) {
        if let res = roundOptionalStringToOptionalInt(text: maxMessagesKeptTextField.text){
            if res > 0{
                print("should end", res)
                maxMessagesKeptTextField.text = String(res)
                maxMessages = res
                
                UserDefaults.standard.set(res, forKey: "maxMessages")
                
                if let previousVC = previousVC {
                    previousVC.autoScrollLimit = maxMessages
                }
            }
            else{
                maxMessagesKeptTextField.text = String(maxMessages)
            }
        }
    }
    
    @IBAction func maxMessagesNoAutoscrollEnded(_ sender: Any) {
        if let res = roundOptionalStringToOptionalInt(text: maxMessagesKeptWhenNotScrollingTextField.text){
            if res > 0{
                maxMessagesKeptWhenNotScrollingTextField.text = String(res)
                maxMessagesNotScrolling = res
                
                UserDefaults.standard.set(res, forKey: "maxMessagesNoScroll")
                
                if let previousVC = previousVC {
                    previousVC.nonAutoScrollLimit = maxMessagesNotScrolling
                }
            }
            else{
                maxMessagesKeptWhenNotScrollingTextField.text = String(maxMessagesNotScrolling)
            }
        }
    }
    
    @IBAction func textSizeEnded(_ sender: Any) {
        if let tempRes = Double(textFontTextField.text ?? ""){
            let res = CGFloat(tempRes)
            if res > 0{
                textFontTextField.text = String(tempRes)
                textFontSize = res
                
                UserDefaults.standard.set(res, forKey: "textFont")
                
                if let previousVC = previousVC {
                    previousVC.textFont = UIFont.systemFont(ofSize: textFontSize)
                }
            }
            else{
                textFontTextField.text = String(Double(textFontSize))
            }
        }
    }
    
    @IBAction func emoteSizeEnded(_ sender: Any) {
        if let tempRes = Double(emoteSizeTextField.text ?? ""){
            let res = CGFloat(tempRes)
            if res > 0{
                emoteSizeTextField.text = String(tempRes)
                emoteSize = res
                
                UserDefaults.standard.set(res, forKey: "emoteSize")
                
                if let previousVC = previousVC {
                    previousVC.emoteFont = UIFont.systemFont(ofSize: emoteSize)
                }
            }
            else{
                emoteSizeTextField.text = String(Double(emoteSize))
            }
        }
    }
    
    @IBAction func lineSpacingEnded(_ sender: Any) {
        if let tempRes = Double(lineSpacingTextField.text ?? ""){
            let res = CGFloat(tempRes)
            if res > 0{
                lineSpacingTextField.text = String(tempRes)
                lineSpacing = res
                
                UserDefaults.standard.set(res, forKey: "lineSpacing")
                
                if let previousVC = previousVC {
                    previousVC.lineSpace = lineSpacing
                }
            }
            else{
                lineSpacingTextField.text = String(Double(lineSpacing))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        maxMessagesKeptTextField.resignFirstResponder()
        maxMessagesKeptWhenNotScrollingTextField.resignFirstResponder()
        emoteSizeTextField.resignFirstResponder()
        textFontTextField.resignFirstResponder()
        lineSpacingTextField.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ///save anything before unwinding
        maxMessagesKeptTextField.resignFirstResponder()
        maxMessagesKeptWhenNotScrollingTextField.resignFirstResponder()
        emoteSizeTextField.resignFirstResponder()
        textFontTextField.resignFirstResponder()
        lineSpacingTextField.resignFirstResponder()
    }
    
}

extension SettingsViewController : UITextFieldDelegate{
    ///limit ot only numbers
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        allowedCharacters.insert(".")
        return allowedCharacters.isSuperset(of: characterSet) && range.location < 5
    }
    
}
