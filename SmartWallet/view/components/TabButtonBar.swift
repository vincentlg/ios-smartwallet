//
//  TabButtonBar.swift
//  SmartWallet
//
//  Created by Frederic DE MATOS on 24/03/2020.
//  Copyright © 2020 Frederic DE MATOS. All rights reserved.
//


import UIKit
import Tabman

/// `TMBarButton` that consists of a single label - that's it!
///
/// Probably the most commonly seen example of a bar button.
class TabButtonBar: TMBarButton {
    
    // MARK: Defaults
    
    private struct Defaults {
        static let contentInset = UIEdgeInsets(top: 6.0, left: 0.0, bottom: 6.0, right: 0.0)
    }
    
    // MARK: Types
    
    /// Vertical alignment of the label within the bar button.
    ///
    /// - `.center`: Center the label vertically in the button.
    /// - `.top`: Align the label with the top of the button.
    /// - `.bottom`: Align the label with the bottom of the button.
    public enum VerticalAlignment {
        case center
        case top
        case bottom
    }
    
    // MARK: Properties
    
    open override var intrinsicContentSize: CGSize {
        if let fontIntrinsicContentSize = self.fontIntrinsicContentSize {
            return fontIntrinsicContentSize
        }
        return super.intrinsicContentSize
    }
    private var fontIntrinsicContentSize: CGSize?
    
    private let button = WalletButton()
    
    open override var contentInset: UIEdgeInsets {
        set {
            super.contentInset = newValue
        } get {
            return super.contentInset
        }
    }
    
    /// Text to display in the button.
    open var text: String? {
        set {
            button.setTitle(newValue, for: .normal)
        } get {
            return button.titleLabel?.text
        }
    }

    
    open override func update(for selectionState: TMBarButton.SelectionState) {
        super.update(for: selectionState)
        
        if selectionState == .selected {
            self.button.select()
        } else {
            self.button.deselect()
        }
    }
    
    /// How to vertically align the label within the button. Defaults to `.center`.
    ///
    /// - Note: This will only apply when the button is larger than
    /// the required intrinsic height. If the bar sizes itself intrinsically,
    /// setting this paramter will have no effect.
    open var verticalAlignment: VerticalAlignment = .center {
        didSet {
            updateAlignmentConstraints()
        }
    }
    private var labelTopConstraint: NSLayoutConstraint?
    private var labelCenterConstraint: NSLayoutConstraint?
    private var labelBottomConstraint: NSLayoutConstraint?
    
    // MARK: Lifecycle
    
    open override func layout(in view: UIView) {
        super.layout(in: view)
        
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        let labelCenterConstraint = button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let constraints = [
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            view.bottomAnchor.constraint(greaterThanOrEqualTo: button.bottomAnchor),
            labelCenterConstraint
        ]
        
        self.labelCenterConstraint = labelCenterConstraint
        self.labelTopConstraint = button.topAnchor.constraint(equalTo: view.topAnchor)
        self.labelBottomConstraint = view.bottomAnchor.constraint(equalTo: button.bottomAnchor)
        
        NSLayoutConstraint.activate(constraints)
        adjustsAlphaOnSelection = false
      
        tintColor = .white
        contentInset = Defaults.contentInset
        
    }
    
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        UIView.performWithoutAnimation {
            update(for: selectionState)
        }
    }
    
    open override func populate(for item: TMBarItemable) {
        super.populate(for: item)
        
        button.setTitle(item.title, for: .normal)
    }
    
    
    // MARK: Layout
    
    
    private func updateAlignmentConstraints() {
        switch verticalAlignment {
        case .center:
            labelCenterConstraint?.isActive = true
            labelTopConstraint?.isActive = false
            labelBottomConstraint?.isActive = false
        case .top:
            labelCenterConstraint?.isActive = false
            labelTopConstraint?.isActive = true
            labelBottomConstraint?.isActive = false
        case .bottom:
            labelCenterConstraint?.isActive = false
            labelTopConstraint?.isActive = false
            labelBottomConstraint?.isActive = true
        }
    }
}


private extension TabButtonBar {
    
    func makeTextLayer(for label: UILabel) -> CATextLayer {
        let layer = CATextLayer()
        layer.frame = label.convert(label.frame, to: self)
        layer.string = label.text
        layer.font = label.font
        layer.fontSize = label.font.pointSize
        return layer
    }
}

