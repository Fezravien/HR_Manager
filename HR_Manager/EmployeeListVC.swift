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
    
    // 새로고침 컨트롤에 들어갈 이미지 뷰
    var loadingImg: UIImageView!
    
    // 임계점에 도달했을 떄 나타날 배경 뷰, 노란 원 형태
    var bgCircle: UIView!
    
    // MARK: - View cycle
    override func viewDidLoad() {
        self.empList = self.empDAO.find()
        self.initUI()
        
        // 당겨서 새로고침 기능
        self.refreshControl = UIRefreshControl()
        //self.refreshControl?.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        
        // 로딩 이미지 초기화 & 중앙 정렬
        self.loadingImg = UIImageView(image: UIImage(named: "refresh"))
        self.loadingImg.center.x = (self.refreshControl?.frame.width)! / 2
        
        // refreshControl의 tintColor 값을 제거하여 기본 로딩 이미지인 인디케이터 뷰를 숨기고, 로딩 이미지 뷰를 서브 뷰로 등록
        self.refreshControl?.tintColor = .clear
        self.refreshControl?.addSubview(self.loadingImg)
        
        self.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        
        // 배경 뷰 초기화 및 노란 원 형태를 위한 속성 설정
        self.bgCircle = UIView()
        self.bgCircle.backgroundColor = UIColor.systemOrange
        self.bgCircle.center.x = (self.refreshControl?.frame.width)! / 2
        
        // 배경 뷰를 refreshControl 객체에 추가하고, 로딩 이미지를 제일 위로 올림
        self.refreshControl?.addSubview(self.bgCircle)
        self.refreshControl?.bringSubviewToFront(self.loadingImg)
    }
    
    // MARK: - refresh
    @objc func pullToRefresh(_ sender: Any) {
        
        // 새로고침 시 갱신되어야 할 내용들
        self.empList = self.empDAO.find()
        self.tableView.reloadData()
        
        // 당겨서 새로고침 기능 종료
        self.refreshControl?.endRefreshing()
        
        // 노란 원이 로딩 이미지를 중심으로 커지는 애니메이션
        let distance = max(0.0, -(self.refreshControl?.frame.origin.y)!)
        
        UIView.animate(withDuration: 0.3) {
            self.bgCircle.frame.size.width = 80
            self.bgCircle.frame.size.height = 80
            self.bgCircle.center.x = (self.refreshControl?.frame.width)! / 2
            self.bgCircle.center.y = distance / 2
            self.bgCircle.layer.cornerRadius = (self.bgCircle?.frame.size.width)! / 2
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // 당긴 거리
        let distance = max(0.0, -(self.refreshControl?.frame.origin.y)!)
        
        // center.y 좌표를 당긴 거리만큼 수정
        self.loadingImg.center.y = distance / 2
        
        // 당긴 거리를 회전 각도로 반환하여 로딩 이미지에 설정한다.
        // 뷰의 변형에는 .transform 속성이 사용되고 CGAffineTransform 타입의 값을 이 속성에 적절히 설정함으로써 뷰의 형태를 찌그러트리거나 회전시키는 등 변형할 수 있다
        let ts = CGAffineTransform(rotationAngle: CGFloat(distance / 20))
        loadingImg.alpha = CGFloat(distance / 100)
        self.loadingImg.transform = ts
        
        // 배경 뷰의 중심 좌표 설정
        self.bgCircle.center.y = distance / 2
        //self.bgCircle.alpha = CGFloat(distance / 100)
        
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        // 노란 원을 다시 초기화
        self.bgCircle.frame.size.width = 0
        self.bgCircle.frame.size.height = 0
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
        cell?.textLabel?.text = rowData.empName + "(\(rowData.stateCd.desc()))"
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        
        cell?.detailTextLabel?.text = rowData.departTitle
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        
        return cell!
    }
    
    // 편집 모드에서 삭제버튼이 표시되도록 셀 편집 스타일 정의
    // 목록 편집 형식을 결정하는 메소스 (삽입/삭제)
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    // DB, 데이터 소스, 테이블 뷰에서 차례대로 관련 데이터를 삭제
    // 목록 편집 버튼을 클릭했을 때 호출되는 메소드
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // 삭제할 행의 empCd를 구한다
        let empCd = self.empList[indexPath.row].empCd
        
        // DB에서, 데이터 소스에서, 그리고 테이블 뷰에서 차례대로 삭제
        if empDAO.remove(empCd) {
            self.empList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
    // MARK: - navigation
   
    @IBAction func add(_ sender: Any) {
        
        let alert = UIAlertController(title: "사원 등록", message: "등록할 사원 정보를 입력해 주세요.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "사원명"}
        
        // contentViewController 영역에 부서 선택 피커 뷰 삽입
        let pickervc = DepartPickerVC()
        alert.setValue(pickervc, forKey: "contentViewController")
        
        // 등록창 버튼 처리
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default){ (_) in
            
            // 알림창의 입력 필드에서 값을 읽어온다
            var param = EmployeeVO()
            param.departCd = pickervc.selectedDepartCd
            param.empName = (alert.textFields?[0].text)!
            
            // 가입일은 오늘로 한다.
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            param.joinDate = df.string(from: Date())
            
            // 재직 상태는 '재직중'으로
            param.stateCd = EmpStateType.ING
            
            // DB 처리
            
            if self.empDAO.create(param) {
               
                // 결과가 성공이면 데이터를 다시 읽어들여 테이블 뷰를 갱신한다.
                self.empList = self.empDAO.find()
                self.tableView.reloadData()
                
                // 내비게이션 타이틀을 갱신다.
                if let navTitle = self.navigationItem.titleView as? UILabel {
                    
                    navTitle.text = "사원 목록 \n" + " 총 \(self.empList.count) 명"
                }
            }
        })
        self.present(alert, animated: false)
    }
    
    
    @IBAction func editing(_ sender: Any) {
        if self.isEditing == false { // 현재 편집 모드가 아닐 때
            
            self.setEditing(true, animated: true)
            (sender as? UIBarButtonItem)?.title = "Done"
            
        } else { // 현재 편집 모드일 때
            self.setEditing(false, animated: true)
            (sender as? UIBarButtonItem)?.title = "Edit"
        }
    }
}
