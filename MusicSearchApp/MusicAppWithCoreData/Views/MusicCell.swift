//
//  MusicCell.swift
//  MusicAppWithCoreData
//
//  Created by 김건우 on 2023/08/18.
//

import UIKit

class MusicCell: UITableViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    // 이 프로퍼티를 통해 Music 객체를 넘겨주게 되면
    // 프로퍼티 옵저버에 의해 셀의 각 항목에 데이터를 넣어줌
    var music: Music? {
        didSet {
            configureUIWithData()
        }
    }
    
    // (커스텀 델리게이트를 대신해) 클로저를 실행해 뷰 컨트롤러에서 필요한 작업을 수행함
    var saveButtonTapped: ((MusicCell, Bool) -> Void) = { (sender, pressed) in }
    
    // 셀이 재사용되기 전에 호출되는 메서드
    override func prepareForReuse() {
        self.prepareForReuse()
        // 스크롤을 해서 셀이 재사용될 때, 이미지가 바뀌는 현상을 없애기 위함
        self.mainImageView.image = nil
    }
    
    // 셀이 인터페이스 빌더에서 불러올 때 호출되는 메서드 (한번만 호출됨)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.mainImageView.contentMode = .scaleToFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureUIWithData() {
        // Music 객체를 옵셔널 바인딩
        guard let music = music else { return }
        loadImage(with: music.imageUrl)
        songNameLabel.text = music.songName
        artistNameLabel.text = music.artistName
        albumNameLabel.text = music.albumName
        releaseDateLabel.text = music.releaseDateString
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
        // Music 객체의 isSaved 프로퍼티 옵셔널 바인딩
        guard let isSaved = music?.isSaved else {
            return
        }
        // 찜한 음악인 경우
        if isSaved {
            saveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        // 찜한 음악이 아닌 경우
        } else {
            saveButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        // Music 객체의 isSaved 프로퍼티 옵셔널 바인딩
        guard let isSaved = music?.isSaved else {
            return
        }
        // 뷰 컨트롤러에서 전달 받은 클로저를 실행함
        saveButtonTapped(self, isSaved)
        // 다시 찜한 음악 여부를 검사
        setButtonStatus()
    }
}
