//
//  HeaderCellDelegate.swift
//  TemplateOfDealsViewer
//
//  Created by Денис Павлов on 03.04.2023.
//

import Foundation

protocol HeaderCellDelegate: AnyObject {
    func needSortTable(with sortParameters: SortParameters)
}
