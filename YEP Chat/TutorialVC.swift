//
//  TutorialVC.swift
//  YEP Chat
//
//  Created by Darren Key on 12/9/21.
//

import UIKit

///handle next tap
protocol tutorialVC{
    func nextTapped()
}

class TutorialVC: UIViewController {
    
    @IBOutlet var continueButton: UIButton!
    
    var delegate: tutorialVC?

    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var label4: UILabel!
    
    let whiteBackgroundColor = UIColor(hexString: "#F0F0F0")
    let blackBackgroundColor = UIColor(hexString: "#101010")
    
    override func viewDidLayoutSubviews() {
        print(label1.font)
        continueButton.titleLabel?.font = UIFont(name: "EB Garamond Regular Bold", size: 0.034 * view.frame.size.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        continueButton.layer.cornerRadius = 10
    }
    
    func convertToLightMode(){
        label1.textColor = .black
        label2.textColor = .black
        label3.textColor = .black
        label4.textColor = .black
        
        view.backgroundColor = whiteBackgroundColor
    }
    
    func convertToDarkMode(){
        label1.textColor = .white
        label2.textColor = .white
        label3.textColor = .white
        label4.textColor = .white
        
        view.backgroundColor = blackBackgroundColor
    }
    

    @IBAction func nextPressed(_ sender: Any) {
        delegate?.nextTapped()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
