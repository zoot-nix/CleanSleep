//
//  ContentView.swift
//  Shared
//
//  Created by Owais Shaikh on 30/06/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    init(){
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UITableView.appearance().backgroundColor = .clear
        }
    
    let bgColor : Color = Color(red: 63/255, green: 48/255, blue: 71/255)
    let mainColor : Color = Color(red: 218/255, green: 212/255, blue: 239/255)
    
    @State private var WakeUp = defaultWakeUp
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    //Alert
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    //Default Wakeuptime
    static var defaultWakeUp : Date{
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView{
            Form{
               
                List{
                    Section{
                        Text("When do you want to wakeup?")
                            .font(.headline)
                            
                        DatePicker("Please enter a time", selection: $WakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .padding(10)
                    }
                }
                .listRowBackground(mainColor)
                
               List{
                   Section{
                       Text("Desired amount of sleep")
                           .font(.headline)
                       
                       Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                           .padding(10)
                   }
                }
               .listRowBackground(mainColor)
                List{
                    Section{
                        Text("Daily Coffee Intake")
                            .font(.headline)
                        
                        Stepper(coffeeAmount == 1 ? "1 Cup" : "\(coffeeAmount) Cups", value: $coffeeAmount, in: 1...20)
                            .padding(10)
                    }
                }
                .listRowBackground(mainColor)
               
                List{
                    Section{
                        HStack{
                            Spacer()
                            Button("Calculate", action: CalculateBedtime)
                                .tint(mainColor)
                                .font(.headline)
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                                .foregroundColor(Color.white)
                        }
                    }
                }
                .listRowBackground(bgColor)
                
            }   //Form
            .padding()
            .background(bgColor)
            
            .navigationTitle("Clean Sleep")
            
            /*.toolbar{
                Button("Calculate", action: CalculateBedtime)
            }*/
            .alert(alertTitle,isPresented: $showAlert){
                Button("OK"){}
            } message: {
                Text(alertMessage)
            }
        }   //NavigationView
    }   //Body
        
    func CalculateBedtime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: WakeUp)
            let hour = (components.hour ?? 0) * 60 * 60 //Converting hr to sec
            let minute = (components.minute ?? 0) * 60 //Converting min to sec
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = WakeUp - prediction.actualSleep
            alertTitle = "Clean Sleep suggests that"
            alertMessage = "You should be in bed by \(sleepTime.formatted(date: .omitted, time: .shortened))"
            
        } catch{
            alertTitle = "Error"
            alertMessage = "Oops! There was a problem calculating your bedtime"
        }
        
        showAlert = true
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
