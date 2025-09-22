//
//  BottomBanner.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI
import AVKit

struct BottomBanner: View {
    
    @State private var player: AVPlayer? = {
        if let path = Bundle.main.path(forResource: "bottomBanner", ofType: "mov") {
            let url = URL(fileURLWithPath: path)
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            
            
            item.tracks.forEach { track in
                if track.assetTrack?.mediaType == .audio {
                    track.isEnabled = false
                }
            }

            return AVPlayer(playerItem: item)
        }
        return nil
    }()
    
    @State private var endObserver: NSObjectProtocol? = nil
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .frame(height: 140)
                    .cornerRadius(16)
                    .clipped()
                    .onAppear {
                        player.isMuted = true
                        player.play()
                        player.actionAtItemEnd = .none
                        endObserver = NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: player.currentItem,
                            queue: .main
                        ) { _ in
                            player.seek(to: .zero)
                            player.play()
                        }
                    }
                    .onDisappear {
                        player.pause()
                        if let endObserver {
                            NotificationCenter.default.removeObserver(endObserver)
                            self.endObserver = nil
                        }
                    }
            } else {
                Color.black.frame(height: 140).cornerRadius(16)
                #if DEBUG
                Text("Missing bottomBanner.mp4")
                    .foregroundColor(.white)
                    .font(.caption)
                #endif
            }
            

//            Image("bottomBannerImage")
//                .resizable()
//                .scaledToFill()
//                .frame(height: 140)
//                .cornerRadius(16)
//                .clipped()
            
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .cornerRadius(16)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(AppColors.brandOrange)
                        Text("첫 거래 특별 혜택")
                            .foregroundColor(.white)
                            .font(.caption)
                            .fontWeight(.heavy)
                    }
                    Text("수수료 50% 할인")
                        .foregroundColor(.white)
                        .font(.headline)
                        .fontWeight(.heavy)
                }
                Spacer()
                NavigationLink(destination: EventDetailView()) {
                    Text("자세히 보기")
                        .bold()
                        .font(.system(size: 11))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.brandOrange)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
        }
    }
}

#Preview {
    BottomBanner()
}
