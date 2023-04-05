import UIKit

class ViewController: UIViewController {
    private let server = Server()
    
    
    private var model: [Deal] = [] 
    private var sortedModel: [Deal] = []
    private var tempModel: [Deal] = []
    @IBOutlet weak var tableView: UITableView!
    
    private let semaphore = DispatchSemaphore(value: 1)
    
    private var sortParameters = SortParameters(label: .instrument, direction: .down)
    private let pageSize = 40
    private var currentPage = 0
    private var totalPages = 0
    private var isFirstSort = true
    
    private var sortQueue = DispatchQueue(label: "sort.queue", qos: .unspecified, attributes: .concurrent)
    private var updateTableTimer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Deals"

        tableView.register(UINib(nibName: DealCell.reuseIidentifier, bundle: nil), forCellReuseIdentifier: DealCell.reuseIidentifier)
        tableView.register(UINib(nibName: HeaderCell.reuseIidentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: HeaderCell.reuseIidentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        
        updateTableTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            self.sortQueue.async {
                self.semaphore.wait()
                self.sortModel()
                if !self.tempModel.isEmpty {
                    self.sortedModel.append(contentsOf: self.tempModel)
                    self.totalPages = (self.sortedModel.count + self.pageSize - 1) / self.pageSize
                    self.tempModel.removeAll()
                }
                self.semaphore.signal()
                DispatchQueue.main.async {
                    self.updateTableView()
                }
            }
            
        }
        RunLoop.current.add(updateTableTimer!, forMode: .common)
        
        server.subscribeToDeals { [weak self] deals in
            guard let self = self else { return }

            self.semaphore.wait()
            self.tempModel.append(contentsOf: deals)
            self.semaphore.signal()
            if self.isFirstSort {
                self.isFirstSort = false
                self.sortQueue.async {
                    self.semaphore.wait()
                    self.sortModel()
                    if !self.tempModel.isEmpty {
                        self.sortedModel.append(contentsOf: self.tempModel)
                        self.totalPages = (self.sortedModel.count + self.pageSize - 1) / self.pageSize
                        self.tempModel.removeAll()
                    }
                    self.semaphore.signal()
                    DispatchQueue.main.async {
                        self.updateTableView()
                    }
                }
            }

        }
        
        
        
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DealCell.reuseIidentifier, for: indexPath) as! DealCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? DealCell else { return }
        
        cell.instrumentNameLabel.text = String(model[indexPath.row].instrumentName)
        
        cell.priceLabel.text = String(format: "%0.2f", model[indexPath.row].price)
        cell.amountLabel.text = String(format: "%d", Int(model[indexPath.row].amount.rounded()))
        cell.dateModifier.text = model[indexPath.row].dateModifier.formatted()
        switch model[indexPath.row].side {
        case .sell:
            cell.sideLabel.text = String("sell")
            cell.sideLabel.textColor = .red
        case .buy:
            cell.sideLabel.text = String("buy")
            cell.sideLabel.textColor = .green
        }
    }
  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderCell.reuseIidentifier) as! HeaderCell
        cell.delegate = self
        return cell
    }
    

    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height

        // Если мы прокрутили таблицу вниз до конца
        if offsetY > contentHeight - height {
            if currentPage < totalPages - 1 {
                currentPage += 1
                let startIndex = currentPage * pageSize
                semaphore.wait()
                let endIndex = min(startIndex + pageSize, sortedModel.count)
                model.append(contentsOf: sortedModel[startIndex ..< endIndex])
                semaphore.signal()
                if model.count > 200 {
                    let removeCount = model.count - 200
                    model.removeFirst(removeCount)
                }
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: model.count - 20, section: 0), at: .bottom, animated: false)
            }
        }
        
        // Если мы прокрутили таблицу вверх до начала
        if offsetY < 0 {
            if currentPage > 0 {
                currentPage -= 1
                let startIndex = currentPage * pageSize
                semaphore.wait()
                let endIndex = min(startIndex + pageSize, sortedModel.count)
                model.insert(contentsOf: sortedModel[startIndex ..< endIndex], at: 0)
                semaphore.signal()
                if model.count > 200 {
                    let removeCount = model.count - 200
                    model.removeLast(removeCount)
                }
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: pageSize - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }


//  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//    return 60
//  }
}

// MARK: - HeaderCellDelegate
extension ViewController: HeaderCellDelegate {
    func needSortTable(with sortParameters: SortParameters) {
        print("needSortTable")
        self.sortParameters = sortParameters
        let activiryIndicator = UIActivityIndicatorView(style: .large)
        if sortedModel.count > 50_000 {
            
            activiryIndicator.center = view.center
            activiryIndicator.startAnimating()
            view.addSubview(activiryIndicator)
        }
        
        
        sortQueue.async {
            self.semaphore.wait()
            self.sortModel()
            self.semaphore.signal()
            DispatchQueue.main.async {
                if self.sortedModel.count > 50_000 {
                    activiryIndicator.removeFromSuperview()
                }
                self.updateTableView()
            }
        }
        
    }

    
    
}

// MARK: - pagination
private extension ViewController {
    func updateModel() {
        let startIndex = currentPage * pageSize
        let endIndex = min(startIndex + pageSize, sortedModel.count)
        model = Array(sortedModel[startIndex..<endIndex])
    }
    
    func updateTableView() {
        let startTime = Date().timeIntervalSince1970
        updateModel()
        tableView.reloadData()
        let endTime = Date().timeIntervalSince1970
        print(endTime - startTime)
    }
}

// MARK: - sorting function
private extension ViewController {
    func sortModel() {
        
        //print("sort!!!!")
        switch sortParameters.label {
        case .instrument :
            if sortParameters.direction == .up {
                sortedModel.sort { $0.instrumentName < $1.instrumentName }
            } else {
                sortedModel.sort { $0.instrumentName > $1.instrumentName }
            }
        case .date:
            if sortParameters.direction == .up {
                sortedModel.sort { $0.dateModifier < $1.dateModifier }
            } else {
                sortedModel.sort { $0.dateModifier > $1.dateModifier }
            }
        case .side:
            if sortParameters.direction == .up {
                sortedModel.sort { ($0.side.hashValue < $1.side.hashValue) }
            } else {
                sortedModel.sort { ($0.side.hashValue > $1.side.hashValue) }
            }
        case .amount:
            if sortParameters.direction == .up {
                sortedModel.sort { $0.amount < $1.amount }
            } else {
                sortedModel.sort { $0.amount > $1.amount }
            }
        case .price:
            if sortParameters.direction == .up {
                sortedModel.sort { $0.price < $1.price }
            } else {
                sortedModel.sort { $0.price > $1.price }
            }
        }
        
        
        
        
    }
}
