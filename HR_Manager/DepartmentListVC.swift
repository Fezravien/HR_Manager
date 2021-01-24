//
//  DepartmentListVC.swift
//  HR_Manager
//
//  Created by 윤재웅 on 2021/01/24.
//

import UIKit

class DepartmentListVC: UITableViewController {
    
    var departList: [(departCd: Int, departTitle: String, departAddr: String)]! // 데이터 소스용 맴버 변수
    let departDAO = DepartmentDAO() // SQLite 처리를 담당할 DAO 객체
    
    override func viewDidLoad() {
        self.departList = self.departDAO.find() // 기존 저장된 부서 정보를 가져온다.
        self.initUI()
    }
    
    // UI 초기화 함수
    func initUI() {
        
        // 내비게이션 타이틀용 레이블 속성 설정
        let navTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        navTitle.numberOfLines = 2
        navTitle.textAlignment = .center
        navTitle.font = UIFont.systemFont(ofSize: 15)
        navTitle.text = "부서 목록 \n" + " 총 \(self.departList.count) 개"
        
        // 내비게이션 바 UI 설정
        self.navigationItem.titleView = navTitle
        self.navigationItem.leftBarButtonItem = self.editButtonItem // 편집 버튼 추가
        
        // 셀을 스와이프했을 때 편집 모드가 되도록 설정
        self.tableView.allowsSelectionDuringEditing = true
    }
    
}
