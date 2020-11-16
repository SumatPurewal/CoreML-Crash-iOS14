//
//  ViewController.swift
//  CrashCoreML
//
//  Created by Sumat Purewal on 11/16/20.
//

import UIKit
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var loadedImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func CreateCrash(_ sender: Any) {
        let image = UIImage(named: "SampleImage.jpg")!
        loadedImageView.image = image
        //Using this value in iOS 14 will work just fine on a iPhoneXs but will crash a iPhone 11.
        //(Will need to divide this by ~4.5 to get it to not crash on the iPhone 11 despite both phones having the same RAM.
        let max_pixels = 3483200
        let (content_img_width,content_img_height) = GetMaxContentImageSize(max_pixels: Float(max_pixels), width: Float(image.size.width), height: Float(image.size.height), divisor: 8)
        let content = image.pixelBuffer(width: content_img_width, height: content_img_height)
        
        let config = MLModelConfiguration.init()
        config.computeUnits = .cpuAndGPU
        var Encoder: encoder! = try! encoder(configuration: config)
        var Transformer: transformer! = try! transformer(configuration: config)
        let Decoder: decoder! = try! decoder(configuration: config)
        let encoder_features = try? Encoder.prediction(content_img: content!)
        if encoder_features == nil{
            print("Error running encoder")
            return
        }
        Encoder = nil //forcefully release memory allocated during encoder's execution
        let transformer_features = try? Transformer.prediction(encoder_out: encoder_features!.encoder_out)
        Transformer = nil //forcefully release memory allocated during transformer's execution
        let _ = try? Decoder.prediction(transformer_out: transformer_features!.transformer_out)
        ShowMessage(title: "Success", message: "Model ran without crashing. You will need to use iPhone11 or newer with iOS 14.2 or later to reproduce the crash. Other iOS14 versions may or may not create crash.", buttonName: "Ok")
    }
    
    func ShowMessage(title: String, message: String, buttonName: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonName, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func MakeDivisibleBy(divisor: Int, number: Int) -> Int{
        return Int(floor(Double(number) / Double(divisor)))*divisor
    }
    
    public func GetMaxContentImageSize(max_pixels: Float, width: Float, height: Float, divisor: Int) -> (Int,Int){
        let content_aspect_ratio = Float(width/height)
        var content_img_height = Int(sqrt(max_pixels/content_aspect_ratio))
        var content_img_width = Int(content_aspect_ratio*Float(content_img_height))
        
        let maxContentImageSize = 16384
        content_img_height = min(content_img_height, maxContentImageSize)
        content_img_width = min(content_img_width, maxContentImageSize)
        
        content_img_width = MakeDivisibleBy(divisor: divisor, number: content_img_width)
        content_img_height = MakeDivisibleBy(divisor: divisor, number: content_img_height)
        return (content_img_width, content_img_height)
    }
    
}

