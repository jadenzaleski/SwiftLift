//
//  Debouncer.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 5/24/24.
//

import Combine
import Foundation

class Debouncer: ObservableObject {
    private var subject = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?

    func debounce(interval: TimeInterval, action: @escaping () -> Void) {
        cancellable = subject
            .debounce(for: .seconds(interval), scheduler: DispatchQueue.main)
            .sink(receiveValue: action)

        subject.send(())
    }
}
