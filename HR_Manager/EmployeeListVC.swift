//
//  EmployeeListVC.swift
//  HR_Manager
//
//  Created by 윤재웅 on 2021/01/24.
//

import UIKit

class EmployeeListVC: UITableViewController {
    
    // 데이터 소스를 저장할 맴버 변수
    var empList: [EmployeeVO]!
    
    // SQLite 처리를 담당할 DAO 클래스
    var empDAO = EmployeeDAO()
    
    // MARK: - View cycle
    override func viewDidLoad() {
        self.empList = self.empDAO.find()
        self.initUI()
    }
    
    
    // MARK: - UI init
    func initUI() {
        
        // 내비게이션 타이틀용 레이블 속성 설정
        let navTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        navTitle.font = UIFont.systemFont(ofSize: 15)
        navTitle.text = "사원 목록 \n" + " 총 \(self.empList.count) 명"
        
        self.navigationItem.titleView = navTitle
    }
    
    // MARK: - tableView delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.empList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowData = self.empList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EMP_CELL")
        
        // 사원명 + 재직 상태 출력
        cell?.textLabel?.text = rowData.empName + "(\(rowData.stateCd.desc())"
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        
        cell?.detailTextLabel?.text = rowData.departTitle
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        
        return cell!
    }
}
