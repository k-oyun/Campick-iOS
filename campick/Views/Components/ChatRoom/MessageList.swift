//
//  MessageList.swift
//  campick
//
//  Created by Admin on 9/18/25.
//

import SwiftUI

private struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct BottomAnchorPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ContainerBottomPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
struct MessageList: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var isAtBottom: Bool = true
    private let bottomThreshold: CGFloat = 80
    @State private var didScrollToBottomInitially = false
    @State private var scrollProxy: ScrollViewProxy?
    @State private var containerMaxY: CGFloat = .zero
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
//                    ForEach(viewModel.messages) { msg in
//                        MessageBubble(
//                            message: msg,
//                            viewModel: viewModel
//                        )
//                        .id(msg.id)
//                    }
                    // ID 충돌 방지를 위해 index 기반 ID 사용 (단기 해결)
                    ForEach(Array(viewModel.messages.enumerated()), id: \.0) { index, msg in
                        let isLast = index == viewModel.messages.count - 1
                        MessageBubble(
                            message: msg,
                            isLast: isLast,
                            viewModel: viewModel
                            
                        )
                        .id(msg.id)
                    }
                    // 바닥 앵커
                    Color.clear
                        .frame(height: 1)
                        .id("bottom-anchor")
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(
                                        key: BottomAnchorPreferenceKey.self,
                                        value: geo.frame(in: .named("scroll")).maxY
                                    )
                            }
                        )
                    
//                    if viewModel.isTyping {
//                        HStack {
//                            TypingIndicator()
//                            Spacer()
//                        }
//                    }
                }
                .padding()
            }
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .preference(
                            key: ContainerBottomPreferenceKey.self,
                            value: geo.frame(in: .named("scroll")).maxY
                        )
                }
            )
            .coordinateSpace(name: "scroll")
            .onAppear {
                scrollProxy = proxy
                guard !didScrollToBottomInitially else { return }
                didScrollToBottomInitially = true
                scrollToBottom(proxy: proxy, animated: false)
                
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom(proxy: proxy, animated: true)
            }
//            .onChange(of: viewModel.isTyping) { _, _ in
//                if viewModel.isTyping && isAtBottom {
//                    withAnimation(.easeInOut) {
//                        proxy.scrollTo("bottom-anchor", anchor: .bottom)
//                    }
//                }
//            }
//            .onChange(of: viewModel.messages) { _, newMessages in
//                guard let last = newMessages.last else { return }
//                if last.isMyMessage {
//                    scrollToBottom(proxy: proxy, animated: true)
//                } else if isAtBottom {
//                    scrollToBottom(proxy: proxy, animated: true)
//                }
//            }
            .onPreferenceChange(ContainerBottomPreferenceKey.self) { value in
                containerMaxY = value
            }
            .onPreferenceChange(BottomAnchorPreferenceKey.self) { bottomMaxY in
                let distance = containerMaxY - bottomMaxY
                withAnimation(.easeInOut(duration: 0.2)) {
                    isAtBottom = distance >= 0 && distance <= bottomThreshold
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if !isAtBottom {
                Button {
                    if let proxy = scrollProxy {
                        withAnimation(.easeInOut) {
                            proxy.scrollTo("bottom-anchor", anchor: .bottom)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(AppColors.brandOrange.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut, value: isAtBottom)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
        if animated {
            withAnimation(.easeInOut) {
                proxy.scrollTo("bottom-anchor", anchor: .bottom)
            }
        } else {
            proxy.scrollTo("bottom-anchor", anchor: .bottom)
        }
    }
}

struct MessageBubble: View {
    let message: Chat
    let isLast: Bool
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        HStack {
            if viewModel.isMyMessage(message) {
                Spacer()
                VStack(alignment: .trailing) {
                    if let url = URL(string: message.message),
                       message.message.hasPrefix("http") {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 200, height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 200, maxHeight: 200)
                                    .cornerRadius(12)
                            case .failure:
                                Text("이미지를 불러올 수 없습니다")
                                    .foregroundColor(.red)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Text(message.message)
                            .padding()
                            .background(AppColors.brandOrange)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }

                    if isLast {
                        HStack(spacing: 4) {
                            Text(message.sendAt)
                                .foregroundColor(.white.opacity(0.5))
                                .font(.caption2)
                        }
                    }
                }
                .frame(maxWidth: 300, alignment: .trailing)
            } else {
                Image("bannerImage")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    if let url = URL(string: message.message),
                       message.message.hasPrefix("http") {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 200, height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 200, maxHeight: 200)
                                    .cornerRadius(12)
                            case .failure:
                                Text("이미지를 불러올 수 없습니다")
                                    .foregroundColor(.red)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Text(message.message)
                            .padding()
                            .background(.ultraThinMaterial.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    
                    if isLast {
                        HStack(spacing: 4) {
                            Text(message.sendAt)
                                .foregroundColor(.white.opacity(0.5))
                                .font(.caption2)
                        }
                    }
                }
                .frame(maxWidth: 300, alignment: .leading)
                .padding(.vertical, 4)
            }
        }
    }
}
