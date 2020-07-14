import UIKit

class TTDCameraView: UIView, UIGestureRecognizerDelegate {
    
    let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    let previewViewContainer = UIView()
    let buttonsContainer = UIView()
    let flipButton = UIButton()
    let shotButton = UIButton()
    let flashButton = UIButton()
    let timeElapsedLabel = UILabel()
    let progressBar = UIProgressView()

    convenience init(overlayView: UIView? = nil) {
        self.init(frame: .zero)
        
        if let overlayView = overlayView {
            [previewViewContainer, overlayView, progressBar, timeElapsedLabel, buttonsContainer, flashButton, flipButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false
                addSubview($0)
            }
            shotButton.translatesAutoresizingMaskIntoConstraints = false
            buttonsContainer.addSubview(shotButton)
        } else {
            [previewViewContainer, progressBar, timeElapsedLabel, buttonsContainer, flashButton, flipButton ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false
                addSubview($0)
            }
            shotButton.translatesAutoresizingMaskIntoConstraints = false
            buttonsContainer.addSubview(shotButton)
        }
        
        // Layout
        let isIphone4 = UIScreen.main.bounds.height == 480
        let sideMargin: CGFloat = isIphone4 ? 20 : 0
        if TTDConfig.onlySquareImagesFromCamera {
            NSLayoutConstraint.activate([
                previewViewContainer.topAnchor.constraint(equalTo: topAnchor),
                previewViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sideMargin),
                previewViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -sideMargin),

                progressBar.topAnchor.constraint(equalTo: previewViewContainer.bottomAnchor, constant: -2),
                progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
                progressBar.trailingAnchor.constraint(equalTo: trailingAnchor),

                buttonsContainer.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
                buttonsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                buttonsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                buttonsContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

                previewViewContainer.heightAnchor.constraint(equalTo: previewViewContainer.widthAnchor, multiplier: 1)
            ])
        }
        else {
            NSLayoutConstraint.activate([
                previewViewContainer.topAnchor.constraint(equalTo: topAnchor),
                previewViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sideMargin),
                previewViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -sideMargin),
                previewViewContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

                progressBar.topAnchor.constraint(equalTo: previewViewContainer.bottomAnchor, constant: -2),
                progressBar.leadingAnchor.constraint(equalTo: leadingAnchor),
                progressBar.trailingAnchor.constraint(equalTo: trailingAnchor),
                progressBar.bottomAnchor.constraint(equalTo: bottomAnchor),

                buttonsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                buttonsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                buttonsContainer.heightAnchor.constraint(equalToConstant: 100),
                buttonsContainer.bottomAnchor.constraint(equalTo: previewViewContainer.bottomAnchor, constant: -50) //or 50
            ])
        }

        if let overlay = overlayView {
            NSLayoutConstraint.activate([
                overlay.centerYAnchor.constraint(equalTo: previewViewContainer.centerYAnchor),
                overlay.centerXAnchor.constraint(equalTo: previewViewContainer.centerXAnchor),
                overlay.widthAnchor.constraint(equalTo: previewViewContainer.widthAnchor),
                overlay.heightAnchor.constraint(equalTo: previewViewContainer.heightAnchor)
            ])
        }

        NSLayoutConstraint.activate([
            flashButton.centerXAnchor.constraint(equalTo: leadingAnchor, constant: 30 + sideMargin),
            flashButton.centerYAnchor.constraint(equalTo: shotButton.centerYAnchor),
            flashButton.bottomAnchor.constraint(equalTo: previewViewContainer.bottomAnchor, constant: -50),//OR +

            flipButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(15 + sideMargin)),
            flipButton.bottomAnchor.constraint(equalTo: previewViewContainer.bottomAnchor, constant: -50),

            timeElapsedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(15 + sideMargin)),
            timeElapsedLabel.topAnchor.constraint(equalTo: previewViewContainer.bottomAnchor, constant: -50),

            shotButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            shotButton.centerYAnchor.constraint(equalTo: flipButton.centerYAnchor),
            shotButton.heightAnchor.constraint(equalToConstant: 64),
            shotButton.widthAnchor.constraint(equalToConstant: 64)
        ])

        // Style
        backgroundColor = TTDConfig.colors.photoVideoScreenBackgroundColor
        previewViewContainer.backgroundColor = UIColor.ypLabel

        timeElapsedLabel.textColor = .white
        timeElapsedLabel.text = "00:00"
        timeElapsedLabel.isHidden = true
        timeElapsedLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .medium)

        progressBar.trackTintColor = .clear
        progressBar.tintColor = .ypSystemRed

        flashButton.setImage(TTDConfig.icons.flashOffIcon, for: .normal)
        flipButton.setImage(TTDConfig.icons.loopIcon, for: .normal)
        shotButton.setImage(TTDConfig.icons.capturePhotoImage, for: .normal)
    }
}
