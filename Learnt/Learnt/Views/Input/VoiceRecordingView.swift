//
//  VoiceRecordingView.swift
//  Learnt
//

import SwiftUI
import AVFoundation

struct VoiceRecordingView: View {
    @Binding var audioFileName: String?
    @Binding var title: String

    @State private var isRecording = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var isPlaying = false
    @State private var showPermissionAlert = false
    @StateObject private var playbackManager = RecordingPlaybackManager()
    @FocusState private var isTitleFocused: Bool

    private let recorder = VoiceRecorderService.shared

    private var audioURL: URL? {
        guard let fileName = audioFileName else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(fileName)
    }

    var body: some View {
        VStack(spacing: 16) {
            if let _ = audioFileName, !isRecording {
                // Has recording - show playback controls + title input
                hasRecordingView
            } else if isRecording {
                // Currently recording
                recordingView
            } else {
                // Ready to record
                readyView
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onChange(of: recorder.isRecording) { _, newValue in
            isRecording = newValue
        }
        .onChange(of: recorder.recordingDuration) { _, newValue in
            if isRecording {
                recordingDuration = newValue
            }
        }
        .onChange(of: playbackManager.isPlaying) { _, newValue in
            isPlaying = newValue
        }
        .alert("Microphone Access Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable microphone access in Settings to record voice memos.")
        }
    }

    // MARK: - Ready State

    private var readyView: some View {
        VStack(spacing: 16) {
            Text("Tap to record")
                .font(.system(size: 13, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)

            Button {
                startRecording()
            } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.primaryTextColor)
                    .frame(width: 72, height: 72)
                    .background(Color.appBackgroundColor)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Recording State

    private var recordingView: some View {
        VStack(spacing: 16) {
            // Duration with pulsing dot
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.primaryTextColor)
                    .frame(width: 10, height: 10)
                    .opacity(pulsingOpacity)

                Text(formattedDuration(recordingDuration))
                    .font(.system(size: 24, design: .serif).monospacedDigit())
                    .foregroundStyle(Color.primaryTextColor)
            }

            Button {
                stopRecording()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.primaryTextColor)
                    .frame(width: 72, height: 72)
                    .background(Color.appBackgroundColor)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Text("Tap to stop")
                .font(.system(size: 13, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
        }
    }

    @State private var pulsingOpacity: Double = 1.0

    // MARK: - Has Recording State

    private var hasRecordingView: some View {
        VStack(spacing: 20) {
            // Title input
            VStack(alignment: .leading, spacing: 6) {
                Text("Give it a title")
                    .font(.system(size: 12, design: .serif))
                    .foregroundStyle(Color.secondaryTextColor)

                TextField("e.g., Thoughts on design patterns", text: $title)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .focused($isTitleFocused)
                    .padding(12)
                    .background(Color.appBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 16)

            // Playback controls
            HStack(spacing: 16) {
                // Play button
                Button {
                    togglePlayback()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 14))
                        Text(formattedDuration(audioDuration ?? 0))
                            .font(.system(size: 13, design: .serif).monospacedDigit())
                    }
                    .foregroundStyle(Color.primaryTextColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.appBackgroundColor)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                // Delete button
                Button {
                    deleteRecording()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondaryTextColor)
                        .padding(10)
                        .background(Color.appBackgroundColor)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                // Re-record button
                Button {
                    deleteRecording()
                    startRecording()
                } label: {
                    Image(systemName: "mic")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.secondaryTextColor)
                        .padding(10)
                        .background(Color.appBackgroundColor)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            // Focus title field when recording is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTitleFocused = true
            }
        }
    }

    private var audioDuration: TimeInterval? {
        guard let url = audioURL else { return nil }
        return recorder.audioDuration(for: url)
    }

    // MARK: - Helpers

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func startRecording() {
        Task {
            if !recorder.hasPermissions {
                let granted = await recorder.requestPermissions()
                if !granted {
                    showPermissionAlert = true
                    return
                }
            }

            if let url = recorder.startRecording() {
                await MainActor.run {
                    recordingDuration = 0
                    audioFileName = url.lastPathComponent
                    startPulsingAnimation()
                }
            }
        }
    }

    private func stopRecording() {
        _ = recorder.stopRecording()
        stopPulsingAnimation()
    }

    private func togglePlayback() {
        if isPlaying {
            playbackManager.stop()
        } else if let url = audioURL {
            playbackManager.play(url: url)
        }
    }

    private func deleteRecording() {
        playbackManager.stop()

        if let url = audioURL {
            try? FileManager.default.removeItem(at: url)
        }
        audioFileName = nil
    }

    private func startPulsingAnimation() {
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            pulsingOpacity = 0.3
        }
    }

    private func stopPulsingAnimation() {
        withAnimation(.default) {
            pulsingOpacity = 1.0
        }
    }
}

// MARK: - Playback Manager

private class RecordingPlaybackManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    private var audioPlayer: AVAudioPlayer?

    func play(url: URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}

#Preview("Ready") {
    VoiceRecordingView(audioFileName: .constant(nil), title: .constant(""))
        .padding()
        .background(Color.appBackgroundColor)
}

#Preview("Has Recording") {
    VoiceRecordingView(audioFileName: .constant("test.m4a"), title: .constant("My learning"))
        .padding()
        .background(Color.appBackgroundColor)
}
