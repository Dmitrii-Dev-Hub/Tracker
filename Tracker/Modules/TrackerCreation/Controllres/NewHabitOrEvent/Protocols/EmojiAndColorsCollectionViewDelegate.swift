import UIKit

protocol EmojiAndColorsCollectionViewDelegate: NSObject {
    func changeSelectedColor(new color: UIColor)
    func changeSelectedEmoji(new emoji: String?)
}

