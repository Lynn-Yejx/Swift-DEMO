//
//  DetailViewController.swift
//  FMDB_DEMO
//
//  Created by ShaoFeng on 2017/4/3.
//  Copyright © 2017年 ShaoFeng. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    var page: Int = 1
    var dataArray = Array<DetailModel>()
    var searchArray = Array<DetailModel>()
    
    var isSearching = false
    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        DetailDAO.shareDAO.creatTable()
        makeData()

        //全量加载
        // dataArray = DetailDAO.shareDAO.getDataList() as! Array<DetailModel>
        // 分页加载
        dataArray = DetailDAO.shareDAO.pageReadDataListWith(page: page) as! Array<DetailModel>
        
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
    
    private func makeData() {
        for i in 0..<1000 {
            let model = DetailModel()
            model.desId = i
            model.des = i % 3 == 0 ? "Java---\(i)" : i % 3 == 1 ? "Objective_C---\(i)" : "Swift---\(i)"
            DetailDAO.shareDAO.insertData(model: model)
        }
    }
}

extension DetailViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = isSearching ? searchArray[indexPath.row] : dataArray[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "ID")
        if !(cell != nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: "ID")
        }
        cell?.textLabel?.text = model.des
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? searchArray.count : dataArray.count
    }
   
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.height {
            print("滑动到底部加载多")
            page += 1
            let array = DetailDAO.shareDAO.pageReadDataListWith(page: page) as! Array<DetailModel>
            dataArray.append(contentsOf: array) //数组拼接数组
            tableView.reloadData()
        }
    }
}

extension DetailViewController: UISearchResultsUpdating,UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let array = DetailDAO.shareDAO.getDataListWithString(string: searchController.searchBar.text!) as! Array<DetailModel>
        searchArray = array
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
        searchArray = []
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchArray = []
    }
}
