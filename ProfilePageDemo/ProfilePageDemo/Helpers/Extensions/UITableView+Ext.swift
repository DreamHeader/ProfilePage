//
//  UITableView+Ext.swift
//  ProfilePageDemo
//
//  Created by FDKCoder on 2022/9/3.
//

import UIKit

extension UITableView {
    /// Set table header view & add Auto layout.
    func setTableHeaderView(headerView: UIView) {
        headerView.translatesAutoresizingMaskIntoConstraints = false

        // Set first.
        tableHeaderView = headerView

        // Then setup AutoLayout.
        headerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }

    /// Update header view's frame.
    func updateHeaderViewFrame() {
        guard let headerView = tableHeaderView else { return }

        // Update the size of the header based on its internal content.
        headerView.layoutIfNeeded()

        // ***Trigger table view to know that header should be updated.
        let header = tableHeaderView
        tableHeaderView = header
    }
}
