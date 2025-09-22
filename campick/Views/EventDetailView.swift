import SwiftUI

struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmation = false
    
    var body: some View {
        ZStack{
            AppColors.brandBackground.ignoresSafeArea(.container, edges: .all)
            VStack {
                TopBarView(title: "매물 찾기") {
                                dismiss()
                            }
                ScrollView {
                    VStack() {
                        ZStack {
                            Image("bottomBannerImage")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 140)
                                .cornerRadius(16)
                                .clipped()
                            
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
                                        Text("수수료 50% 할인 쿠폰")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                            .fontWeight(.heavy)
                                    }
                                    Text("지금 응모하고 혜택 받기")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .fontWeight(.heavy)
                                }
                                Spacer()
                            }
                            .padding()
                        }
                        
                        
                        VStack(alignment: .leading){
                            VStack(alignment: .leading){
                                Text("수수료 50% 할인 쿠폰 응모")
                                    .font(.system(size: 20,weight: .bold))
                                    .padding(.top,20)
                                    .padding(.bottom,1)
                                Text("응모하고 수수료 50% 할인 쿠폰을 받아보세요")
                                    .font(.system(size: 17,weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom,30)
                                
                                
                                Text("혜택")
                                    .font(.system(size: 18,weight: .bold))
                                    .padding(.bottom,1)
                                Text("· 수수료 50% 할인 쿠폰 1매 제공\n· 쿠폰은 지정 카테고리에서 사용 가능 \n· 다른 할인과 중복 적용 불가 (프로모션 코드 포함)\n· 쿠폰 지급 시점: 응모 즉시 계정에 자동 지급\n· 사용 기한: 발급일로부터 7일 이내")
                                    .font(.system(size: 15,weight: .light))
                                    .padding(.bottom,20)
                                
                                
                                Text("기간")
                                    .font(.system(size: 18,weight: .bold))
                                    .padding(.bottom,1)
                                Text("응모 기간: 2025.09.01 ~ 2025.10.31")
                                    .font(.system(size: 15,weight: .bold))
                                    .padding(.bottom,20)
                                
                                
                                Text("유의사항")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.bottom,1)
                                Text("· 응모는 계정당 1회만 가능합니다.\n· 쿠폰은 발급일로부터 7일 이내 사용해야 합니다.\n· 부정 응모가 확인될 경우 쿠폰이 회수될 수 있습니다.\n· 자세한 내용은 고객센터 공지사항을 확인해 주세요.")
                                    .font(.system(size: 15,weight: .bold))
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.leading, -45)
                            .foregroundStyle(.white)
                            
                            
                            
                        }
                        
                        
                    }
                    .padding(.leading, 10)
                    
                }
                .padding(.horizontal)
                .padding(.vertical)
                Button(action: {
                    showConfirmation = true
                }) {
                    Text("쿠폰 응모하기")
                        .frame(maxWidth: 300)
                        .padding()
                        .background(AppColors.brandOrange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .alert("응모가 완료되었습니다", isPresented: $showConfirmation) {
                Button("확인", role: .cancel) { }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        EventDetailView()
            
    }
}
