import speech_recognition as sr
import sys
b = sys.argv[1]
#print(b)
def audio_to_text(b):
    #print("Inside Function")
    filename = b
    r = sr.Recognizer()
    with sr.AudioFile(filename) as source:
        audio_data = r.record(source)
        text = r.recognize_google(audio_data)
    return(text)
    
a = audio_to_text(b)
print(a)

