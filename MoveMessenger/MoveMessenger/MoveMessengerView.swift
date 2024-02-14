import SwiftUI

struct MoveMessengerView: View {
    @StateObject var moveSession = MoveMultipeerSession()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Connected Devices:")
                .bold()
            Text(String(describing: moveSession.connectedPeers.map(\.displayName)))

            Divider()

            VStack {
                ForEach(Move.allCases, id: \.self) { move in
                    Button(move.rawValue) {
                        moveSession.send(move: move)
                    }
                    .padding()
                }
            }

            Text("Current Move: \(moveSession.currentMove?.rawValue ?? "None")")
            Text("Last Move Latency: \(moveSession.latency) seconds")
            Text("Highest Latency: \(moveSession.maxLatency) seconds")
            Text("Average Latency: \(moveSession.avgLatency) seconds")

            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MoveMessengerView()
    }
}
