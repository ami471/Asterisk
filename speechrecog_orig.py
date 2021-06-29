import speech_recognition as sr
def audio_to_text():
    filename = "media_rec-3.wav"
    r = sr.Recognizer()
    with sr.AudioFile(filename) as source:
        audio_data = r.record(source)
        text = r.recognize_google(audio_data)
    return(text)
    
a = audio_to_text()
print(a)

