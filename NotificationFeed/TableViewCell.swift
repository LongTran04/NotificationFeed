//
//  TableViewCell.swift
//  NotificationFeed
//
//  Created by Long Tran on 30/03/2023.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.width/2
        userImageView.layer.borderWidth = 2
        userImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCell(data: Noti) {
        userImageView.load(urlString: data.image)
        let textLabel = data.message.text
        var highlightText: [String] = []
        for i in 0..<data.message.highlights.count {
            let highlightOffset = data.message.highlights[i].offset
            let highlightLength = data.message.highlights[i].length
            let text: String = String(textLabel[textLabel.index(textLabel.startIndex, offsetBy: highlightOffset)..<textLabel.index(textLabel.startIndex, offsetBy: highlightOffset + highlightLength)])
            highlightText.append(text)
        }
        messageLabel.highlightText(highlightText, in: textLabel)
        let timeLabelText = getTimeDataToDate(timeData: data.createdAt)
        timeLabel.text = timeLabelText
        iconImageView.load(urlString: data.icon)
        if(data.status == "unread") {
            backgroundColor = UIColor(red: 0.93, green: 0.97, blue: 0.91, alpha: 1.00)
        }
        else {
            backgroundColor = .white
        }
    }
    
    func setupResultSearchCell(data: Noti, searchText: String) {
        userImageView.load(urlString: data.image)
        let textLabel = data.message.text
        let searchTexts = searchText.split(separator: " ")
        var range = (textLabel.lowercased().folded as NSString).range(of: searchTexts[0].lowercased().folded)
        for item in searchTexts {
            let itemRange = (textLabel.lowercased().folded as NSString).range(of: item.lowercased().folded)
            if(range.location > itemRange.location) {
                range = itemRange
            }
        }
        var highlightText: [String] = []
        if range.location <= 30 {
            for i in 0..<data.message.highlights.count {
                let highlightOffset = data.message.highlights[i].offset
                let highlightLength = data.message.highlights[i].length
                let text: String = String(textLabel[textLabel.index(textLabel.startIndex, offsetBy: highlightOffset)..<textLabel.index(textLabel.startIndex, offsetBy: highlightOffset + highlightLength)])
                highlightText.append(text)
            }
            messageLabel.highlightSearchText(highlightText, searchText, in: textLabel)
        }
        else {
            for i in 0..<data.message.highlights.count {
                var highlightOffset = data.message.highlights[i].offset
                var highlightLength = data.message.highlights[i].length
                if(highlightOffset < range.location - 20 && highlightOffset + highlightLength > range.location - 20) {
                    highlightLength = highlightLength - (range.location - 20 - highlightOffset)
                    highlightOffset = range.location - 20
                }
                let text: String = String(textLabel[textLabel.index(textLabel.startIndex, offsetBy: highlightOffset)..<textLabel.index(textLabel.startIndex, offsetBy: highlightOffset + highlightLength)])
                highlightText.append(text)
            }
            let textSearchResult = "...\(textLabel[textLabel.index(textLabel.startIndex, offsetBy: range.location - 20)..<textLabel.endIndex])"
            messageLabel.highlightSearchText(highlightText, searchText, in: textSearchResult)
        }
        let timeLabelText = getTimeDataToDate(timeData: data.createdAt)
        timeLabel.text = timeLabelText
        iconImageView.load(urlString: data.icon)
        if(data.status == "unread") {
            backgroundColor = UIColor(red: 0.93, green: 0.97, blue: 0.91, alpha: 1.00)
        }
        else {
            backgroundColor = .white
        }
    }
    
    func getTimeDataToDate(timeData: Int) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy, HH:mm"
        let date = Date(timeIntervalSince1970: TimeInterval(timeData))
        let dateString = formatter.string(from: date)
        return dateString
    }
    
}

extension UILabel {
    func highlightText(_ texts: [String], in mainText: String) {
        // chuyển mainText sang NSMutableAttributedString để xử lý tìm range của highlight text
        let highlightAttributedString = NSMutableAttributedString(string: mainText)
        for i in texts {
            // xác định vị trí, độ dài của text cần highlight
            let range = (mainText as NSString).range(of: i)
            // thêm thuộc tính cho đoạn text cần highlight
            highlightAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: range)
        }
        // gán giá trị vào label
        self.attributedText = highlightAttributedString
    }
    
    func highlightSearchText(_ texts: [String],_ searchText: String, in mainText: String) {
        let highlightAttributedString = NSMutableAttributedString(string: mainText)
        let searchTexts = searchText.split(separator: " ")
        for item in searchTexts {
            var text = mainText
            while(text.lowercased().folded.contains(item.lowercased().folded)) {
                var rangeSearchText = (text.lowercased().folded as NSString).range(of: item.lowercased().folded)
                let range = mainText.count - text.count
                text = String(text[text.index(text.startIndex, offsetBy: rangeSearchText.location + rangeSearchText.length)..<text.endIndex])
                rangeSearchText.location += range
                highlightAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.customColor, range: rangeSearchText)
                highlightAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: rangeSearchText)
            }
        }
        
        for i in texts {
            let range = (mainText as NSString).range(of: i)
            highlightAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: range)
        }
        self.attributedText = highlightAttributedString
    }

}

var imageCache = NSCache<NSString, UIImage>()
extension UIImageView {
    func load(urlString: String) {
        if let image = imageCache.object(forKey: urlString as NSString) {
            self.image = image
            return
        }
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        imageCache.setObject(image, forKey: urlString as NSString)
                        self?.image = image
                    }
                }
            }
        }
    }
}
