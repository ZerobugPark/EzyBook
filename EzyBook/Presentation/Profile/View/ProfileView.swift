//
//  ProfileView.swift
//  EzyBook
//
//  Created by youngkyun park on 5/11/25.
//

import SwiftUI





struct ProfileView: View {
    


    var body: some View {
        VStack(spacing: 15) {
            
            
        }
        .padding([.horizontal, .top], 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            GeometryReader { proxy in
            
                LinearGradient(colors: [.blackSeafoam ,.deepSeafoam, .blackSeafoam], startPoint: .top, endPoint: .bottom)
            }
        }
       

            
    }


}



#Preview {
    ProfileView()
}
