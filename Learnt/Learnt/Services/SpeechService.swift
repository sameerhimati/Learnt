//
//  SpeechService.swift
//  Learnt
//

import Foundation
import Speech
import AVFoundation

@Observable
final class SpeechService {
    var transcribedText: String = ""
    var isRecording: Bool = false
    var isAuthorized: Bool = false
    var errorMessage: String?
    var recordedAudioData: Data?

    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    // Audio recording
    private var audioFile: AVAudioFile?
    private var audioFileURL: URL?

    init() {
        checkAuthorization()
    }

    // MARK: - Authorization

    func checkAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.isAuthorized = true
                case .denied, .restricted, .notDetermined:
                    self?.isAuthorized = false
                    self?.errorMessage = "Speech recognition not authorized"
                @unknown default:
                    self?.isAuthorized = false
                }
            }
        }
    }

    // MARK: - Recording

    func startRecording() {
        guard isAuthorized else {
            errorMessage = "Speech recognition not authorized"
            return
        }

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            errorMessage = "Speech recognition unavailable"
            return
        }

        // Reset state
        transcribedText = ""
        errorMessage = nil
        recordedAudioData = nil

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Audio session error"
            return
        }

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create recognition request"
            return
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.addsPunctuation = true

        // Start audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            errorMessage = "Unable to create audio engine"
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Setup audio file for recording
        setupAudioFile(format: recordingFormat)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            recognitionRequest.append(buffer)
            // Also write to audio file
            self?.writeToAudioFile(buffer: buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "Audio engine couldn't start"
            return
        }

        // Start recognition task
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.transcribedText = result.bestTranscription.formattedString
                }

                if error != nil || (result?.isFinal ?? false) {
                    self?.stopRecording()
                }
            }
        }
    }

    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        // Finalize audio file and load data
        finalizeAudioFile()

        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil

        isRecording = false

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    // MARK: - Audio File Management

    private func setupAudioFile(format: AVAudioFormat) {
        let tempDir = FileManager.default.temporaryDirectory
        audioFileURL = tempDir.appendingPathComponent("voice_recording_\(UUID().uuidString).m4a")

        guard let url = audioFileURL else { return }

        // Create audio file with AAC format for smaller size
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: format.sampleRate,
            AVNumberOfChannelsKey: format.channelCount,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        do {
            audioFile = try AVAudioFile(forWriting: url, settings: settings)
        } catch {
            // If AAC fails, try with the original format
            do {
                audioFile = try AVAudioFile(forWriting: url, settings: format.settings)
            } catch {
                print("Failed to create audio file: \(error)")
                audioFile = nil
            }
        }
    }

    private func writeToAudioFile(buffer: AVAudioPCMBuffer) {
        guard let audioFile = audioFile else { return }
        do {
            try audioFile.write(from: buffer)
        } catch {
            // Silently fail - transcription still works
        }
    }

    private func finalizeAudioFile() {
        audioFile = nil

        guard let url = audioFileURL else { return }

        // Load the audio data
        do {
            recordedAudioData = try Data(contentsOf: url)
        } catch {
            print("Failed to load audio data: \(error)")
        }

        // Clean up temp file
        try? FileManager.default.removeItem(at: url)
        audioFileURL = nil
    }

    func clearAudioData() {
        recordedAudioData = nil
    }
}
