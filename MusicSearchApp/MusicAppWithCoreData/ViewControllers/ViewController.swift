//
//  ViewController.swift
//  MusicAppWithCoreData
//
//  Created by 김건우 on 2023/08/17.
//

import UIKit

class ViewController: UIViewController {

    // 서치 컨트롤러 생성
    let searchController = UISearchController()
    
    @IBOutlet weak var musicTableView: UITableView!
    
    // 음악 데이터를 관리하는 매니저 선언 (싱글톤)
    let musicManager = MusicManager.shared
    
    // 뷰가 메모리에 로드된 후 호출되는 메서드 (한번만 호출)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaviBar()
        setupSearchBar()
        setupTableView()
        setupDatas()
    }

    // 뷰가 화면에 나타나기 전 호출되는 메서드 (여러번 호출 가능)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 테이블 뷰 리로드헤서 데이터 새로 불러오기
        musicTableView.reloadData()
    }
    
    func setupNaviBar() {
        self.title = "음악 검색"
    }
    
    func setupSearchBar() {
        // 네비게이션 스택에 서치바 할당
        navigationItem.searchController = searchController
        // 서치바의 동작을 구현하기 위해 델리게이트 패턴 할당
        searchController.searchBar.delegate = self
    }
    
    func setupTableView() {
        // 테이블 뷰의 동작을 구현하기 위해 델리게이트 패턴 할당
        musicTableView.delegate = self
        musicTableView.dataSource = self
        // Nib파일을 이용해 테이블 뷰에 셀 등록하기
        musicTableView.register(
            UINib(nibName: Cell.musicCellIdentifier, bundle: nil),
            forCellReuseIdentifier: Cell.musicCellIdentifier
        )
    }
    
    func setupDatas() {
        musicManager.setupDatasFromAPI {
            // API로부터 가져온 음악 데이터를
            // 메인 쓰레드에서 테이블 뷰 리로드해서 데이터 새로 불러오기
            DispatchQueue.main.async {
                self.musicTableView.reloadData()
            }
        }
    }
    
    func makeMessageAlert(completionHandler: @escaping (String?, Bool) -> Void) {
        // 입력한 메모를 저장하는 변수
        var savedMemo: String?
        
        let alert = UIAlertController(
            title: "음악 찜하기",
            message: "메모를 입력해주세요.",
            preferredStyle: .alert
        )
        // 얼럿창에 텍스트필드 추가하기
        alert.addTextField { textField in
            textField.placeholder = "30자 이내"
        }
        
        // 확인 버튼 동작 구현하기
        let ok = UIAlertAction(title: "확인", style: .default) { _ in
            savedMemo = alert.textFields?[0].text
            completionHandler(savedMemo, true)
        }
        // 취소 버튼 동작 구현하기
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(nil, false)
        }
        // 해당 동작은 얼럿에 추가하기
        alert.addAction([ok, cancel])
        self.present(alert, animated: true)
    }
    
    func makeRemoveAlert(completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: "음악 삭제",
            message: "음악을 찜 목록에서 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        // 확인 버튼 동작 구현하기
        let ok = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        }
        // 취소 버튼 동작 구현하기
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(false)
        }
        // 해당 동작을 얼럿에 추가하기
        alert.addAction([ok, cancel])
        self.present(alert, animated: true)
    }
}

extension ViewController: UITableViewDelegate {
    // 테이블 뷰의 셀을 최적의 높이로 설정하는 델리게이트 메서드
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicManager.getMusicArrayFromAPI().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 재사용 가능한 셀을 큐에서 가져오기
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.musicCellIdentifier, for: indexPath) as? MusicCell else {
            // 셀 가져오기에 실패하면 빈 셀 반환
            return UITableViewCell()
        }
        // 셀로 음악 데이터 전달하기
        let music = musicManager.getMusicArrayFromAPI()[indexPath.row]
        cell.music = music
        
        // 셀에서 저장 버튼을 클릭하면 수행할 동작 전달하기
        // 강한 순환 참조를 피하기 위해 약한 캡처하기
        cell.saveButtonTapped = { [weak self] (senderCell, isSaved) in
            // 뷰 컨트롤러가 메모리에 여전히 남아있는지 확인
            // 약한 참조를 하게 되면 자신의 뷰 컨트롤러 객체에 접근할 때마다
            // 옵셔널로 접근(self?.)해야 하는데, 이를 피하기 위해서 아래 코드를 작성
            guard let self = self else { return }
            
            // 저장이 되어 있는 경우
            if isSaved {
                // 정말 지울지 묻는 얼럿메시지 창 띄우기
                self.makeRemoveAlert { removeAction in
                    // 데이터를 지우는 경우
                    if removeAction {
                        self.musicManager.deleteMusicFromCoreData(with: music) {
                            // ❗️셀의 music 객체의 isSaved 프로퍼티를 수정해주어야 함
                            // 왜냐하면, setButtonStatus 메서드가 그 프로퍼리틑 사용하기 떄문
                            senderCell.music?.isSaved = false
                            // 저장 여부가 바뀌었으니, 버튼 스타일 재설정하기
                            senderCell.setButtonStatus()
                        }
                    }
                }
            // 저장이 되어 있지 않은 경우
            } else {
                // 저장 확인을 위한 얼럿메시지 창 띄우기
                self.makeMessageAlert { text, saved in
                    // 데이터를 저장하는 경우
                    if saved {
                        self.musicManager.saveMusic(with: music, message: text) {
                            senderCell.music?.isSaved = true
                            // 저장 여부가 바뀌었으니, 버튼 스타일 재설정하기
                            senderCell.setButtonStatus()
                        }
                    }
                }
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    // 키보드에서 검색(확인) 버튼을 클릭하면 호출되는 델리게이트 메서드
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
         // 서치바에 입력된 텍스트를 소문자로 옵셔널 바인딩
        guard let searchTerm = searchController.searchBar.text?.lowercased() else {
            return
        }
        // 검색어로 API를 호출해 음악 데이터 전달받기
        musicManager.fetchDatasFromAPI(with: searchTerm) {
            // 새로 불러온 음악 데이터로 테이블 리로드하기
            DispatchQueue.main.async {
                self.musicTableView.reloadData()
            }
        }
    }
    
    // 서치바에 입력을 할 때마다 호출되는 델리게이트 메서드
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = searchText.lowercased()
    }
}
