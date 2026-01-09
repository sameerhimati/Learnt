//
//  AudioPlaybackButton.swift
//  Learnt
//

import SwiftUI
import AVFoundation

struct AudioPlaybackButton: View {
    let audioURL: URL?

    @State private var isPlaying = false
    @StateObject private var playbackManager = AudioPlaybackManager()

    var body: some View {
        if audioURL != nil {
            Button {
                togglePlayback()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 10))
                    Image(systemName: "waveform")
                        .font(.system(size: 10))
                }
                .foregroundStyle(Color.secondaryTextColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.appBackgroundColor)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .onDisappear {
                stopPlayback()
            }
            .onChange(of: playbackManager.isPlaying) { _, newValue in
                isPlaying = newValue
            }
        }
    }

    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }

    private func startPlayback() {
        guard let url = audioURL else { return }
        playbackManager.play(url: url)
    }

    private func stopPlayback() {
        playbackManager.stop()
    }
}

// Manager class to handle audio playback with proper delegate lifecycle
private class AudioPlaybackManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
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

#Preview {
    VStack(spacing: 20) {
        AudioPlaybackButton(audioURL: nil)
        AudioPlaybackButton(audioURL: URL(string: "file:///test.m4a"))
    }
    .padding()
    .background(Color.inputBackgroundColor)
}
