//
//  VoiceRecordingView.swift
//  Learnt
//

import SwiftUI
import AVFoundation

struct VoiceRecordingView: View {
    @Binding var audioFileName: String?
    @Binding var title: String
    @Binding var transcription: String?

    @State private var isRecording = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var isPlaying = false
    @State private var showPermissionAlert = false
    @State private var wantsTranscription = false
    @State private var isTranscribing = false
    @State private var editableTranscription = ""
    @StateObject private var playbackManager = RecordingPlaybackManager()
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isTranscriptionFocused: Bool

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

            // Transcription toggle
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Transcribe audio")
                        .font(.system(size: 12, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    Spacer()

                    if isTranscribing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Toggle("", isOn: $wantsTranscription)
                            .labelsHidden()
                            .toggleStyle(MonochromeToggleStyle())
                    }
                }

                // Editable transcription
                if wantsTranscription {
                    if isTranscribing {
                        Text("Transcribing...")
                            .font(.system(size: 13, design: .serif))
                            .foregroundStyle(Color.secondaryTextColor)
                            .italic()
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appBackgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(editableTranscription.isEmpty ? "Tap to add transcription" : "Edit if needed")
                                .font(.system(size: 10, design: .serif))
                                .foregroundStyle(Color.secondaryTextColor.opacity(0.7))

                            TextEditor(text: $editableTranscription)
                                .font(.system(.body, design: .serif))
                                .foregroundStyle(Color.primaryTextColor)
                                .focused($isTranscriptionFocused)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .frame(minHeight: 80, maxHeight: 120)
                                .background(Color.appBackgroundColor)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onChange(of: editableTranscription) { _, newValue in
                                    transcription = newValue.isEmpty ? nil : newValue
                                }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .onChange(of: wantsTranscription) { _, shouldTranscribe in
                if shouldTranscribe && editableTranscription.isEmpty && transcription == nil {
                    // Only transcribe if we don't already have one
                    performTranscription()
                } else if !shouldTranscribe {
                    editableTranscription = ""
                    transcription = nil
                }
            }

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
            // If we already have a transcription, restore the state
            if let existingTranscription = transcription, !existingTranscription.isEmpty {
                editableTranscription = existingTranscription
                wantsTranscription = true
            }

            // Focus title field when recording is done (only if no title yet)
            if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isTitleFocused = true
                }
            }
        }
    }

    private func performTranscription() {
        guard let url = audioURL else { return }

        isTranscribing = true

        Task {
            if let text = await recorder.transcribe(audioURL: url) {
                await MainActor.run {
                    editableTranscription = text
                    transcription = text
                    isTranscribing = false

                    // Auto-fill title if empty
                    if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        title = text
                    }
                }
            } else {
                await MainActor.run {
                    editableTranscription = ""
                    isTranscribing = false
                    wantsTranscription = false
                }
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
    VoiceRecordingView(audioFileName: .constant(nil), title: .constant(""), transcription: .constant(nil))
        .padding()
        .background(Color.appBackgroundColor)
}

// MARK: - Monochrome Toggle Style

struct MonochromeToggleStyle: ToggleStyle {
    @Environment(\.colorScheme) private var colorScheme

    private func trackOffColor(_ scheme: ColorScheme) -> Color {
        // More visible off state in dark mode
        scheme == .dark ? Color.secondaryTextColor.opacity(0.4) : Color.dividerColor
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            Spacer()

            Button {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                    configuration.isOn.toggle()
                }
            } label: {
                ZStack {
                    // Track
                    Capsule()
                        .fill(configuration.isOn ? Color.primaryTextColor : trackOffColor(colorScheme))
                        .frame(width: 51, height: 31)

                    // Thumb
                    Circle()
                        .fill(Color.appBackgroundColor)
                        .overlay(
                            Circle()
                                .stroke(configuration.isOn ? Color.primaryTextColor : Color.secondaryTextColor.opacity(0.5), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                        .frame(width: 27, height: 27)
                        .offset(x: configuration.isOn ? 10 : -10)
                }
            }
            .buttonStyle(.plain)
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isOn)
    }
}

#Preview("Has Recording") {
    VoiceRecordingView(audioFileName: .constant("test.m4a"), title: .constant("My learning"), transcription: .constant(nil))
        .padding()
        .background(Color.appBackgroundColor)
}
