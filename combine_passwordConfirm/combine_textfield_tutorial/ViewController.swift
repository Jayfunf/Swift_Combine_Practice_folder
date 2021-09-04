//
//  ViewController.swift
//  combine_textfield_tutorial
//
//  Created by Minhyun Cho on 2021/09/04.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var passwordConfirmTextfield: UITextField!
    @IBOutlet weak var myButton: UIButton!
    
    var viewModel: MyViewModel!
    
    private var mySubscriptions = Set<AnyCancellable>() // 메모리 관리용 cancellable
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        viewModel = MyViewModel()
        
        // 텍스트필드에서 나가는 이벤트를
        // 뷰모델의 프로퍼티가 구독
        passwordTextfield
            .myTextPublisher
//            .print()
            // 스레드 - 메인에서 받겠다
            .receive(on: DispatchQueue.main)
            // 구독
            .assign(to: \.passwordInput, on: viewModel)
            .store(in: &mySubscriptions)
        
        passwordConfirmTextfield
            .myTextPublisher
//            .print()
            // 다른 쓰레드와 같이 작업 하기 때문에 Runloop 로 돌리기
            .receive(on: RunLoop.main)
            // 구독
            .assign(to: \.passwordConfirmInput, on: viewModel)
            .store(in: &mySubscriptions)
        
        // 버튼이 뷰모델의 퍼블리셔를 구독
        viewModel.isMatchPasswordInput
            .print()
            .receive(on: RunLoop.main)
            // 구독
            .assign(to: \.isValid, on: myButton)
            .store(in: &mySubscriptions)
    }
}

extension UITextField {
    var myTextPublisher: AnyPublisher<String, Never> {
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            // UITextfield 가져옴
            .compactMap{$0.object as? UITextField} // compactMap으로 먼저 UITextField를 거르고
            .map{ $0.text ?? "" } // ?? -> 값이 없다면 "" -> 빈 값을 넣어주겠다. // String 가져옴
            .print()
            .eraseToAnyPublisher() // 기존의 래핑을 뭉퉁그려서 anypublisher로 바꿈
    }
}

extension UIButton {
    var isValid: Bool {
        get {
            backgroundColor == .yellow
        }
        set {
            backgroundColor = newValue ? .yellow : .lightGray
            isEnabled = newValue
            setTitleColor(newValue ? .blue : .white, for: .normal)
        }
    }
}
