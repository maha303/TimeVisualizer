//
//  GraphViewController.swift
//  TimeVisualizer
//
//  Created by Maha saad on 20/05/1443 AH.
//

import UIKit
import Charts
import CalendarKit

enum CurrentChart{
    case pie
    case bar
    case line
}

class GraphViewController: UIViewController , UITextFieldDelegate {
   
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard let text = textField.text else{
                return false
            }
            print(text)
            word1Text = text
            
            makePieChart()
            makeBarChart()
            makeLineChart()
            
            
            return true
        }
        
        @IBOutlet weak var chartsView: UIView!
        
        var events: [EventDescriptor]?
        
        var word1Text: String?
        
        @IBOutlet weak var word6: UITextField!
        @IBOutlet weak var word5: UITextField!
        
        @IBOutlet weak var word4: UITextField!
        @IBOutlet weak var word3: UITextField!
        @IBOutlet weak var word2: UITextField!
        @IBOutlet weak var word1: UITextField!
        
        let pieChartView = PieChartView(frame: .zero)
        let barChartView = BarChartView(frame: .zero)
        let lineChartView = LineChartView(frame: .zero)
        
        let colors: [UIColor] = [
            .systemMint, .systemYellow, .systemRed,
            .systemBlue, .systemGreen, .systemBrown
        ]

        
        var currentChart: CurrentChart = .bar
        
    override func viewDidLoad() {
        super.viewDidLoad()
        word1.delegate = self
        word1.text = word1Text
        makePieChart()
        pieChartView.isHidden = false
        makeBarChart()
        makeLineChart()
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedChart))
        gesture.direction = .left
        view.addGestureRecognizer(gesture)
        loadWordColors()


        // Do any additional setup after loading the view.
    }
        func loadWordColors(){
            word1.textColor = colors[0]
            word2.textColor = colors[1]
            word3.textColor = colors[2]
            word4.textColor = colors[3]
            word5.textColor = colors[4]
            word6.textColor = colors[5]
        }
        
        @objc func swipedChart(){
            print("Change the chart")
            switch currentChart{
            case .pie:
                pieChartView.isHidden = false
                barChartView.isHidden = true
                lineChartView.isHidden = true
                currentChart = .bar
                
            case .bar:
                pieChartView.isHidden = true
                barChartView.isHidden = false
                lineChartView.isHidden = true
                currentChart = .line
            case .line:
                pieChartView.isHidden = true
                barChartView.isHidden = true
                lineChartView.isHidden = false
                currentChart = .pie
            }
            
            
        }
        func grabWordsToAnalyze() -> [String]{
            guard let word1 = word1.text,let word2 = word2.text,
                  let word3 = word3.text,let word4 = word4.text,
                  let word5 = word5.text,let word6 = word6.text else{
                      return []
                  }
            return [word1,word2,word3,word4,word5,word6]
            
        }
        func grabWordsToAnalyzeData()->[Double]{
            guard let word1 = word1.text,let word2 = word2.text,
                  let word3 = word3.text,let word4 = word4.text,
                  let word5 = word5.text,let word6 = word6.text,
                  let events = events else{
                      return []
                  }
            
            var count1 = 0.0
            var count2 = 0.0
            var count3 = 0.0
            var count4 = 0.0
            var count5 = 0.0
            var count6 = 0.0
            
            for event in events {
                if event.text.lowercased().contains(word1.lowercased()){
                    count1 += 1
                }else if event.text.lowercased().contains(word2.lowercased()){
                    count2 += 1
                }else if event.text.lowercased().contains(word3.lowercased()){
                    count3 += 1
                }else if event.text.lowercased().contains(word4.lowercased()){
                    count4 += 1
                }else if event.text.lowercased().contains(word5.lowercased()){
                    count5 += 1
                }else if event.text.lowercased().contains(word6.lowercased()){
                    count6 += 1
                }
            }
            
            return [count1,count2,count3,count4,count5,count6]
            
        }
        
        func makeLineChart(){
            let dataPoints = grabWordsToAnalyze()
            let values = grabWordsToAnalyzeData()
            lineChartView.frame = chartsView.frame
            lineChartView.isHidden = true
            view.addSubview(lineChartView)
            
            var dataEntries: [ChartDataEntry] = []
            for i in 0..<dataPoints.count {
              let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
              dataEntries.append(dataEntry)
            }
            
            let lineChartDataSet = LineChartDataSet(entries: dataEntries, label: "Make Words")
            let lineChartData = LineChartData(dataSet: lineChartDataSet)
            lineChartView.data = lineChartData
        }
        
        func makeBarChart(){
            let dataPoints = grabWordsToAnalyze()
            let values = grabWordsToAnalyzeData()
            barChartView.frame = chartsView.frame
            barChartView.isHidden = true
            view.addSubview(barChartView)
            var dataEntries: [BarChartDataEntry] = []
            for i in 0..<dataPoints.count {
              let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
              dataEntries.append(dataEntry)
            }
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
            let chartData = BarChartData(dataSet: chartDataSet)
            barChartView.data = chartData
        }
        
        func makePieChart(){
            let dataPoints = grabWordsToAnalyze()
            let values = grabWordsToAnalyzeData()
            pieChartView.frame = chartsView.frame
            pieChartView.isHidden = false
            view.addSubview(pieChartView)
            
            var dataEntries: [ChartDataEntry] = []
              for i in 0..<dataPoints.count {
                let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject)
                dataEntries.append(dataEntry)
              }
              // 2. Set ChartDataSet
            let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "pie Chart View")
            pieChartDataSet.colors = self.colors
            // 3. Set ChartData
            let pieChartData = PieChartData(dataSet: pieChartDataSet)
            let format = NumberFormatter()
            format.numberStyle = .none
            let formatter = DefaultValueFormatter(formatter: format)
            pieChartData.setValueFormatter(formatter)
            // 4. Assign it to the chart’s data
            pieChartView.data = pieChartData
        }
}
