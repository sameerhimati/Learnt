//
//  VoiceInputView.swift
//  Learnt
//

import SwiftUI

struct VoiceInputView: View {
    let onSave: (String, Data?) -> Void
    let onCancel: () -> Void

    @State private var speechService = SpeechService()
    @State private var pulseAnimation = false
    @State private var keepAudio = false
    @AppStorage("alwaysSaveAudio") private var alwaysSaveAudio = false

    private var canSave: Bool {
        !speechService.transcribedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasFinishedRecording: Bool {
        !speechService.isRecording && !speechService.transcribedText.isEmpty
    }

    var body: some View {
        ZStack {
            Color.appBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                topBar

                // Transcribed text area
                transcriptionArea

                // Keep audio toggle (shows after recording)
                if hasFinishedRecording && speechService.recordedAudioData != nil {
                    keepAudioToggle
                }

                // Visual feedback and controls
                controlsArea
            }
        }
        .onAppear {
            keepAudio = alwaysSaveAudio
            speechService.startRecording()
        }
        .onDisappear {
            speechService.stopRecording()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: {
                speechService.stopRecording()
                onCancel()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.secondaryTextColor)
                    .frame(width: 32, height: 32)
                    .background(Color.inputBackgroundColor)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: saveEntry) {
                Text("Save")
                    .font(.system(.body, design: .serif, weight: .medium))
                    .foregroundStyle(canSave ? Color.primaryTextColor : Color.secondaryTextColor)
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Transcription Area

    private var transcriptionArea: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if speechService.transcribedText.isEmpty {
                    Text(speechService.isRecording ? "Listening..." : "Tap to start speaking")
                        .font(.system(.title2, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                } else {
                    Text(speechService.transcribedText)
                        .font(.system(.title2, design: .serif))
                        .foregroundStyle(Color.primaryTextColor)
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .animation(.easeOut(duration: 0.1), value: speechService.transcribedText)
                }

                if let error = speechService.errorMessage {
                    Text(error)
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Keep Audio Toggle

    private var keepAudioToggle: some View {
        HStack {
            Image(systemName: keepAudio ? "waveform.circle.fill" : "waveform.circle")
                .font(.system(size: 20))
                .foregroundStyle(keepAudio ? Color.primaryTextColor : Color.secondaryTextColor)

            Text("Keep audio")
                .font(.system(.body, design: .serif))
                .foregroundStyle(Color.primaryTextColor)

            Spacer()

            Toggle("", isOn: $keepAudio)
                .labelsHidden()
                .tint(Color.primaryTextColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.inputBackgroundColor)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }

    // MARK: - Controls Area

    private var controlsArea: some View {
        VStack(spacing: 24) {
            // Recording indicator
            ZStack {
                // Pulse rings
                if speechService.isRecording {
                    Circle()
                        .stroke(Color.primaryTextColor.opacity(0.1), lineWidth: 2)
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                        .opacity(pulseAnimation ? 0 : 0.5)
                        .animation(
                            .easeOut(duration: 1.0).repeatForever(autoreverses: false),
                            value: pulseAnimation
                        )

                    Circle()
                        .stroke(Color.primaryTextColor.opacity(0.15), lineWidth: 2)
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                        .opacity(pulseAnimation ? 0 : 0.7)
                        .animation(
                            .easeOut(duration: 1.0).repeatForever(autoreverses: false).delay(0.3),
                            value: pulseAnimation
                        )
                }

                // Mic button
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(speechService.isRecording ? Color.primaryTextColor : Color.inputBackgroundColor)
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

                        Image(systemName: speechService.isRecording ? "stop.fill" : "mic")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundStyle(speechService.isRecording ? Color.appBackgroundColor : Color.primaryTextColor)
                    }
                }
                .buttonStyle(.plain)
            }
            .frame(height: 120)
            .onAppear {
                pulseAnimation = true
            }

            // Status text
            Text(statusText)
                .font(.system(.caption, design: .serif))
                .foregroundStyle(Color.secondaryTextColor)
        }
        .padding(.vertical, 32)
    }

    private var statusText: String {
        if speechService.isRecording {
            return "Tap to stop"
        } else if hasFinishedRecording {
            return "Tap to record more"
        } else {
            return "Tap to record"
        }
    }

    // MARK: - Actions

    private func toggleRecording() {
        if speechService.isRecording {
            speechService.stopRecording()
        } else {
            speechService.startRecording()
        }
    }

    private func saveEntry() {
        speechService.stopRecording()
        let audioData = keepAudio ? speechService.recordedAudioData : nil
        onSave(speechService.transcribedText, audioData)
    }
}

#Preview {
    VoiceInputView(
        onSave: { _, _ in },
        onCancel: {}
    )
}
