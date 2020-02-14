//
//  ReVIEW.swift
//  
//
//  Created by mcs on 2/9/20.
//

import MapKit
import YelpAPI
import UIKit

extension UIImageView {
    func downloadImageFrom(link:String, contentMode: UIView.ContentMode) {
        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}


public class ReVIEW: UIViewController {
    
    @IBOutlet public weak var resultsView: UIView!
    @IBOutlet weak var resultsImage: UIImageView!
    @IBOutlet weak var resultsName: UILabel!
    @IBOutlet weak var resultsRating: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    @IBOutlet weak var starImageTwo: UIImageView!
    @IBOutlet weak var starImageThree: UIImageView!
    @IBOutlet weak var starImageFour: UIImageView!
    @IBOutlet weak var starImageFive: UIImageView!
    @IBOutlet weak var reviewLabelOne: UILabel!
    @IBOutlet weak var reviewLabelTwo: UILabel!
    @IBOutlet weak var reviewLabelThree: UILabel!
    @IBOutlet weak var reviewRatingOne: UILabel!
    @IBOutlet weak var reviewRatingTwo: UILabel!
    @IBOutlet weak var reviewRatingThree: UILabel!
    
    var reviewResults = ReviewResults(reviews: [])
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        resultsView.backgroundColor = .systemPink
        fetchYelpReviews { (data, err) in
            DispatchQueue.main.async {
                self.reviewResults = data ?? ReviewResults(reviews: [])
                if self.reviewResults.reviews.count > 0 {
                    self.reviewLabelOne.text = self.reviewResults.reviews[0].text
                    self.reviewRatingOne.text = "Rating: \(self.reviewResults.reviews[0].rating?.description ?? "0")/5"
                }
                if self.reviewResults.reviews.count > 1 {
                    self.reviewLabelTwo.text = self.reviewResults.reviews[1].text
                    self.reviewRatingTwo.text = "Rating: \( self.reviewResults.reviews[1].rating?.description ?? "0")/5"
                }
                if self.reviewResults.reviews.count > 2 {
                    self.reviewLabelThree.text = self.reviewResults.reviews[2].text
                    self.reviewRatingThree.text = "Rating: \( self.reviewResults.reviews[2].rating?.description ?? "0")/5"
                }

            }
        }
        reviewLabelOne.numberOfLines = 4
        reviewLabelTwo.numberOfLines = 4
        reviewLabelThree.numberOfLines = 4
        resultsRating.text = ("\(State.tempBusiness?.rating.description ?? "")/5.0")
        resultsName.text = State.tempBusiness?.name
        resultsImage.downloadImageFrom(link: State.tempBusiness?.imageURL?.description ?? "", contentMode: UIView.ContentMode(rawValue: resultsView.contentMode.hashValue) ?? UIView.ContentMode.center)
        if State.tempBusiness?.rating ?? 0.0 == 0.5 {
            starImage.image = UIImage.init(systemName: "star.lefthalf.fill")
        }else if State.tempBusiness?.rating ?? 0.0 > 0.5{
            starImage.image = UIImage.init(systemName: "star.fill")
        }
        if State.tempBusiness?.rating ?? 0.0 == 1.5 {
            starImageTwo.image = UIImage.init(systemName: "star.lefthalf.fill")
        }else if State.tempBusiness?.rating ?? 0.0 > 1.5{
            starImageTwo.image = UIImage.init(systemName: "star.fill")
        }
        if State.tempBusiness?.rating ?? 0.0 == 2.5 {
            starImageThree.image = UIImage.init(systemName: "star.lefthalf.fill")
        }else if State.tempBusiness?.rating ?? 0.0 > 2.5{
            starImageThree.image = UIImage.init(systemName: "star.fill")
        }
        if State.tempBusiness?.rating ?? 0.0 == 3.5 {
            starImageFour.image = UIImage.init(systemName: "star.lefthalf.fill")
        }else if State.tempBusiness?.rating ?? 0.0 > 3.5{
            starImageFour.image = UIImage.init(systemName: "star.fill")
        }
        if State.tempBusiness?.rating ?? 0.0 == 4.5 {
            starImageFive.image = UIImage.init(systemName: "star.lefthalf.fill")
        }else if State.tempBusiness?.rating ?? 0.0 > 4.5{
            starImageFive.image = UIImage.init(systemName: "star.fill")
        }
    }
    
    fileprivate func fetchYelpReviews(completion: @escaping (ReviewResults?, Error?) -> ()) {
        let idString = State.tempBusiness?.identifier ?? ""
        guard let url = URL(string: "https://api.yelp.com/v3/businesses/\(idString)/reviews") else { return }
        var request = URLRequest(url: url)
    request.setValue("Bearer \(YelpAPIKey)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "GET"

    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let err = error {
            print(err.localizedDescription)
        }
        do {
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(ReviewResults.self, from: data ?? Data())
            completion(jsonData, nil)
        } catch {
            print("caught")
        }
        }.resume()
    }
}

struct ReviewResults: Decodable {
    var reviews: [Reviews]
}

    struct Reviews: Decodable {
        var rating: Int?
        var text: String?
}
