//
//  Tester.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/28/23.
//

import SwiftUI
import UIKit

struct Tester: View {
    @State var i = 0;
    var body: some View {
        VStack {
            Text("Hello World")
                .font(Font.custom("OpenSans-Regular", size: 16))
                .fontWeight(.light)
            Text("Hello World")
                .font(Font.custom("OpenSans-Regular", size: 16))
                .fontWeight(.thin)
            Text("Hello World")
                .font(Font.custom("OpenSans-Regular", size: 16))
                .fontWeight(.regular)
            Text("Hello World")
                .font(Font.custom("OpenSans-Regular", size: 16))
                .fontWeight(.medium)
            Text("Hello World")
                .font(Font.custom("OpenSans-Regular", size: 16))
                .fontWeight(.semibold)
            Text("Hello World")
                .font(Font.custom("OpenSans-Regular", size: 16))
                .fontWeight(.bold)
            Text("Hello World")
                .font(Font.custom("OpenSansRoman-CondensedBold", size: 16))
            Text("Hello World")
                .font(Font.custom("OpenSansRoman-ExtraBold", size: 16))
            
            Text("Hello World")
                .font(Font.custom("OpenSansRoman-Light", size: 16))

            Text("Hello World")
                .font(.system(size: 16))
            Button("Tap") {
                i += 1
                print("[+] Running Tester: \(i)")

                switch i {
                case 1:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)

                case 2:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)

                case 3:
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.warning)

                case 4:
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()

                case 5:
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()

                case 6:
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                
                case 7:
                    let generator = UIImpactFeedbackGenerator(style: .rigid)
                    generator.impactOccurred()
                    
                case 8:
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()

                default:
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                    i = 0
                }
            }
        }
    }
}

struct Tester_Previews: PreviewProvider {
    static var previews: some View {
        Tester()
    }
}
