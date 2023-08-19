//
//  SavedListViewController.swift
//  MusicAppWithCoreData
//
//  Created by 김건우 on 2023/08/18.
//

import UIKit

class SavedListViewController: UIViewController {

    @IBOutlet weak var musicTableView: UITableView!
    
    // 음악 데이터를 관리하는 매니저 선언 (싱글톤)
    let musicManager = MusicManager.shared
    
    // 뷰가 메모리에 로드된 후 호출되는 메서드 (한번만 호출)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaviBar()
        setupTableView()
    }
    
    // 뷰가 화면에 나타나기 전 호출되는 메서드 (여러번 호출 가능)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        musicTableView.reloadData()
    }
    
    func setupNaviBar() {
        self.navigationItem.title = "찜한 목록"
    }
    
    func setupTableView() {
        // 테이블 뷰의 동작을 구현하기 위해 델리게이트 패턴 할당
        musicTableView.delegate = self
        musicTableView.dataSource = self
        // Nib파일을 이용해 테이블 뷰에 셀 등록하기
        musicTableView.register(
            UINib(nibName: Cell.savedMusicCellIdentifier, bundle: nil),
            forCellReuseIdentifier: Cell.savedMusicCellIdentifier
        )
    }
    
    func makeMessageAlert(message: String?, completionHandler: @escaping (String?, Bool) -> Void) {
        // 입력한 메모를 저장하는 변수
        var savedMemo: String?
        
        let alert = UIAlertController(
            title: "음악 수정하기",
            message: "메모를 입력해주세요.",
            preferredStyle: .alert
        )
        // 얼럿창에 텍스트필드 추가하기
        alert.addTextField { textField in
            textField.text = message
        }
        
        // 확인 버튼 동작 구현
        let ok = UIAlertAction(title: "확인", style: .default) { _ in
            savedMemo = alert.textFields?[0].text
            completionHandler(savedMemo, true)
        }
        // 취소 버튼 동작 구현
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(nil, false)
        }
        
        // 해당 동작을 얼럿에 추가하기
        alert.addAction([ok, cancel])
        self.present(alert, animated: true)
    }

    func makeRemoveAlert(completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: "음악 삭제",
            message: "음악을 찜 목록에서 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        // 확인 버튼 동작 구현
        let ok = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        }
        // 취소 버튼 동작 구현
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(false)
        }
        // 해당 동작을 얼럿에 추가하기
        alert.addAction([ok, cancel])
        self.present(alert, animated: true)
    }
}

extension SavedListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
}

extension SavedListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicManager.getMusicArrayFromCoreData().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 재사용 가능한 셀을 큐에서 가져오기
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.savedMusicCellIdentifier, for: indexPath) as? SavedMusicCell else {
            // 셀 가져오기 실패하면 빈 셀 반환
            return UITableViewCell()
        }
        
        // 셀로 음악 데이터 전달하기
        let musicSaved = musicManager.getMusicArrayFromCoreData()[indexPath.row]
        cell.musicSaved = musicSaved
        
        // 셀에서 하트 버튼을 클릭하면 수행할 동작 전달하기
        cell.saveButtonTapped = { [weak self] (senderCell) in
            // 약한 켑처를 하게 되면 자신의 뷰 컨트롤러 객체에 접근할 때마다
            // 옵셔널로 접근(self?.)해야 하는데, 이를 피하기 위해서 아래 코드를 작성
            guard let self = self else { return }
            // 정말 지울지 묻는 얼럿메시지 창 띄우기
            self.makeRemoveAlert { okAction in
                // 확인 버튼을 클릭한다면
                if okAction {
                    self.musicManager.deleteMusicFromCoreData(with: musicSaved) {
                        self.musicTableView.reloadData()
                    }
                }
            }
        }
        
        // 셀에서 수정 버튼을 클릭하면 수행할 동작 전달하기
        cell.updateButtonTapped = { [weak self] (senderCell, message) in
            // 약한 켑처를 하게 되면 자신의 뷰 컨트롤러 객체에 접근할 때마다
            // 옵셔널로 접근(self?.)해야 하는데, 이를 피하기 위해서 아래 코드를 작성
            guard let self = self else { return }
            // 수정하기 위한 얼럿메시지 창 띄우기
            self.makeMessageAlert(message: message) { updatedMessage, okAction in
                // 확인 버튼을 클릭한다면
                if okAction {
                    // 새로운 메시지로 바꾸고
                    senderCell.musicSaved?.myMessage = updatedMessage
                    // 메시지를 수정한 음악 데이터를 코어데이터에 업데이트하기
                    guard let musicSaved = senderCell.musicSaved else { return }
                    self.musicManager.updateMusicToCoreData(with: musicSaved) {
                        senderCell.configureUIwithData()
                    }
                }
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
}
