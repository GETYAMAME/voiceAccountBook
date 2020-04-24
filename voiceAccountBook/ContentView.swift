import SwiftUI
import Speech
struct ContentView: View {
    @State var recognizedText: String?
    @State var message: String = ""
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var body: some View {
        VStack(alignment: .trailing) {
            Text(recognizedText ?? "")
                .font(.body)
                .border(Color.gray)
                .padding()
            HStack {
                Text(message)
                Button("録音開始") {
                    self.message = "音声認識中..."
                    if self.audioEngine.isRunning {
                        self.audioEngine.stop()
                        self.recognitionRequest.endAudio()
                        self.recognitionTask?.cancel()
                        self.message = "END"
                    } else {
                        // マイクからの音声を解析エンジンに渡す
                        let recordingFormat = self.audioEngine.inputNode.outputFormat(forBus: 0)
                        self.audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                                   self.recognitionRequest.append(buffer)
                        }
                        try! self.audioEngine.start()
                        _ = self.speechRecognizer?.recognitionTask(with: self.recognitionRequest, resultHandler: { (speechResult, error) in
                            guard let speechResult = speechResult else {
                                return
                            }

                            if speechResult.isFinal {
                                self.message = "音声認識が完了しました"
                                print("Speech in the file is \(speechResult.bestTranscription.formattedString)")
                            } else {
                                let text = speechResult.bestTranscription.formattedString
                                self.message = text
                            }
                        })
                    }
                }.padding()
            }
        }
    }
}
