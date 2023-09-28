//
//  SetView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/27/23.
//

import SwiftUI
import Combine

struct SetPill: View {
    @Binding var set: SetData
    @Binding var isDeleting: Bool
    @State private var decString: String = "0.0"
    @State private var intString: String = "0"
    var body: some View{
        HStack {
            Button {
                set.isChecked.toggle()
                // haptic feedback
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: set.isChecked ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title2)
            }
            .frame(width: 40, height: 30)
            .foregroundStyle(set.isChecked ? Color.green : Color.blue)
            Spacer()
            
            TextField("0", text: $intString)
                .numbersOnly($intString)
                .frame(width: 75)
                .font(.title2)
                .onChange(of: intString) {
                        set.setReps(string: intString)
                }
            Spacer()
            Text("/")
                .font(.title2)
            Spacer()
            TextField("0.0", text: $decString)
                .numbersOnly($decString, includeDecimal: true)
                .frame(width: 100)
                .font(.title2)
                .multilineTextAlignment(.trailing)
                .onChange(of: decString) {
                        set.setWeight(string: decString)
                }
                .padding(.trailing, 5.0)
        }
        .padding()
        .background(Color("offset"))
        .clipShape(Capsule())
        .overlay(set.isChecked ? Capsule(style: .continuous).stroke(Color.green, lineWidth: 2).padding(.horizontal, 1.0) : nil)
        .onAppear {
            intString = set.getReps()
            decString = set.getWeight()
        }
    }
}

struct SetPill_Previews: PreviewProvider {
    static var previews: some View {
        SetPill(set: .constant(SetData.sampleSets[1]), isDeleting: .constant(false))
    }
}
