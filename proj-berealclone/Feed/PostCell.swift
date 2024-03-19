//
//  PostCell.swift
//  proj-berealclone
//
//  Created by Nafay on 2/1/24.
//

import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {

    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    private var imageDataRequest: DataRequest?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    
    func configure(with post: Post) {
        // TODO: Pt 1 - Configure Post Cell
        
        // Username
        if let user = post.user {
            usernameLabel.text = user.username
        }

        // Image
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url {
            
            // Use AlamofireImage helper to fetch remote image from URL
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    // Set image view image with fetched image
                    self?.postImageView.image = image
                    self?.postImageView.layer.cornerRadius = 10
                    self?.postImageView.layer.masksToBounds = true
                    
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                    break
                }
            }
        }

        // Caption
        captionLabel.text = post.caption

        // Date
        if let date = post.createdAt {
            dateLabel.text = DateFormatter.postFormatter.string(from: date)
        }

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // TODO: P1 - Cancel image download
        
        // Reset image view image.
        postImageView.image = nil

        // Cancel image request.
        imageDataRequest?.cancel()

    }

}


extension DateFormatter {
    static var postFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
}
