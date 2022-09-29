//
//  AudioRecorderViewController.swift
//  Spark
//
//  Created by Gowthaman P on 19/07/21.
//

import UIKit
import AVKit
import SoundWave

/**
 This class is  used to record the audio and send to attachement page
 */
class AudioRecorderViewController: UIViewController,backFromPhotomodelDelegate, backtoMultipostDelegate {
    /// back function from delegate to call from attachment page
    func back() {
        self.dismiss(animated: true) {
            self.backMultiPostdelegate?.back()
        }
    }
    /// back function from delegate to call from attachment page to send all the datas
    func backFromAttachement() {
        self.dismiss(animated: true) {
            self.delegate?.backFromAttachement()
        }
    }
    
    
    ///Audio recording enum is refers to
    /// - ready
    /// - recording
    /// - recorded
    /// - playing
    /// - paused
     
    
    enum AudioRecodingState {
        case ready
        case recording
        case recorded
        case playing
        case paused

        var buttonImage: UIImage {
            switch self {
            case .ready, .recording:
                return #imageLiteral(resourceName: "Record-Button")
            case .recorded, .paused:
                return #imageLiteral(resourceName: "Play-Button")
            case .playing:
                return #imageLiteral(resourceName: "Pause-Button")
            }
        }

        
        
        
        
        /// It will show the audio recording visulization
        var audioVisualizationMode: AudioVisualizationView.AudioVisualizationMode {
            switch self {
            case .ready, .recording:
                return .write
            case .paused, .playing, .recorded:
                return .read
            }
        }
    }

    @IBOutlet private var recordButton: UIButton!
    @IBOutlet private var clearButton: UIButton!
    @IBOutlet private var audioVisualizationView: AudioVisualizationView!

    @IBOutlet private var optionsView: UIView!
    @IBOutlet private var optionsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var audioVisualizationTimeIntervalLabel: UILabel!
    @IBOutlet private var meteringLevelBarWidthLabel: UILabel!
    @IBOutlet private var meteringLevelSpaceInterBarLabel: UILabel!

    var typedQuestionDict = [String:Any]()
    var nftParam = Int()
    var FromLoopMonetize = 0
    
    var multiplePost = 0
    
    var repostId = ""
    
    var currenyCode = ""
    var currencySymbol = ""
    
    var monetizeSpark = Int()
    
    var backMultiPostdelegate : backtoMultipostDelegate?
    
    private let viewModel = ViewModel()
    var delegate : backFromPhotomodelDelegate?

    /// Show the current state of audio recording
    private var currentState: AudioRecodingState = .ready {
        didSet {
            self.recordButton.setImage(self.currentState.buttonImage, for: .normal)
            self.audioVisualizationView.audioVisualizationMode = self.currentState.audioVisualizationMode
            self.clearButton.isHidden = self.currentState == .ready || self.currentState == .playing || self.currentState == .recording
        }
    }

    private var chronometer: Chronometer?

    
    
    /**
     Called after the controller's view is loaded into memory.
     - This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView() method. You usually override this method to perform additional initialization on views that were loaded from nib files.
     */
    /// - It is asked the audio for recording permission
    /// - Add the audio visulization here
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint(AudioRecorderManager.shared.currentRecordPath ?? "")
        

        self.viewModel.askAudioRecordingPermission()

