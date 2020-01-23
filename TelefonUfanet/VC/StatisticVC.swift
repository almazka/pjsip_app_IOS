//
//  StatisticVC.swift
//  TelefonUfanet
//
//  Created by Almaz on 24/06/2019.
//  Copyright © 2019 Brian Daneshgar. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON
import Alamofire



@available(iOS 11.0, *)

class StatisticVC: UIViewController, UITextFieldDelegate {
    
    
    private let numEntry = 2
    

    var out_call_success = PieChartDataEntry(value: 0)
    var out_call_failed = PieChartDataEntry(value: 0)
    var inc_call_success = PieChartDataEntry(value: 0)
    var inc_call_failed = PieChartDataEntry(value: 0)
    
    var numberOfDownloadsDataEntries = [PieChartDataEntry]()
    var numberOfDownloadsDataEntries2 = [PieChartDataEntry]()

    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var info_view: UIView!
    @IBOutlet weak var sec_average: UILabel!
    @IBOutlet weak var Scroll: UIScrollView!
    @IBOutlet weak var percent_average: UILabel!
    @IBOutlet weak var date_first: UITextField!
    @IBOutlet weak var date_second: UITextField!
    @IBOutlet weak var b_submit: UIButton!
    @IBOutlet weak var PieView: PieChartView!
    @IBOutlet weak var inc_out_call: UILabel!
    @IBOutlet weak var call_time_average: UILabel!
    @IBOutlet weak var basicBarChart: BasicBarChart!
    @IBOutlet weak var inc_calls: UILabel!
    @IBOutlet weak var inc_call_PieChart: PieChartView!
    var body : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Scroll.isScrollEnabled = false
        self.progress.stopAnimating()
        self.hideKeyboard()
        
        
        
        PieView.chartDescription?.text = ""
        PieView.holeRadiusPercent = 0.1
        PieView.transparentCircleRadiusPercent = 0.1
        PieView.isUserInteractionEnabled = false
        
        
        inc_call_PieChart.chartDescription?.text = ""
        inc_call_PieChart.holeRadiusPercent = 0.1
        inc_call_PieChart.transparentCircleRadiusPercent = 0.1
        inc_call_PieChart.isUserInteractionEnabled = false
        
        
        out_call_success.value = 25
        out_call_success.label = "Успешные"
        
        out_call_failed.value = 15
        out_call_failed.label = "Неуспешные"
        
        
        inc_call_success.value = 100
        inc_call_success.label = "Успешные"
        
        inc_call_failed.value = 16
        inc_call_failed.label = "Неуспешные"

        
        numberOfDownloadsDataEntries = [out_call_success, out_call_failed]
        numberOfDownloadsDataEntries2 = [inc_call_success, inc_call_failed]
        
        updateChartData()
        updateChartData2()
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let year: String  =  String(components.year as! Int)
        var month: String  = String(components.month as! Int)
        var day : String = String(components.day as! Int)
        
