//
//  BannerView.swift
//  Crypta2.0
//
//  Created by Mitch on 7/21/22.
//

import SwiftUI

//extension View {
//    func banner(title: Binding<String>, show: Binding<Bool>) -> some View {
//        self.modifier(BannerView(show: show, title:title))
//    }
//}

struct BannerView: View {
    
    struct BannerData {
        var title:String
        var detail:String
    }
    
    @Binding var show:Bool
    @Binding var title:String
    
    var body: some View {
        
              if show {
                  VStack {
                      HStack {
                          VStack(alignment: .leading, spacing: 2) {
                              Text(title)
                                  .bold()
                              //Text(data.detail)
                              //  .font(Font.system(size: 15, weight: Font.Weight.light, design: Font.Design.default))
                          }
                          Spacer()
                      }
                      .foregroundColor(Color.white)
                      .padding(12)
                      .background(Color("Prime"))
                      .cornerRadius(8)
                      Spacer()
                  }
                  .zIndex(1)
                  .padding()
                  .animation(.easeInOut)
                  .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                  .onTapGesture {
                      withAnimation {
                          self.show = false
                      }
                  }.onAppear(perform: {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                          withAnimation {
                              self.show = false
                          }
                      }
                  })
              }
    }
    
}

