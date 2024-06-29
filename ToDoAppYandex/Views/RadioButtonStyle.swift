import SwiftUI

struct RadioButtonStyle: View {
    var isReady: Bool
    var importance: Importance


    var body: some View {
            if isReady {
                Circle()
                    .fill(Color.cGreen)
                    .frame(width: 24, height: 24)
                Image(systemName: "checkmark")
                    .foregroundColor(.cWhite)
                    .font(.system(size: 12))
            } else {
                switch importance {
                case .high:
                    HStack {
                        Circle()
                            .stroke(Color.cRed, lineWidth: 1)
                            .background(Circle().fill(Color.cRed.opacity(0.1)))
                            .frame(width: 24, height: 24)
                        Image(systemName:"exclamationmark.2")
                            .foregroundColor(.cRed)
                            .font(.system(size: 16))
                    }
                    
                case .low:
                    HStack {
                        Circle()
                            .stroke(Color.cGray, lineWidth: 1)
                            .background(Circle().fill(Color.clear))
                        .frame(width: 24, height: 24)
                        Image(systemName: "arrow.down")
                            .foregroundColor(.cGray)
                            .font(.system(size: 16))
                    }
                    
                case .medium:
                    Circle()
                        .stroke(Color.cGray, lineWidth: 2)
                        .background(Circle().fill(Color.clear))
                        .frame(width: 24, height: 24)
                }
            }
        }
}

#Preview {
    VStack {
        RadioButtonStyle(isReady: true, importance: .medium)
        RadioButtonStyle(isReady: false, importance: .high)
        RadioButtonStyle(isReady: false, importance: .low)
        RadioButtonStyle(isReady: false, importance: .medium)
    }
    
}



