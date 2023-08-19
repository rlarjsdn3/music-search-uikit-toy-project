//
//  SavedMusicCell.swift
//  MusicAppWithCoreData
//
//  Created by 김건우 on 2023/08/18.
//

import UIKit

class SavedMusicCell: UITableViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var saveDateLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // 이 프로퍼티를 통해 MusicSaved 객체를 넘겨주게 되면
    // 프로퍼티 옵저버에 의해 셀의 각 항목에 데이터를 넣어줌
    var musicSaved: MusicSaved? {
        didSet {
            configureUIwithData()
        }
    }
    
    // (커스텀 델리게이트를 대신해) 클로저를 실행해 뷰 컨트롤러에서 필요한 작업을 수행함
    var saveButtonTapped: ((SavedMusicCell) -> Void) = { (sender) in }
    
    // (커스텀 델리게이트를 대신해) 클로저를 실행해 뷰 컨트롤러에서 필요한 작업을 수행함
    var updateButtonTapped: ((SavedMusicCell, String?) -> Void) = { (sender, message) in }
    
    
    // 셀이 재사용되기 전에 호출되는 메서드
    override func prepareForReuse() {
        super.prepareForReuse()
        // 스크롤을 해서 셀이 재사용될 때, 이미지가 바뀌는 현상을 없애기 위함
        self.mainImageView.image = nil
    }
    
    // 셀이 인터페이스 빌더에서 불러올 때 호출되는 메서드 (한번만 호출됨)
    override func awakeFromNib() {
        super.awakeFromNib()
        // 뷰의 레이아웃을 바꾸는 작업은 주로 이 메서드에서 수행함
        setupUpdateButton()
    }
    
    func setupUpdateButton() {
        updateButton.layer.masksToBounds = true
        updateButton.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureUIwithData() {
        // MusicSaved 객체를 옵셔널 바인딩
        guard let musicSaved = musicSaved else { return }
        loadImage(with: musicSaved.imageUrl)
        songNameLabel.text = musicSaved.songName
        artistNameLabel.text = musicSaved.artistName
        albumNameLabel.text = musicSaved.albumName
        releaseDateLabel.text = musicSaved.releaseDate
        saveDateLabel.text = musicSaved.savedDateString ?? ""
        messageLabel.text = musicSaved.myMessage
        setButtonStatus()
    }
    
    func loadImage(with imageUrl: String?) {
        // url을 옵셔널 바인딩하고, URL구조체로 초기화
        guard let urlString = imageUrl, let url = URL(string: urlString) else {
            return
        }
        // 데이터를 비동기적으로 다운로드 받기
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            // UI를 업데이트하는 일은 메인 쓰레드에서 하기
            DispatchQueue.main.async {
                self.mainImageView.image = UIImage(data: data)
            }
        }
    }
    
    func setButtonStatus() {
        saveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        // 뷰 컨트롤러에서 전달 받은 클로저 실행
        saveButtonTapped(self)
    }
    
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        // 뷰 컨트롤러에서 전달 받은 클로저 실행
        updateButtonTapped(self, musicSaved?.myMessage)
    }
    
}
