//
//  TopBanner.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI
import AVKit
struct TopBanner: View {
    
//    @State private var player: AVPlayer? = {
//           if let path = Bundle.main.path(forResource: "topBanner", ofType: "mov") {
//               let url = URL(fileURLWithPath: path)
//               let asset = AVURLAsset(url: url)
//               let item = AVPlayerItem(asset: asset)
//
//               // 오디오 트랙 비활성화 (소리 아예 제거)
//               item.tracks.forEach { track in
//                   if track.assetTrack?.mediaType == .audio {
//                       track.isEnabled = false
//                   }
//               }
//
//               return AVPlayer(playerItem: item)
//           }
//           return nil
//       }()
//    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
//            if let player = player {
//                            VideoPlayer(player: player)
//                                .frame(height: 200)
//                                .cornerRadius(20)
//                                .clipped()
//                                .shadow(radius: 5)
//                                .onAppear {
//                                    player.play()
//                                    player.actionAtItemEnd = .none
//                                    NotificationCenter.default.addObserver(
//                                        forName: .AVPlayerItemDidPlayToEndTime,
//                                        object: player.currentItem,
//                                        queue: .main
//                                    ) { _ in
//                                        player.seek(to: .zero)
//                                        player.play()
//                                    }
//                                }
//                                .onDisappear {
//                                    player.pause()
//                                    NotificationCenter.default.removeObserver(self)
//                                }
//                        } else {
                            Image("bannerImage")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .cornerRadius(20)
                                .shadow(radius: 5)
//                        }
            
            
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
                startPoint: .bottom,
                endPoint: .top
            )
            .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("완벽한 캠핑카를\n찾아보세요")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 7)
                Text("전국 최다 프리미엄 캠핑카 매물")
                    .font(.system(size:13))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
    }
}
