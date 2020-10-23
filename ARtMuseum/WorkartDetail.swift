//
//  WorkartDetail.swift
//  ARtMuseum
//
//  Created by Gabriel Logronio on 28/03/2020.
//  Copyright © 2020 Gabriel Logronio Projects. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class WorkartDetail
{
    var detailNode: SCNNode!
    var detailName: String!
    var detailNumID: Int!
    // var detailPosition: SCNVector3
    var detailMinAng, detailMaxAng: Float!
    //var detailButton: UIButton
    
    //var viewController: ViewController
    
    init(name: String, ID: Int, /*position: SCNVector3,*/ minAng: Float, maxAng: Float) //, vController: ViewController)
    {
        detailName = "\(name ?? "")"
        detailNumID = ID
        //detailPosition = position
        detailMinAng = minAng
        detailMaxAng = maxAng
        
        /*
        viewController = vController
        detailButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 35))
        detailButton.setTitle(detailName, for: .normal)
        detailButton.setTitleColor(UIColor.white, for: .normal)
        detailButton.backgroundColor = UIColor.gray
        detailButton.layer.cornerRadius = detailButton.frame.size.height / 4
        detailButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                
        detailButton.isHidden = true;
        */
    }
    /*
    @objc func buttonAction(sender: UIButton!)
    {
        viewController.DetailSelected(ID: detailNumID)
    }
    */
        
    func setNode(toSetNode: SCNNode)
    {
        detailNode = toSetNode
    }
    
    func rotateDirection(currentAngle: Float) -> Bool
    {
        if (getDistance(currentAngle: currentAngle) >= 0) { return true }
        else { return false }
        
    }
    
    func getDistance(currentAngle: Float) -> Float
    {
        var requestedAngle: Float
        
        if detailMinAng < detailMaxAng
            {
                requestedAngle = (detailMinAng + detailMaxAng) / 2
            }
        else
            {
                requestedAngle = (detailMinAng + detailMaxAng + 360) / 2
                if (requestedAngle >= 360) { requestedAngle -= 360 }
            }
        
        requestedAngle = requestedAngle - currentAngle
        
        if (requestedAngle > 180) { requestedAngle -= 360 }
        if (requestedAngle < -180) { requestedAngle += 360 }
        
        return requestedAngle
    }
    
    func toDisplay(currentAngle: Float) -> Bool {
        
        
        if detailMinAng < detailMaxAng
            {
                return (currentAngle >  detailMinAng) && (currentAngle < detailMaxAng)
            }
        else
            {
                return (currentAngle <  detailMaxAng) || (currentAngle > detailMinAng)
            }
    }
    
}
