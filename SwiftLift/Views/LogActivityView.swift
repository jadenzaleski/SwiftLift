//
//  LogActivityView.swift
//  SwiftLift
//
//  Created by Jaden Zaleski on 8/21/23.
//

import SwiftUI

struct LogActivityView: View {
    @EnvironmentObject var history: History
    @Binding var activity: Activity
    @State var notes = ""
    @State private var isDeleting : Bool = false
    var body: some View {
        ScrollView(showsIndicators: false) {
            HStack {
                Text("\(activity.name)")
                    .font(.largeTitle)
                Spacer()
            }
            Divider()
            HStack {
                let c = activity.warmUpSets.count
                Text(c == 1 ? "\(c) warmup set:" : "\(c) warmup sets:")
                    .font(.title2)
                Spacer()
            }
            .padding(.horizontal)
            
            ForEach(Array(activity.warmUpSets.enumerated()), id: \.element.id) { index, set in
                HStack {
                    SetPill(set: $activity.warmUpSets[index], isDeleting: $isDeleting)
                    if isDeleting {
                        Button(action: {
                            activity.warmUpSets.remove(at: index)
                            // haptic feedback
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }) {
                            Image(systemName: "trash")
                                .font(.title2)
                                .foregroundStyle(Color.red)
                        }
                        .padding(.leading, 5.0)
                    }
                }
                .padding(.vertical, 2.0)
            }
            
            Button(action: {
                activity.warmUpSets.append(SetData(reps: 0, weight: 0, isChecked: false))
                // haptic feedback
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .font(.title3)
                    Text("Add warm up set")
                        .font(.title3)
                    Spacer()
                }
            }
            .padding(.top, 5.0)
            
            HStack {
                let c = activity.workingSets.count
                Text(c == 1 ? "\(c) working set:" : "\(c) working sets:")
                    .font(.title2)
                Spacer()
            }
            .padding([.top, .horizontal])
            
            ForEach(Array(activity.workingSets.enumerated()), id: \.element.id) { index, set in
                HStack {
                    SetPill(set: $activity.workingSets[index], isDeleting: $isDeleting)
                    if isDeleting {
                        Button(action: {
                            activity.workingSets.remove(at: index)
                            // haptic feedback
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }) {
                            Image(systemName: "trash")
                                .font(.title2)
                                .foregroundStyle(Color.red)
                        }
                        .padding(.leading, 5.0)
                    }
                }
                .padding(.vertical, 2.0)
            }
            
            Button(action: {
                activity.workingSets.append(SetData(reps: 0, weight: 0.0, isChecked: false))
                // haptic feedback
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .font(.title3)
                    Text("Add working set")
                        .font(.title3)
                    Spacer()
                }
            }
            .padding(.top, 5.0)
            
            HStack {
                Text("Notes:")
                    .font(.title2)
                    .padding(.leading)
                Spacer()
            }
            .padding(.top)
            TextField("Add note", text: $notes, axis: .vertical)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .onAppear() {
                    notes = history.notesForExercise(target: activity.name) ?? ""
                }
                .onChange(of: notes) {
                    history.setNotesForExercise(target: activity.name, notes: notes)
                }
                .background(Color("lg"))
                .clipShape(RoundedRectangle(cornerRadius: 30))
        }
        .padding(.horizontal)
        // for some strange reason xcode throws and error if i combine the below two toolbars
        .toolbar {
            Button(isDeleting ? "Done" : "Edit") {
                withAnimation(.interactiveSpring) {
                    isDeleting.toggle()
                }
            }
        }
        .toolbar{
            ToolbarItemGroup(placement: .keyboard){
                    Spacer()
                    Button {
                        UIApplication.shared.dismissKeyboard()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                    .padding(.all, 5.0)
            }
        }
    }
    
}

struct LogActivity_Previews: PreviewProvider {
    static var previews: some View {
        LogActivityView(activity: .constant(.sampleActivites[1]))
            .environmentObject(History.sampleHistory)
    }
}
