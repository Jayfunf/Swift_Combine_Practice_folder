//
//  ViewController.swift
//  combine_textfield_tutorial
//
//  Created by Minhyun Cho on 2021/09/04.
//  Reference by 개발하는 정대리 on Youtube
//  https://www.youtube.com/channel/UCutO2H_AVmWHbzvE92rpxjA

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var passwordConfirmTextfield: UITextField!
    @IBOutlet weak var myButton: UIButton!
    // SwiftUI를 사용하지 않고 Storyboard 사용
    
    var viewModel: MyViewModel!
    
    private var mySubscriptions = Set<AnyCancellable>() // deinit될 때 자동으로 cancle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        viewModel = MyViewModel()
        
        // 텍스트필드에서 나가는 이벤트를
        // 뷰모델의 프로퍼티가 구독
        passwordTextfield
            .myTextPublisher // extensiond으로 myTextPublisher기능 확장
//            .print()
            // 스레드 - 메인에서 받겠다
            // A publisher that delivers elements using the specified scheduler. - Apple Dev.
            // 즉 on: DispatchQuqeu.main -> 디스패치큐 메인을 사용하여 요소를 전달.
            .receive(on: DispatchQueue.main)
            // 구독
            .assign(to: \.passwordInput, on: viewModel) // to: on에 있는, on: 어디에,to: 에는 <\.> <- 들어가야함.
            .store(in: &mySubscriptions) // RxSwift의 disposeBag과 같이 사용 가능.
        
        passwordConfirmTextfield
            .myTextPublisher
//            .print()
            // 다른 쓰레드와 같이 작업 하기 때문에 Runloop 로 돌리기
            .receive(on: RunLoop.main)
            // 구독
            .assign(to: \.passwordConfirmInput, on: viewModel)
            .store(in: &mySubscriptions) // RxSwift의 disposeBag과 같이 사용 가능.
        
        // 버튼이 뷰모델의 퍼블리셔를 구독
        viewModel.isMatchPasswordInput
            .print()
            .receive(on: RunLoop.main)
            // 구독
            .assign(to: \.isValid, on: myButton)
            .store(in: &mySubscriptions) // RxSwift의 disposeBag과 같이 사용 가능.
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