        self.viewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
            guard let self = self, self.audioVisualizationView.audioVisualizationMode == .write else {
                return
            }
            self.audioVisualizationView.add(meteringLevel: meteringLevel)
        }

        self.viewModel.audioDidFinish = { [weak self] in
            self?.currentState = .recorded
            self?.audioVisualizationView.stop()
        }
        
        
    }

    // MARK: - Actions

    /// Record button did touch down it will start  to record the audio
    @IBAction private func recordButtonDidTouchDown(_ sender: AnyObject) {
        if self.currentState == .ready {
            self.viewModel.startRecording { [weak self] soundRecord, error in
                if let error = error {
                    self?.showAlert(with: error)
                    return
                }

                self?.currentState = .recording

                self?.chronometer = Chronometer()
                self?.chronometer?.start()
            }
        }
    }

    /// If the record button touch up inside accoring to the current state it will change to stop, paused or playing
    @IBAction private func recordButtonDidTouchUpInside(_ sender: AnyObject) {
        switch self.currentState {
        case .recording:
            self.chronometer?.stop()
            self.chronometer = nil

            self.viewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
            self.audioVisualizationView.audioVisualizationMode = .read

            do {
                try self.viewModel.stopRecording()
                self.currentState = .recorded
            } catch {
                self.currentState = .ready
                self.showAlert(with: error)
            }
        case .recorded, .paused:
            do {
                let duration = try self.viewModel.startPlaying()
                self.currentState = .playing
                self.audioVisualizationView.meteringLevels = self.viewModel.currentAudioRecord!.meteringLevels
                self.audioVisualizationView.play(for: duration)
            } catch {
                self.showAlert(with: error)
            }
        case .playing:
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        default:
            break
        }
    }

    /// Clear button is tapped to reset the recording clips
    @IBAction private func clearButtonTapped(_ sender: AnyObject) {
        do {
            try self.viewModel.resetRecording()
            self.audioVisualizationView.reset()
            self.currentState = .ready
        } catch {
            self.showAlert(with: error)
        }
    }

    /// Switch state if it is on it will change the color
    @IBAction private func switchValueChanged(_ sender: AnyObject) {
        let theSwitch = sender as! UISwitch
        if theSwitch.isOn {
            self.view.backgroundColor = .mainBackgroundPurple
            self.audioVisualizationView.gradientStartColor = .audioVisualizationPurpleGradientStart
            self.audioVisualizationView.gradientEndColor = .audioVisualizationPurpleGradientEnd
        } else {
            self.view.backgroundColor = .mainBackgroundGray
            self.audioVisualizationView.gradientStartColor = .audioVisualizationGrayGradientStart
            self.audioVisualizationView.gradientEndColor = .audioVisualizationGrayGradientEnd
        }
    }

    /// Audio vizualiation will change according to the recording
    @IBAction private func audioVisualizationTimeIntervalSliderValueDidChange(_ sender: AnyObject) {
        let audioVisualizationTimeIntervalSlider = sender as! UISlider
        self.viewModel.audioVisualizationTimeInterval = TimeInterval(audioVisualizationTimeIntervalSlider.value)
        self.audioVisualizationTimeIntervalLabel.text = String(format: "%.2f", self.viewModel.audioVisualizationTimeInterval)
    }

    /// The bar width value has been changed when its recording
    @IBAction private func meteringLevelBarWidthSliderValueChanged(_ sender: AnyObject) {
        let meteringLevelBarWidthSlider = sender as! UISlider
        self.audioVisualizationView.meteringLevelBarWidth = CGFloat(meteringLevelBarWidthSlider.value)
        self.meteringLevelBarWidthLabel.text = String(format: "%.2f", self.audioVisualizationView.meteringLevelBarWidth)
    }

    /// When the value level changed in the recording it will show the vizualization
    @IBAction private func meteringLevelSpaceInterBarSliderValueChanged(_ sender: AnyObject) {
        let meteringLevelSpaceInterBarSlider = sender as! UISlider
        self.audioVisualizationView.meteringLevelBarInterItem = CGFloat(meteringLevelSpaceInterBarSlider.value)
        self.meteringLevelSpaceInterBarLabel.text = String(format: "%.2f", self.audioVisualizationView.meteringLevelBarWidth)
    }

    ///When options button tapped it will show the options
    @IBAction private func optionsButtonTapped(_ sender: AnyObject) {
        let shouldExpand = self.optionsViewHeightConstraint.constant == 0
        self.optionsViewHeightConstraint.constant = shouldExpand ? 165.0 : 0.0
        UIView.animate(withDuration: 0.2) {
            self.optionsView.subviews.forEach { $0.alpha = shouldExpand ? 1.0 : 0.0 }
            self.view.layoutIfNeeded()
        }
    }
    
    
    /// When save button tapped  it will stop the recording and get the filepath and pass to attachment page.
    @IBAction private func SaveButtonTapped(_ sender: AnyObject) {
        debugPrint(AudioRecorderManager.shared.currentRecordPath ?? "")
        
        if currentState == .playing {
            self.chronometer?.stop()
        }
        
        do {
            try self.viewModel.pausePlaying()
            self.currentState = .paused
            self.audioVisualizationView.pause()
        } catch {
            self.showAlert(with: error)
        }

        let fileArray = "\(AudioRecorderManager.shared.currentRecordPath ?? URL(fileURLWithPath: ""))".components(separatedBy: "/")
        let finalFileName = fileArray.last
        
        let finalName = finalFileName?.components(separatedBy: ".")
        
        let fileURL = URL.init(string: "file://\(AudioRecorderManager.shared.currentRecordPath ?? URL(fileURLWithPath: ""))") ?? URL(fileURLWithPath: "")
        do {
            let data = try Data(contentsOf: fileURL)
            debugPrint(data)
            let storyBoard : UIStoryboard = UIStoryboard(name:"Home", bundle: nil)
            let editImageVC = storyBoard.instantiateViewController(identifier: "AttachmentViewController") as! AttachmentViewController
            editImageVC.currencySymbol = currencySymbol
            editImageVC.currenyCode = currenyCode
            editImageVC.nftParam = nftParam
            editImageVC.selectedDocData = data
            typedQuestionDict["mediaType"] = MediaType.RecordedAudio.rawValue
            editImageVC.typedQuestionDict = typedQuestionDict
            editImageVC.selectedDocTypeArray = finalName ?? []
            editImageVC.isFromPhotoModel = 1
            editImageVC.delegate = self
            editImageVC.FromLoopMonetize = self.FromLoopMonetize //isMonetise
            editImageVC.multiplePost = self.multiplePost
            editImageVC.repostId = self.repostId
            editImageVC.backtoMultipostDelegate = self
            editImageVC.delegate = self
            editImageVC.monetizeSpark = monetizeSpark
            editImageVC.asseturl = AudioRecorderManager.shared.currentRecordPath ?? URL(fileURLWithPath: "")
            self.present(editImageVC, animated: true, completion: nil)
        }catch{
            debugPrint(error.localizedDescription)
        }
       
    }
    
}
