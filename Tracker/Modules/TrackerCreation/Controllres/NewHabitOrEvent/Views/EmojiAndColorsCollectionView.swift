import UIKit

final class EmojiAndColorsCollectionView: UICollectionView {
    // MARK: Properties
    
    weak var delegateController: EmojiAndColorsCollectionViewDelegate?
    
    let params: GeometricParams
    private let colors = R.ColorYP.Tracker.trackers
    private let borderColors = R.ColorYP.Tracker.trackersBorder
    private let emojies = R.Mocks.emojies
    
    private var emojiIsSelected = false
    private var colorIsSelected = false
    private var lastSelectedEmojiCell: EmojiOrColorCollectionViewCell? = nil
    private var lastSelectedColorCell: EmojiOrColorCollectionViewCell? = nil
    
    // MARK: Init
    
    init(params: GeometricParams) {
        self.params = params
        
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    
    private func configure() {
        backgroundColor = R.ColorYP.whiteDynamic
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isScrollEnabled = false
        allowsMultipleSelection = false
        
        register(EmojiOrColorCollectionViewCell.self,
                 forCellWithReuseIdentifier: EmojiOrColorCollectionViewCell.reuseIdentifier)
        register(SectionHeaderView.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: SectionHeaderView.identifier)
        
        dataSource = self
        delegate = self
    }
}

// MARK: UICollectionViewDataSource

extension EmojiAndColorsCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let isEmojies = section == 0
        return isEmojies ? emojies.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(
            withReuseIdentifier: EmojiOrColorCollectionViewCell.reuseIdentifier,
            for: indexPath
        )
        guard let cell = cell as? EmojiOrColorCollectionViewCell else {
            assertionFailure("color or emoji cell is nil")
            return UICollectionViewCell()
        }
        
        if indexPath.section == 0 {
            cell.configure(with: emojies[indexPath.row])
        } else {
            cell.configure(with: colors[indexPath.row])
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension EmojiAndColorsCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier,
            for: indexPath)
        guard let view = view as? SectionHeaderView else {
            print("SectionHeaderView is nil")
            return UICollectionReusableView()
        }
        
        let headerText = (indexPath.section == 0) ? "Emoji" : "Цвет"
        view.changeTitle(title: headerText, leadingAnchor: 28)
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: frame.width, height: 19)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: params.topInset, left: params.leftInset, bottom: params.bottomInset, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        guard let cell = cell as? EmojiOrColorCollectionViewCell else {
            print("EmojiOrColorCollectionViewCell is nil")
            return
        }
        
        if indexPath.section == 0 {
            if emojiIsSelected {
                lastSelectedEmojiCell?.backgroundColor = .clear
            }
            
            lastSelectedEmojiCell = cell
            emojiIsSelected = true
            cell.backgroundColor = R.ColorYP.backgroundDynamic
            
            delegateController?.changeSelectedEmoji(new: String(emojies[indexPath.row]))
        } else {
            if colorIsSelected {
                lastSelectedColorCell?.layer.borderWidth = 0
            }
            
            lastSelectedColorCell = cell
            colorIsSelected = true
            cell.layer.borderColor = borderColors[indexPath.row].cgColor
            cell.layer.borderWidth = 3
            
            delegateController?.changeSelectedColor(new: colors[indexPath.row])
        }
    }
}
