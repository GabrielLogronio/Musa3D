//
//  ViewController.swift
//  ARtMuseum
//
//  Created by Gabriel Logronio on 23/03/2020.
//  Copyright © 2020 Gabriel Logronio Projects. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, AVAudioPlayerDelegate {
                    
    // MARK: Initialize
    var workartDetails = [WorkartDetail?]()
    var selectedDetail = 0
    
    let detailsNames: [String] = ["Introduzione","Vista Frontale", "Vista Sinistra", "Vista Posteriore", "Chiusura"]
    let detailsAngles : [[Float]] = [[-180, 180], [-50, 50], [40, 140], [130, -130], [-180, 180]]
    let detailsHighlights: [Bool] = [false, true, true, true, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(HandleTap(rec:)))
        sceneView.addGestureRecognizer(tapRec)
        
        audioPlayer = AVAudioPlayer()
                
        let modelScene = SCNScene(named:
            "art.scnassets/Statuetta di Ed Sheeran.dae")
        
        if (detailsNames.count == detailsAngles.count)
            { InitializeDetails(scene: modelScene!) }
                
    }

    func InitializeDetails(scene: SCNScene)
    {
        for workartCount in 0...detailsNames.count - 1
        {
            let newDetail = WorkartDetail.init(name: detailsNames[workartCount], ID: workartCount, minAng: detailsAngles[workartCount][0], maxAng: detailsAngles[workartCount][1])
                        
            let workartNode = scene.rootNode.childNode(withName: detailsNames[workartCount].replacingOccurrences(of: " ", with: ""), recursively: false)!
            
            if (detailsHighlights[workartCount]){
                
                workartNode.setHighlighted()

                if let path = Bundle.main.path(forResource: "NodeTechnique", ofType: "plist") {
                    if let dict = NSDictionary(contentsOfFile: path)  {
                        let dict2 = dict as! [String : AnyObject]
                        let technique = SCNTechnique(dictionary:dict2)

                        // set the glow color to yellow
                        let color = SCNVector3(0.0, 1.0, 0.0)
                        technique?.setValue(NSValue(scnVector3: color), forKeyPath: "glowColorSymbol")

                        self.sceneView.technique = technique
                    }
                }
            }
            
            newDetail.setNode(toSetNode: workartNode)
                        
            workartDetails.append(newDetail)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "Group1", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        configuration.detectionObjects = referenceObjects
        sceneView.session.run(configuration)
                
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: Augmented Reality

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var ViewImage: UIImageView!
    
    var sceneNode : SCNNode!
    var sceneAnchor: ARObjectAnchor!
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        if let objectAnchor = anchor as? ARObjectAnchor {
                        
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
            
            DispatchQueue.main.async {

                // print("Anchor \(objectAnchor.name) found")
                self.WorkartOutlet.text = objectAnchor.name
            
                self.DetailSelected(ID: self.selectedDetail)
                self.ViewImage.isHidden = true
                //sceneView.scene.rootNode.addChildNode(node)
                node.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y, objectAnchor.referenceObject.center.z)
            
                self.sceneNode = node
                self.sceneAnchor = objectAnchor
                                        
                for currentDetail in self.workartDetails {
                
                let detailCloneNode = currentDetail?.detailNode
                node.addChildNode(detailCloneNode!)

                }
            }
        }
    }
    
    // MARK: MediaPlayer UI View
    var audioPlayer: AVAudioPlayer!
    var changedSide: Bool = false
    var audioPlayerOpen: Bool = true
    
    @IBOutlet weak var AudioPlayerView: UIView!
    @IBOutlet weak var TextPlayerView: UIView!
    
    @IBOutlet weak var WorkartOutlet: UILabel!
    @IBOutlet weak var TextDetailTitle: UILabel!
    @IBOutlet weak var AudioDetailTitle: UILabel!
    @IBOutlet weak var TextCounter: UILabel!
    @IBOutlet weak var AudioCounter: UILabel!
    @IBOutlet weak var TextSubtitleOutlet: UITextView!
    
    @IBOutlet weak var ShowButton: UIButton!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var PauseButton: UIButton!
    @IBOutlet weak var AudioBar: UISlider!
    @IBOutlet weak var SubtitlesOutlet: UILabel!
    
    @IBOutlet weak var RightArrow: UIImageView!
    @IBOutlet weak var LeftArrow: UIImageView!
    
    @IBAction func PlayDetail(_ sender: Any) {
        PlayPressed()
    }
    @IBAction func PauseDetail(_ sender: Any) {
        PausePressed()
    }
    
    @IBAction func MoveAudioDetail(_ sender: Any) {
        if(!changedSide) {
            audioPlayer.currentTime = TimeInterval(AudioBar.value)
            PlayPressed()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if(flag) {
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
            PausePressed()
            DetailSelected(ID: selectedDetail + 1)
        }
    }

    @objc func UpdateAudioBar()
    {
        DispatchQueue.main.async {
            self.AudioBar.value = Float(self.audioPlayer.currentTime)
        }
        
    }
    
    @IBAction func CloseView(_ sender: Any) {
        DispatchQueue.main.async {
            self.AudioPlayerView.isHidden = true
            self.TextPlayerView.isHidden = true
            self.ShowButton.isHidden = false
        }
    }
    
    @IBAction func OpenView(_ sender: Any) {
        DispatchQueue.main.async {
            if (self.audioPlayerOpen) {self.AudioPlayerView.isHidden = false}
            else {self.TextPlayerView.isHidden = false}
            self.ShowButton.isHidden = true
        }
    }

    func PausePressed()
    {
        audioPlayer.pause()
        DispatchQueue.main.async {
                self.PlayButton.isHidden = false
                self.PauseButton.isHidden = true
            }
    }
    
    func PlayPressed()
    {
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        DispatchQueue.main.async
            {
                self.PlayButton.isHidden = true
                self.PauseButton.isHidden = false
            }
    }
    
    @IBAction func PrevDetail(_ sender: Any) {
        PausePressed()
        if(selectedDetail > 0) { DetailSelected(ID: selectedDetail - 1) }
    }
    
    @IBAction func NextDetail(_ sender: Any) {
        PausePressed()
        if(selectedDetail <  workartDetails.count) { DetailSelected(ID: selectedDetail + 1)}
    }
    
    func DetailSelected(ID: Int)
    {
        //PausePressed()
        if(ID >= 0) && (ID <= workartDetails.count - 1) {
            selectedDetail = ID
            changedSide = true
            TextCounter.text = "\(ID + 1)/\(workartDetails.count)"
            AudioCounter.text = "\(ID + 1)/\(workartDetails.count)"
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: workartDetails[ID]!.detailName + " audio", ofType: "mp3")!))
                audioPlayer?.delegate = self
                                
                AudioBar.maximumValue = Float(audioPlayer.duration)
                                                
                _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.UpdateAudioBar), userInfo: nil, repeats: true)

            }
            catch {print("Error found finding the audio track")}
            
            do {
                let detailsText = try NSMutableAttributedString(url: Bundle.main.url(forResource: workartDetails[ID]!.detailName + " testo", withExtension: "rtf")!, options: [NSMutableAttributedString.DocumentReadingOptionKey.documentType: NSMutableAttributedString.DocumentType.rtf], documentAttributes: nil)
                TextSubtitleOutlet.attributedText = detailsText
            }
            catch {print("Error found finding the text")}

            DispatchQueue.main.async {
                self.TextDetailTitle.text = self.workartDetails[self.selectedDetail]?.detailName
                self.AudioDetailTitle.text = self.workartDetails[self.selectedDetail]?.detailName
                if (self.audioPlayerOpen) {self.AudioPlayerView.isHidden = false}
                else {self.TextPlayerView.isHidden = false}
                self.ShowButton.isHidden = true
                self.PlayButton.isEnabled = false
            }
        }
    }
    
    
    @IBAction func ToAudioView(_ sender: Any) {
        AudioPlayerView.isHidden = false
        TextPlayerView.isHidden = true
        
        audioPlayerOpen = true
    }
    
    @IBAction func ToTextView(_ sender: Any) {
        AudioPlayerView.isHidden = true
        TextPlayerView.isHidden = false
        
        audioPlayerOpen = false
    }
    
    @objc func HandleTap(rec: UITapGestureRecognizer){
        
        if rec.state == .ended {
              let location: CGPoint = rec.location(in: sceneView)
              let hits = self.sceneView.hitTest(location, options: nil)
              if !hits.isEmpty{
                  let tappedNode = hits.first?.node
                  for workartCount in 0...workartDetails.count - 1 {
                      if (workartDetails[workartCount]?.detailNode === tappedNode?.parent) { DetailSelected(ID: workartCount) }
                  }
              }
         }
    }
    
    // MARK: Update function

    var currentUserRotation: Float = 0.0

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        if sceneNode != nil{

            let userPosition = sceneView.pointOfView!.convertPosition(sceneView.pointOfView!.position, to: sceneNode)
            
            var rotation = rad2deg( atan(userPosition.x / userPosition.z))
            
            if ...0 ~= userPosition.z {
                
                if ...0 ~= userPosition.x
                    {
                        rotation = rotation - 180.0
                        currentUserRotation = rotation
                    }
                else
                    {   rotation = rotation + 180.0
                        currentUserRotation = rotation}
                    }
            else
                { currentUserRotation = rotation }
                                 
            
            for workartCount in 0...workartDetails.count - 1
            {
                DispatchQueue.main.async {

                    let currentDetail = self.workartDetails[workartCount]
                    
                    if (currentDetail?.toDisplay(currentAngle: self.currentUserRotation))! { currentDetail?.detailNode.isHidden = false }
                    else { currentDetail?.detailNode.isHidden = true }
                    
                    if (self.selectedDetail == 0 || self.selectedDetail == self.workartDetails.count - 1)
                    {
                        if (self.changedSide)
                        {
                            self.changedSide = false
                            self.PlayButton.isEnabled = true
                        }
                        self.RightArrow.isHidden = true
                        self.LeftArrow.isHidden = true

                    }
                    else
                    {
                        if (workartCount == self.selectedDetail)
                        {
                            if(currentDetail?.toDisplay(currentAngle: self.currentUserRotation))!
                            {
                                self.RightArrow.isHidden = true
                                self.LeftArrow.isHidden = true
                                if (self.changedSide)
                                {
                                    self.changedSide = false
                                    self.PlayButton.isEnabled = true
                                }
                            }
                            else
                            {
                                if ((currentDetail?.rotateDirection(currentAngle: self.currentUserRotation))!)
                                {
                                    self.RightArrow.isHidden = false
                                    self.LeftArrow.isHidden = true
                                }
                                else
                                {
                                    self.RightArrow.isHidden = true
                                    self.LeftArrow.isHidden = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Functions
    func rad2deg(_ number: Float) -> Float {
        return number * 180 / .pi
    }
    
    // End of
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}

extension SCNNode {
    func setHighlighted( _ highlighted : Bool = true, _ highlightedBitMask : Int = 2 ) {
        categoryBitMask = highlightedBitMask
        for child in self.childNodes {
            child.setHighlighted()
        }
    }
}
