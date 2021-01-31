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
    
    // 새로고침 컨트롤에 들어갈 이미지 뷰
    var loadingImg: UIImageView!
    
    // 임계점에 도달했을 떄 나타날 배경 뷰, 노란 원 형태
    var bgCircle: UIView!
    
    
    // MARK: - View cycle
    override func viewDidLoad() {
        self.departList = self.departDAO.find() // 기존 저장된 부서 정보를 가져온다.
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
        self.departList = self.departDAO.find()
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
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)  {
        
        // 삭제할 행의 departCd를 구한다.
        let departCd = self.departList[indexPath.row].departCd
        
        // DB에서, 데이터 소스에서, 그리고 테이블 뷰에서 차례대로 삭제한다.
        if departDAO.remove(departCd) {
            self.departList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 화면 이동 시 함께 전달할 부서 코드
        let departCd = self.departList[indexPath.row].departCd
        
        // 이동할 대상 뷰 컨트롤러의 인스턴스
        let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "DEPART_INFO")
        
        if let _infoVC = infoVC as? DepartmentInfoVC {
            
            // 부서 코드를 전달한 다음, 푸시 방식으로 화면 이동
            _infoVC.departCd = departCd
            self.navigationController?.pushViewController(_infoVC, animated: true)
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
