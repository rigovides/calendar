//
//  ViewController.swift
//  CalendarMVP
//
//  Created by Rigoberto Antonio Vides Rodriguez on 11/6/19.
//  Copyright © 2019 Rigoberto Antonio Vides Rodriguez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.autoupdatingCurrent
        return calendar
    }()

    private var monthNames: [String] {
        return self.calendar.monthSymbols
    }

    private let dates: [[Date?]] = {
        let calendar = Calendar(identifier: .gregorian)
        let initialDate = Date(timeIntervalSinceReferenceDate: 3600 * 24)
        var dates = [[Date?]]()
        let allDates = (0...365 * 400).compactMap { calendar.date(byAdding: .day, value: $0, to: initialDate) }

        let endDate = calendar.date(byAdding: .day, value: (365 * 400), to: initialDate)

        let components = calendar.dateComponents([.month], from: initialDate, to: endDate!)

        var currentDateIndex = 0
        for i in 0...components.month! {
            var monthDates = [Date?]()
            for j in currentDateIndex..<allDates.count {
                let date = allDates[j]

                //add empty slots depending on starting day of the week
                if monthDates.isEmpty {
                    let components = calendar.dateComponents([.day, .weekday], from: date)

                    for n in (1...7) {
                        if components.weekday == n {
                            break
                        }
                        monthDates.append(nil)
                    }
                }

                monthDates.append(date)

                //calculate change of month
                if allDates.indices.contains(j+1) {
                    let nextDate = allDates[j+1]
                    let nextDay = calendar.component(.day, from: nextDate)
                    if nextDay == 1 {
                        dates.append(monthDates)
                        currentDateIndex = j + 1
                        break
                    }
                }
            }
        }

        return dates
    }()

    private var itemSize: CGSize = .zero

    override func viewDidLoad() {
        super.viewDidLoad()

        let width = self.collectionView.visibleSize.width/7
        self.itemSize = CGSize(width: width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.dates.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dates[section].count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId", for: indexPath)

        if let label = header.viewWithTag(111) as? UILabel {
            label.text = self.monthNames[indexPath.section % self.monthNames.count]
        }

        return header
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayId", for: indexPath)
        cell.contentView.backgroundColor = .none

        guard let date = self.dates[indexPath.section][indexPath.item] else {
            if let label = cell.contentView.viewWithTag(111) as? UILabel {
                label.text = ""
                cell.contentView.backgroundColor = .quaternarySystemFill
            }
            return cell
        }

        if let label = cell.contentView.viewWithTag(111) as? UILabel {
            let components = self.calendar.dateComponents([.day], from: date)
            label.text = String(components.day!)
        }

        return cell
    }
}
