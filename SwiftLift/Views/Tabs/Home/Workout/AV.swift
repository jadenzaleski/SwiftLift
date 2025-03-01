//
//  AV.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 2/28/25.
//

import SwiftUI

struct AV: View {
    @Binding var activity: Activity
    
    var body: some View {
        TextField("\($activity.name)", text: $activity.name)
    }
}

#Preview {
    AV(activity: .constant(Activity(name: "tester", gym: "default")))
}
