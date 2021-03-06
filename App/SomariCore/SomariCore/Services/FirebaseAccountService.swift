//
//  FirebaseAccountService.swift
//  Somari
//
//  Created by Kazuki Yamamoto on 2019/10/05.
//  Copyright © 2019 Kazuki Yamamoto. All rights reserved.
//

import Foundation
import FirebaseAuth
import Combine
import SomariFoundation

private struct FirebaseUser: SomariFoundation.User {
    private let user: FirebaseAuth.User

    init(user: FirebaseAuth.User) {
        self.user = user
    }
}

private extension LoginError {
    init?(with firebaseError: NSError) {
        guard let code = AuthErrorCode(rawValue: firebaseError.code) else {
            return nil
        }

        switch code {
        default:
            self = .unknown
        }
    }
}

public class FirebaseAccountService: AccountService {
    public init() {
    }

    public func uid() -> String? {
        Auth.auth().currentUser?.uid
    }

    public func loginAnonymously(completion: @escaping (Result<SomariFoundation.User, LoginError>) -> Void) {
        Auth.auth().signInAnonymously { (user, error) in
            if let error = error {
                guard let loginError = LoginError(with: error as NSError) else {
                    completion(.failure(.unknown))
                    return
                }

                completion(.failure(loginError))
                return
            }
            guard let user = user else {
                completion(.failure(.unknown))
                return
            }

            completion(.success(FirebaseUser(user: user.user)))
        }
    }

    public func listenLoginState() -> AnyPublisher<Result<SomariFoundation.User, LoginError>, Never> {
        let subject = PassthroughSubject<Result<SomariFoundation.User, LoginError>, Never>()

        let handle = Auth.auth().addStateDidChangeListener { (_, user) in
            guard let user = user else {
                subject.send(.failure(.notLogin))
                return
            }
            subject.send(.success(FirebaseUser(user: user)))
        }

        _ = subject.handleEvents(receiveCancel: { Auth.auth().removeStateDidChangeListener(handle) })

        return subject.eraseToAnyPublisher()
    }
}
