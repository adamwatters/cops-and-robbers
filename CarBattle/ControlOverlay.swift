import SpriteKit

class ControlOverlay: SKNode {
    var rightPad = PadOverlay()

    init(frame: CGRect) {
        super.init()
        
        rightPad.position = CGPoint(x: CGFloat(frame.size.width - 20 - rightPad.size.width), y: CGFloat(40))
        addChild(rightPad)
    }

    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

