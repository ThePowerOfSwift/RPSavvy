
class GameController: GameViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quick Match"
    }
    
    override func viewDidAppear(animated: Bool) {
        gameview = GameView(frame: self.view.bounds)
        gameview!.type = .Random
        self.view.addSubview(gameview!)
        gameview!.presentReady()
        sideMenuObj.gameControls = true
    }
}

class FriendGame: GameViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RPSavvy"
    }
    
    override func viewDidAppear(animated: Bool) {
        gameview = GameView(frame: self.view.bounds)
        gameview!.type = .Friend
        self.view.addSubview(gameview!)
        gameview!.presentReady()
        sideMenuObj.gameControls = true
    }
    
}


class GameViewController: UIViewController {
    
    var gameview: GameView?
    
    override func awakeFromNib() {
        hideBackButton()
        addHamMenu()
        view.GradLayer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        sideMenuObj.gameControls = false
        if gameview != nil {
            gameview!.removeFromSuperview()
            gameview = nil
        }
    }
    
}

public enum RPSChoice: Int, CustomStringConvertible {
    case Rock = 0
    case Paper = 1
    case Scissors = 2
    case Empty = 3
    
    public var description: String {
        switch self {
        case .Rock:
            return "rock"
        case .Paper:
            return "paper"
        case .Scissors:
            return "scissors"
        case .Empty:
            return "Empty"
        }
    }
}

public enum Results: Int, CustomStringConvertible {
    case Win = 0
    case Lose = 1
    case Tie = 2
    
    public var description: String {
        switch self {
        case .Win:
            return "Win"
        case .Lose:
            return "Lose"
        case .Tie:
            return "Tie"
        }
    }
}

public enum GameType: Int, CustomStringConvertible {
    case Random = 0
    case Nearby = 1
    case Friend = 2
    
    public var description: String {
        switch self {
        case .Random:
            return "Random"
        case .Nearby:
            return "Nearby"
        case .Friend:
            return "Friend"
        }
    }
}
