//
//  VoiceRecorderService.swift
//  Learnt
//

import Foundation
import AVFoundation
import Speech
import UIKit

@Observable
final class VoiceRecorderService: NSObject {
    static let shared = VoiceRecorderService()

    // MARK: - State

    var isRecording = false
    var recordingDuration: TimeInterval = 0
    var audioLevel: Float = 0

    // MARK: - Private

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var currentRecordingURL: URL?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    // MARK: - Permissions

    func requestPermissions() async -> Bool {
        // Request microphone permission only (no transcription)
        let audioGranted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        return audioGranted
    }

    var hasPermissions: Bool {
        AVAudioSession.sharedInstance().recordPermission == .granted
    }

    // MARK: - Recording

    func startRecording() -> URL? {
        guard !isRecording else { return nil }

        // Configure audio session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
            return nil
        }

        // Create unique filename
        let fileName = "voice_\(UUID().uuidString).m4a"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent(fileName)

        // Recording settings
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            currentRecordingURL = audioURL
            isRecording = true
            recordingDuration = 0

            // Keep screen awake during recording
            UIApplication.shared.isIdleTimerDisabled = true

            // Start timer for duration and level updates
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.updateRecordingState()
            }

            return audioURL
        } catch {
            print("Failed to start recording: \(error)")
            return nil
        }
    }

    func stopRecording() -> URL? {
        guard isRecording else { return nil }

        recordingTimer?.invalidate()
        recordingTimer = nil

        audioRecorder?.stop()
        isRecording = false
        audioLevel = 0

        // Allow screen to sleep again
        UIApplication.shared.isIdleTimerDisabled = false

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false)

        return currentRecordingURL
    }

    func cancelRecording() {
        guard isRecording else { return }

        recordingTimer?.invalidate()
        recordingTimer = nil

        audioRecorder?.stop()
        isRecording = false
        audioLevel = 0
        recordingDuration = 0

        // Allow screen to sleep again
        UIApplication.shared.isIdleTimerDisabled = false

        // Delete the recording file
        if let url = currentRecordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        currentRecordingURL = nil

        try? AVAudioSession.sharedInstance().setActive(false)
    }

    private func updateRecordingState() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }

        recordingDuration = recorder.currentTime
        recorder.updateMeters()
        audioLevel = recorder.averagePower(forChannel: 0)
    }

    // MARK: - Playback

    func playAudio(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - Transcription

    func transcribe(audioURL: URL) async -> String? {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognizer not available")
            return nil
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false

        do {
            let result = try await recognizer.recognitionTask(with: request)
            return result.bestTranscription.formattedString
        } catch {
            print("Transcription failed: \(error)")
            return nil
        }
    }

    // MARK: - File Management

    func deleteAudioFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    func audioDuration(for url: URL) -> TimeInterval? {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            return player.duration
        } catch {
            return nil
        }
    }

    private override init() {
        super.init()
    }
}

// MARK: - AVAudioRecorderDelegate

extension VoiceRecorderService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording finished unsuccessfully")
        }
    }
}

// MARK: - SFSpeechRecognizer Extension

extension SFSpeechRecognizer {
    func recognitionTask(with request: SFSpeechRecognitionRequest) async throws -> SFSpeechRecognitionResult {
        try await withCheckedThrowingContinuation { continuation in
            recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result, result.isFinal {
                    continuation.resume(returning: result)
                }
            }
        }
    }
}
