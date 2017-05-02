
class GameController: GameViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quick Match"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        gameview = GameView(frame: self.view.bounds)
        gameview!.type = .random
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
    
    override func viewDidAppear(_ animated: Bool) {
        gameview = GameView(frame: self.view.bounds)
        gameview!.type = .friend
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
    
    override func viewWillAppear(_ animated: Bool) {
        hambutton.badgeString = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        sideMenuObj.gameControls = false
        if gameview != nil {
            gameview!.removeFromSuperview()
            gameview = nil
        }
    }
    
}

public enum RPSChoice: Int, CustomStringConvertible {
    case rock = 0
    case paper = 1
    case scissors = 2
    case empty = 3
    
    public var description: String {
        switch self {
        case .rock:
            return "rock"
        case .paper:
            return "paper"
        case .scissors:
            return "scissors"
        case .empty:
            return "Empty"
        }
    }
}

public enum Results: Int, CustomStringConvertible {
    case win = 0
    case lose = 1
    case tie = 2
    
    public var description: String {
        switch self {
        case .win:
            return "Win"
        case .lose:
            return "Lose"
        case .tie:
            return "Tie"
        }
    }
}

public enum GameType: Int, CustomStringConvertible {
    case random = 0
    case nearby = 1
    case friend = 2
    
    public var description: String {
        switch self {
        case .random:
            return "Random"
        case .nearby:
            return "Nearby"
        case .friend:
            return "Friend"
        }
    }
}
