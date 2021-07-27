
import sys
import requests
import json
#callerid = '8369854211'
callerid = sys.argv[1]
def getcircle(callerid):
    URL = "https://api.datayuge.com/api/v1/lookup/mnp/rubicsolution?apikey=05BQaZLdYLJuhZK5AgwZ08sH9MyE1l5c&number="
    PARAMS = {'number':callerid}
    r = requests.get(url = URL, params = PARAMS)
    data = r.json()
    dict_a = data
    dict_circle = dict_a['data']
    circle = dict_circle['circle']
    #return(circle)
    if(circle == "Maharashtra"):
        return(23)
    if(circle == "Mumbai"):
        return(24)
    
    
a = getcircle(callerid)
print(a)