        if(day.count < 2) {
            day = "0" + day
        }
        if (month.count < 2) {
            month = "0" + month
        }
        self.date_first.text = year + "-" + month + "-" + day + " 00:00:00"
        self.date_second.text = year + "-" + month + "-" + day + " 23:59:59"
    }
    
    


    
    func updateChartData() {
        
        let chartDataSet = PieChartDataSet(entries: numberOfDownloadsDataEntries, label: nil)
        chartDataSet.sliceSpace = 2
        let chartData = PieChartData(dataSet: chartDataSet)
        
       
        let colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)]
    
        chartDataSet.colors = colors
        
        PieView.data = chartData
        
        
    }
    
    func updateChartData2() {
        
        let chartDataSet = PieChartDataSet(entries: numberOfDownloadsDataEntries2, label: nil)
        chartDataSet.sliceSpace = 2
        let chartData = PieChartData(dataSet: chartDataSet)
        
        
        let colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)]
        
        chartDataSet.colors = colors
        
        self.inc_call_PieChart.data = chartData
        
        
    }

    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }

    @IBAction func b_submit(_ sender: Any) {
        
        
        if (self.date_first.text?.count == 0 && self.date_second.text?.count == 0) {
            self.alert(title: "Ошибка!", message: "Пожалуйста? укажите период", style: .alert)
        }
        else {
            let string: String = self.date_first.text!
            let string2: String = self.date_second.text!
            let endIndex = string.index(string.startIndex, offsetBy: 10)
            let endIndex2 = string2.index(string2.startIndex, offsetBy: 10)
            let date1 = string.substring(to: endIndex)
            let date2 = string2.substring(to: endIndex2)
            
            
            self.progress.startAnimating()
            let token = (self.tabBarController?.viewControllers?[2] as? SoftPhoneVC)?.token
    
            DispatchQueue.main.async {
        
                
                Alamofire.request("https://telefon.ufanet.ru/api/Home?date1="+date1+"%2000:00:00&date2="+date2+"%2023:00:00",  method: .get, encoding: JSONEncoding.default, headers: ["Authorization": token!]).responseJSON {
                    
                    (response) -> Void in
                    if let value = response.result.value {
                        let json = JSON(value)
                        
        
                        let parent_obj = json[0].dictionaryValue
                        
        
                        let percentSuccess = parent_obj["percentIncSucces"]!.stringValue
                        let wait = parent_obj["averageWaitDuration"]!.stringValue
                        
                        self.sec_average.text = wait + "с"
                        self.percent_average.text = percentSuccess + "%"
                        
                        self.info_view.isHidden = false
                        
                        
                        
                        Alamofire.request("https://telefon.ufanet.ru/api/Statistics/GetNumbers",  method: .get, headers: ["Authorization": token!]).responseString {
                            
                            (response) -> Void in
                            self.body = response.result.value!
                            
                            var request_statistic = URLRequest(url: URL(string: "https://telefon.ufanet.ru/api/Statistics?date1="+date1+"%2000:00:00&date2="+date2+"%2023:59:59")!)
                            request_statistic.httpMethod = HTTPMethod.post.rawValue
                            request_statistic.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            request_statistic.setValue(token!, forHTTPHeaderField: "Authorization")
                            
                            
                            let endIndex = self.body.index(self.body.endIndex, offsetBy: -1)
                            var truncated = self.body.substring(to: endIndex)
                            truncated = String(truncated.dropFirst())
                            
                            
                            let data = Data(truncated.utf8)
                            
                            
                            request_statistic.httpBody = data
                            
                            Alamofire.request(request_statistic).responseJSON {
                                (response_stat) in
                                
                                if let value = response_stat.result.value {
                                    let json = JSON(value)
                                    
                                    
                                    
                                    let outgoing_total = json["outgoing_total"].intValue
                                    let outgoing_success = json["outgoing_success"].intValue
                                    let outgoing_fail = json["outgoing_fail"].intValue
                                    let out_duration_avg = json["out_duration_avg"].intValue
                                    let inc_duration_avg = json["inc_duration_avg"].intValue
                                    let incoming_success = json["incoming_success"].intValue
                                    let incoming_total = json["incoming_total"].intValue
                                    let incoming_fail = json["incoming_fail"].intValue
                                    
                                    
                                    self.out_call_success.value = Double(outgoing_success)
                                    self.out_call_failed.value = Double(outgoing_fail)
                                    self.updateChartData()
                                    
                                    
                                    self.inc_call_success.value = Double(incoming_success)
                                    self.inc_call_failed.value = Double(incoming_fail)
                                    self.updateChartData2()
                                    
                                    
                                    
                                    let colors = [ #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)]
                                    var entry: [DataEntry] = []
                                    let all_avg: Float = Float(out_duration_avg + inc_duration_avg)
                                    if (all_avg == 0) {
                                        entry.append(DataEntry(color: colors[0], height: 0.5, textValue: "\(inc_duration_avg)", title: "Входящие"))
                                        entry.append(DataEntry(color: colors[1], height: 0.5, textValue: "\(out_duration_avg)", title: "Исходящие"))
                                    }
                                    else {
                                        let height: Float = (Float(inc_duration_avg) / all_avg)
                                        let height2: Float = (Float(out_duration_avg) / all_avg)
                                        entry.append(DataEntry(color: colors[0], height: height, textValue: "\(inc_duration_avg)", title: "Входящие"))
                                        entry.append(DataEntry(color: colors[1], height: height2, textValue: "\(out_duration_avg)", title: "Исходящие"))
                                    }
                                    
                            
                                    self.basicBarChart.updateDataEntries(dataEntries: entry, animated: true)
                                    
                                    
                                    self.Scroll.isScrollEnabled = true
                                    self.progress.stopAnimating()
                                    self.PieView.isHidden = false
                                    self.inc_out_call.isHidden = false
                                    self.call_time_average.isHidden = false
                                    self.basicBarChart.isHidden = false
                                    self.inc_calls.isHidden = false
                                    self.inc_call_PieChart.isHidden = false
                                    
                                }
                                
                            }
                            
                        }
                        
                
                    }
                }
                
                }
            
           
        }
        
       
    }


    

    @IBAction func textFierdEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.date_first.text = dateFormatter.string(from: sender.date) + " 00:00:00"
    }
    
    @IBAction func DateText2Editing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged2), for: UIControl.Event.valueChanged)
    }
    
    
    @objc func datePickerValueChanged2(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        self.date_second.text = dateFormatter.string(from: sender.date) + " 23:59:59"
    }
    
    func alert(title : String, message: String, style : UIAlertController.Style) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: style)
        let action = UIAlertAction (title: "ОК", style: .default) { (action) in
            
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
