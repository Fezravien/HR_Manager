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
    
    
    // MARK: - View cycle
    override func viewDidLoad() {
        self.departList = self.departDAO.find() // 기존 저장된 부서 정보를 가져온다.
        self.initUI()
    }
    
    // MARK: - UI 초기화
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
    
    // MARK: - tableView delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.departList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // indexPath 매개변수가 가리키는 행에 대한 데이터를 읽어온다.
        let rowData = self.departList[indexPath.row]
        
        // 셀 객체를 생성하고 데이터를 배치한다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "DEPART_CELL")
        
        cell?.textLabel?.text = rowData.departTitle
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        
        cell?.detailTextLabel?.text = rowData.departAddr
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        
        return cell!
    }
    
    // 편집
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)  {
        
        // 삭제할 행의 departCd를 구한다.
        let departCd = self.departList[indexPath.row].departCd
        
        // DB에서, 데이터 소스에서, 그리고 테이블 뷰에서 차례대로 삭제한다.
        if departDAO.remove(departCd) {
            self.departList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - 사원 등록
    @IBAction func add(_ sender: Any) {
        
        let alert = UIAlertController(title: "신규 부서 등록", message: "신규 부서를 등록해 주세요", preferredStyle: .alert)
        
        // 부서명 및 주소 입력용 덱스트 필드 추가
        alert.addTextField { $0.placeholder = "부서명"}
        alert.addTextField { $0.placeholder = "주소"}
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in // 확인 버튼
            
            let title = alert.textFields?[0].text // 부서명
            let addr = alert.textFields?[1].text // 부서 주소
            
            if self.departDAO.create(title!, addr!) {
                
                // 신규 부서가 등록되면 DB에서 목록을 다시 읽어온 후, 테이블을 갱신해 준다.
                self.departList = self.departDAO.find()
                self.tableView.reloadData()
                
                // 내비게이션 타이틀에도 변경된 부서 정보를 반영한다.
                let navTitle = self.navigationItem.titleView as! UILabel
                navTitle.text = "부서 목록 \n" + " 총 \(self.departList.count) 개"
            }
        })
        
        self.present(alert, animated: false)
        
    }
}
