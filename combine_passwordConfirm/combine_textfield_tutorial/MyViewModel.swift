//
//  MyViewModel.swift
//  combine_textfield_tutorial
//
//  Created by Minhyun Cho on 2021/09/04.
//  Reference by 개발하는 정대리 on Youtube
//  https://www.youtube.com/channel/UCutO2H_AVmWHbzvE92rpxjA

import Foundation
import Combine

class MyViewModel { // 비밀번호 입력 시 이벤트를 받아줌.
    
    // subscriber가 볼 수 있도록 @Published로 변수 선언. 게시자임.
    @Published var passwordInput: String = "" //{
//        didSet{
//            print("\(passwordInput)")
//        }
//    }
    @Published var passwordConfirmInput: String = "" //{
//        didSet {
//            print("\(passwordConfirmInput)")
//        }
//    }
    
    // 들어온 퍼블리셔들의 값 일치 여부를 반환 하는 퍼블리셔
    lazy var isMatchPasswordInput: AnyPublisher<Bool, Never> = Publishers
        // lazy: 처음 사용 전 까진 로드하지 않음. 필요하지만 사용전 불러오기 부담스러운 친구들에게 사용.
        // 예를 들어 페이스북의 알림같은 경우 알림 버튼을 사용자가 클릭하기 전까지 날라온 알림들을 로드해두지 않음. 메모리 낭비. 그럴 때 사용.
        // 밑의 경우 passwordInput과 passwordConfirmInput이 들어오기 전까지 로드X
        .CombineLatest( $passwordInput, $passwordConfirmInput ) // 두 개시자로 부터 최신 요소를 받아 결합.
        .map({ (password: String, passwordConfirm: String) in
            if password == "" || passwordConfirm == "" {
                return false
            }
            if password == passwordConfirm {
                return true
            } else {
                return false
            }
        })
        .print()
        .eraseToAnyPublisher()
    // 이 변수를 요약하자면, 인자가 입력은 Bool로, error는 Never로 하는AnyPublisher로 생성한다.
    // CombineLatest로 두 인자(게시자)로 부터 최신 요소를 받아 결합한다.
    // map으로 String타입의 password와 passwordConfirmInput을 받아
    // 조건문으로 Bool타입을 return 한다.
    // .eraseToAnyPublisher() -> Operation에서의 데이터를 처리할 땐 Operation 상호 간 에러 처리나 혹은 스트림 제어를 위해서 데이터 형식을 알아야 하지만 Subscrbier에게 전달될 땐 필요가 없다. 따라서 최종적인 형태로 데이터를 전달할 땐 eraseToAnyPublisher를 사용.
}
