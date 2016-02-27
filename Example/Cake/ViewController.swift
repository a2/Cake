//
//  ViewController.swift
//  Cake
//
//  Created by Alexsander Akers on 02/26/2016.
//  Copyright (c) 2016 Alexsander Akers. All rights reserved.
//

import Cake
import UIKit

struct Category {
    let amount: Double
    let color: UIColor
    let image: UIImage?
    let name: String
}

class ViewController: UIViewController, CakeViewDataSource, CakeViewDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var cakeView: CakeView!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    let categories = [
        Category(amount: 292.4, color: UIColor(red: 56/255, green: 138/255, blue: 226/255, alpha: 1), image: UIImage(named: "food"), name: "Food"),
        Category(amount: 131.5, color: UIColor(red: 251/255, green: 99/255, blue: 90/255, alpha: 1), image: UIImage(named: "shirt"), name: "Clothing"),
        Category(amount: 70.3, color: UIColor(red: 48/255, green: 232/255, blue: 190/255, alpha: 1), image: UIImage(named: "airplane"), name: "Airlines"),
        Category(amount: 58.48, color: UIColor(red: 252/255, green: 201/255, blue: 35/255, alpha: 1), image: UIImage(named: "bed"), name: "Hotel"),
        Category(amount: 29.12, color: UIColor(red: 128/255, green: 143/255, blue: 158/255, alpha: 1), image: UIImage(named: "cards"), name: "Entertainment"),
    ]
    var totalAmount: Double {
        return categories.lazy.map { $0.amount }.reduce(0, combine: +)
    }

    let percentageFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = .PercentStyle
        return numberFormatter
    }()

    let currencyFormatter: NSNumberFormatter = {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .CurrencyStyle
        return numberFormatter
    }()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        cakeView.dataSource = self
        cakeView.delegate = self
        totalAmountLabel.text = currencyFormatter.stringFromNumber(totalAmount)
    }
    
    // MARK: - Table View

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let category = categories[indexPath.row]
        let percent = category.amount / totalAmount

        let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath) as! CategoryCell
        cell.categoryTitleLabel.text = category.name
        cell.percentageLabel.text = percentageFormatter.stringFromNumber(percent)
        cell.percentageProgressView.progress = Float(percent)
        cell.percentageProgressView.progressTintColor = category.color
        cell.amountLabel.text = currencyFormatter.stringFromNumber(category.amount)
        cell.categoryImageView.tintColor = category.color
        cell.categoryImageView.image = category.image
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        cakeView.selectedSegmentIndex = indexPath.row
    }

    // MARK: - Cake View

    func numberOfSegmentsInCakeView(cakeView: CakeView) -> Int {
        return categories.count
    }

    func cakeView(cakeView: CakeView, fillColorForSegmentAtIndex index: Int) -> UIColor {
        return categories[index].color
    }

    func cakeView(cakeView: CakeView, valueForSegmentAtIndex index: Int) -> Double {
        return categories[index].amount
    }

    func cakeView(cakeView: CakeView, willDeselectSegmentAtIndex index: Int) {

    }

    func cakeView(cakeView: CakeView, didDeselectSegmentAtIndex index: Int) {

    }

    func cakeView(cakeView: CakeView, willSelectSegmentAtIndex index: Int) {

    }

    func cakeView(cakeView: CakeView, didSelectSegmentAtIndex index: Int) {
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), animated: true, scrollPosition: .None)
    }
}
