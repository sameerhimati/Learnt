//
//  EntryCard.swift
//  Learnt
//

import SwiftUI
import AVFoundation

struct EntryCard: View {
    let entry: LearningEntry
    let onEdit: () -> Void

    @State private var isExpanded = false
    @State private var isPlayingAudio = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioDelegate: AudioPlayerDelegate?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                // Voice/Audio indicator
                if entry.isVoiceEntry {
                    if entry.hasAudio {
                        // Play button when audio is available
                        Button(action: toggleAudioPlayback) {
                            Image(systemName: isPlayingAudio ? "stop.circle.fill" : "play.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Color.primaryTextColor)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Just mic icon when no audio stored
                        Image(systemName: "mic")
                            .font(.system(.caption))
                            .foregroundStyle(Color.secondaryTextColor)
                    }
                }

                // Content
                Text(isExpanded ? entry.content : entry.previewText)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(Color.primaryTextColor)
                    .lineLimit(isExpanded ? nil : 1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Expand indicator
                if !isExpanded && entry.content.count > 50 {
                    Image(systemName: "chevron.down")
                        .font(.system(.caption))
                        .foregroundStyle(Color.secondaryTextColor)
                }
            }

            // Timestamp and edit button (only when expanded)
            if isExpanded {
                HStack {
                    Text(entry.createdAt, style: .time)
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(Color.secondaryTextColor)

                    Spacer()

                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(.body))
                            .foregroundStyle(Color.secondaryTextColor)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color.inputBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
        .onLongPressGesture {
            onEdit()
        }
        .onDisappear {
            stopAudio()
        }
    }

    // MARK: - Audio Playback

    private func toggleAudioPlayback() {
        if isPlayingAudio {
            stopAudio()
        } else {
            playAudio()
        }
    }

    private func playAudio() {
        guard let audioData = entry.audioData else { return }

        do {
            // Configure audio session for playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            audioPlayer = try AVAudioPlayer(data: audioData)
            audioDelegate = AudioPlayerDelegate {
                DispatchQueue.main.async {
                    isPlayingAudio = false
                }
            }
            audioPlayer?.delegate = audioDelegate
            audioPlayer?.play()
            isPlayingAudio = true
        } catch {
            print("Failed to play audio: \(error)")
        }
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlayingAudio = false
    }
}

// MARK: - Audio Player Delegate

private class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}

#Preview {
    VStack(spacing: 16) {
        EntryCard(
            entry: {
                let entry = LearningEntry(content: "Short learning")
                return entry
            }(),
            onEdit: {}
        )

        EntryCard(
            entry: {
                let entry = LearningEntry(
                    content: "Today I learned about SwiftUI animations and how they can make the user interface feel more responsive and polished.",
                    isVoiceEntry: true
                )
                return entry
            }(),
            onEdit: {}
        )
    }
    .padding()
    .background(Color.appBackgroundColor)
}
