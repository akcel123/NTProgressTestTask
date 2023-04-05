import UIKit

// TODO: попробовать реализовать не лейблы, а кнопки!!!!!!!!!
class HeaderCell: UITableViewHeaderFooterView {
    static let reuseIidentifier = "HeaderCell"
  
    var sortParameters = SortParameters(label: .instrument, direction: .down)
    weak var delegate: HeaderCellDelegate?
    
    
    @IBOutlet weak var instrumentNameTitlLabel: UILabel!
    @IBOutlet weak var priceTitleLabel: UILabel!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var sideTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!


    override func layoutSubviews() {
        super.layoutSubviews()
        
        let instrumentNameGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnInstrumentName))
        let priceGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnPrice))
        let amountGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnAmount))
        let sideGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnSide))
        let dateGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnDate))
     
        instrumentNameTitlLabel.addGestureRecognizer(instrumentNameGesture)
        priceTitleLabel.addGestureRecognizer(priceGesture)
        amountTitleLabel.addGestureRecognizer(amountGesture)
        sideTitleLabel.addGestureRecognizer(sideGesture)
        dateLabel.addGestureRecognizer(dateGesture)
        
        instrumentNameTitlLabel.isUserInteractionEnabled = true
        priceTitleLabel.isUserInteractionEnabled = true
        amountTitleLabel.isUserInteractionEnabled = true
        sideTitleLabel.isUserInteractionEnabled = true
        dateLabel.isUserInteractionEnabled = true
        
        
    }
    
    @objc func didTapOnInstrumentName() {
        if sortParameters.label != .instrument {
            sortParameters.label = .instrument
            sortParameters.direction = .down
            setupLabelsText()
            delegate?.needSortTable(with: sortParameters)
            return
        }
        switchDirection()
    }
    
    @objc func didTapOnPrice() {
        if sortParameters.label != .price {
            sortParameters.label = .price
            sortParameters.direction = .down
            setupLabelsText()
            delegate?.needSortTable(with: sortParameters)
            return
        }
        switchDirection()
    }
    
    @objc func didTapOnAmount() {
        if sortParameters.label != .amount {
            sortParameters.label = .amount
            sortParameters.direction = .down
            setupLabelsText()
            delegate?.needSortTable(with: sortParameters)
            return
        }
        switchDirection()
    }
    
    @objc func didTapOnSide() {
        if sortParameters.label != .side {
            sortParameters.label = .side
            sortParameters.direction = .down
            setupLabelsText()
            delegate?.needSortTable(with: sortParameters)
            return
        }
        switchDirection()
    }
    
    @objc func didTapOnDate() {
        if sortParameters.label != .date {
            sortParameters.label = .date
            sortParameters.direction = .down
            setupLabelsText()
            delegate?.needSortTable(with: sortParameters)
            return
        }
        switchDirection()
    }

    
    private func setupLabelsText() {
        instrumentNameTitlLabel.text = "Instruments"
        amountTitleLabel.text = "Amount"
        sideTitleLabel.text = "Side"
        dateLabel.text = "Date"
        priceTitleLabel.text = "Price"

        switch sortParameters.label {
        case .side:
            sideTitleLabel.text = sortParameters.label.rawValue + " " + sortParameters.direction.rawValue
        case .price:
            priceTitleLabel.text = sortParameters.label.rawValue + " " + sortParameters.direction.rawValue
        case .amount:
            amountTitleLabel.text = sortParameters.label.rawValue + " " + sortParameters.direction.rawValue
        case .date:
            dateLabel.text = sortParameters.label.rawValue + " " + sortParameters.direction.rawValue
        case .instrument:
            instrumentNameTitlLabel.text = sortParameters.label.rawValue + " " + sortParameters.direction.rawValue
            
        }
    }
    
    private func switchDirection() {
        sortParameters.direction = sortParameters.direction == .up ? .down : .up
        setupLabelsText()
        delegate?.needSortTable(with: sortParameters)
    }
    

}
