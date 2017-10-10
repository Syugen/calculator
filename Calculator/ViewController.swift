//
//  ViewController.swift
//  Calculator
//
//  Created by Yuan Zhou on 2017-08-26.
//  Copyright © 2017 Yuan Zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    /* Note:
       1. The feature "-/+ should not change the display for the number 0" 
          is not consistent with real iPhone calculators (117, 123-126)
       2. "C" not implemented
       3. Functions in landscape orientation not implemented
       4. Views on landscape orientation and iPad or iPhone 4s disordered
     */
    
    @IBOutlet weak var stackLabel: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
    
    @IBOutlet var allButtons: [UIButton]!
    @IBOutlet var signButtons: [UIButton]!
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var buttonMinus: UIButton!
    @IBOutlet weak var buttonMult: UIButton!
    @IBOutlet weak var buttonDiv: UIButton!
    
    @IBAction func numberButtonDown(_ sender: UIButton) {
        sender.backgroundColor = UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1)
    }
    
    @IBAction func numberButtonUp(_ sender: UIButton) {
        sender.backgroundColor = UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1)
    }
    
    @IBAction func signButtonDown(_ sender: UIButton) {
        sender.backgroundColor = UIColor(red: 197/255, green: 116/255, blue: 40/255, alpha: 1)
    }
    
    @IBAction func signButtonUp(_ sender: UIButton) {
        sender.backgroundColor = UIColor(red: 241/255, green: 146/255, blue: 51/255, alpha: 1)
    }
    
    @IBAction func funcButtonDown(_ sender: UIButton) {
        sender.backgroundColor = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1)
    }
    
    @IBAction func funcButtonUp(_ sender: UIButton) {
        sender.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
    }
    
    var stack: [String] = ["0"]
    var clearMain: Bool = false
    var clearStack: Bool = false
    var repeatNum: String? = nil
    var repeatSign: String? = nil
    
    @IBAction func numberButtonWasPressed(_ sender: UIButton) {
        let value = sender.titleLabel!.text!
        
        if value != "=" && repeatSign != nil {
            repeatSign = nil
            repeatNum = nil
        }
        
        if clearStack == true {
            if Int(value) != nil || value == "." {
                stack.removeAll()
                stack.append("0")
            }
            clearStack = false
        }
        
        for signButton in signButtons {
            signButton.layer.borderWidth = 0.25
        }
        
        switch value {
        case let num where Int(num) != nil:
            if stack.count % 2 == 0 {     // Last input is operator
                stack.append("")
            }
            if resultsLabel.text == "0" || clearMain {
                display(value)
                stack[stack.count - 1] = value
                clearMain = false
            } else if resultsLabel.text == "-0" {
                display("-" + value)
                stack[stack.count - 1] += value
            } else if numDigits(stack.last!) < 9 {
                stack[stack.count - 1] += value
                display(stack[stack.count - 1], false)
            }
        case ".":
            if stack.count % 2 == 0 {
                stack.append("")
            }
            if clearMain {
                display("0.", false)
                stack[stack.count - 1] = "0."
                clearMain = false
            } else if !resultsLabel.text!.characters.contains(".") &&
                numDigits(stack.last!) < 9 {
                stack[stack.count - 1] += "."
                display(stack[stack.count - 1], false)
            }
        case "AC":
            display("0")
            stack.removeAll()
            stack.append("0")
        case "⁺∕₋":
            clearMain = false
            if stack.count % 2 == 0 {    // Last input is operator
                stack.append("-")
                display("0") // display("-0")
            } else if stack.last!.hasPrefix("-") { // Number already negative
                let index = stack.last!.index(stack.last!.startIndex, offsetBy: 1)
                stack[stack.count - 1] = stack.last!.substring(from: index)
                display(stack.last!)
            } else {                     // Positive number (including 0)
                let prune = stack.last!.trimmingCharacters(in: ["0"])
                if prune == "" || prune == "." {
                    display(stack.last!)
                } else {
                    stack[stack.count - 1] = "-" + stack.last!
                    display(stack.last!)
                }
            }
        case "%":
            clearMain = true
            if stack.count % 2 == 0 {    // Last input is operator
                stack.append(String(Double(stack[stack.count - 2])! / 100))
                display(stack.last!)
            } else {                     // Last input is number
                stack[stack.count - 1] = String(Double(stack.last!)! / 100)
                display(stack.last!)
            }
        case "=":
            if stack.count == 1 {
                if repeatNum != nil {
                    stack[0] = String(calculate(stack[0], repeatNum!, repeatSign!))
                }
            } else if stack.count == 2 {
                repeatNum = stack[0]
                repeatSign = stack[1]
                stack[0] = String(calculate(stack[0], stack[0], stack[1]))
                stack.removeLast(1)
            } else if stack.count == 3 {
                repeatNum = stack[2]
                repeatSign = stack[1]
                stack[0] = String(calculate(stack[0], stack[2], stack[1]))
                stack.removeLast(2)
            } else if stack.count == 4 {
                repeatNum = stack[2]
                repeatSign = stack[3]
                stack[2] = String(calculate(stack[2], stack[2], stack[3]))
                stack[0] = String(calculate(stack[0], stack[2], stack[1]))
                stack.removeLast(3)
            } else if stack.count == 5 {
                repeatNum = stack[4]
                repeatSign = stack[3]
                stack[2] = String(calculate(stack[2], stack[4], stack[3]))
                stack[0] = String(calculate(stack[0], stack[2], stack[1]))
                stack.removeLast(4)
            }
            display(stack[0])
            clearStack = true
            clearMain = true
        case "×", "÷":
            if value == "×" {
                buttonMult.layer.borderWidth = 2
            } else {
                buttonDiv.layer.borderWidth = 2
            }
            if stack.count == 1 {
                stack.append(value)
            } else if stack.count == 2 {
                stack[1] = value
            } else if stack.count == 3 {
                if stack[1] == "×" || stack[1] == "÷" {
                    stack[0] = String(calculate(stack[0], stack[2], stack[1]))
                    stack[1] = value
                    stack.removeLast(1)
                    display(stack[0])
                } else {
                    stack.append(value)
                }
            } else if stack.count == 4 {
                stack[3] = value
            } else if stack.count == 5 {
                stack[2] = String(calculate(stack[2], stack[4], stack[3]))
                stack[3] = value
                stack.removeLast(1)
                display(stack[2])
            }
            clearMain = true
        case "+", "-":
            if value == "+" {
                buttonPlus.layer.borderWidth = 2
            } else {
                buttonMinus.layer.borderWidth = 2
            }
            if stack.count == 1 {
                stack.append(value)
            } else if stack.count == 2 {
                stack[1] = value
            } else if stack.count == 3 {
                stack[0] = String(calculate(stack[0], stack[2], stack[1]))
                stack[1] = value
                stack.removeLast(1)
                display(stack[0])
            } else if stack.count == 4 {
                if stack[1] == "+" || stack[1] == "-" {
                    stack[0] = String(calculate(stack[0], stack[2], stack[1]))
                    stack[1] = value
                    stack.removeLast(2)
                    display(stack[0])
                } else {
                    stack[3] = value
                }
            } else if stack.count == 5 {
                stack[2] = String(calculate(stack[2], stack[4], stack[3]))
                stack[0] = String(calculate(stack[0], stack[2], stack[1]))
                stack[1] = value
                stack.removeLast(3)
                display(stack[0])
            }
            clearMain = true
        default:
            ()
        }
        display_full(stack)
        print(stack)
    }
    
    func numDigits(_ string: String) -> Int {
        var count = 0
        for char in string.characters {
            if char >= "0" && char <= "9" {
                count += 1
            }
        }
        return count
    }
    
    func calculate(_ num1: String, _ num2: String, _ sign: String) -> Double {
        let double1 = num1 == "Error" ? Double("inf")! : Double(num1)!
        let double2 = num2 == "Error" ? Double("inf")! : Double(num2)!
        switch sign {
        case "+":
            return double1 + double2
        case "-":
            return double1 - double2
        case "×":
            return double1 * double2
        case "÷":
            return double1 / double2
        default:
            return 0
        }
    }
    
    func display(_ string: String, _ prune_zero: Bool = true) {
        if string == "inf" || string == "-inf" ||
           string == "nan" || string == "-nan" {
            resultsLabel.text = "Error"
            return
        }
        var comma: [Character] = []
        var add_comma = !string.characters.contains(".")
        var counter = 0
        for char in string.characters.reversed() {
            if char == "," {
                continue
            }
            if counter > 0 && counter % 3 == 0 {
                comma.insert(",", at: 0)
            }
            comma.insert(char, at: 0)
            if char == "." {
                add_comma = true
            } else if add_comma {
                counter += 1
            }
        }
        
        var prune = String(comma)
        if prune_zero && prune.hasSuffix(".0") {
            let end = prune.index(prune.endIndex, offsetBy: -2)
            prune = prune.substring(to: end)
        }
        resultsLabel.text = prune
    }
    
    func display_full(_ stack: [String]) {
        var full = ""
        for string in stack {
            var prune = string
            if prune.characters.contains(".") {
                // Glitch: would prune "0.01" to ".01"
                prune = prune.trimmingCharacters(in: ["0"])
                if prune.characters.last == "." {
                    let end = prune.index(prune.endIndex, offsetBy: -1)
                    prune = prune.substring(to: end)
                }
            }
            if prune != "-" && prune.hasPrefix("-") {
                prune = "(" + prune + ")"
            }
            full += prune
        }
        stackLabel.text = full
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackLabel.text = "0"
        resultsLabel.text = "0"
        for button in allButtons {
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 0.25
        }
    }
}

