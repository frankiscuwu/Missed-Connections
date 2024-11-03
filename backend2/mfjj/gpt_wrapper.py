from openai import OpenAI
from dotenv import load_dotenv
import os
import json

def call_gpt(content):
    # load environment variables to connect to ChatGPT api
    load_dotenv()
    client = OpenAI(api_key=os.getenv("CHAT_KEY"))
    
    # Descriptive prompt telling ChatGPT exactly what to output, i.e, a JSON like string that can simply be turned into JSON
    prompt = '''You will be given a list of people. The first person in the list is me, don't include me as a match. Find three other people in the list that most share similar interests to me. Be optimistic. Format each person recomendation in a JSON format. This an an example of an output: ' ,   
                "Example: {
        "recommendations": [
            {"person": "frank",
             "reason": "Frank has an interest in teaching, which aligns with shared educational values."},
            {"person": "jodi",
             "reason": "Jodi's interest in dance and skating shows a creative spirit that could resonate with various artistic interests."},
            {"person": "jodii",
             "reason": "Though Jodii's interests differ, sharing the same school implies potential common ground in social or academic activities."}
        ]
    }. In your JSON, dont put ```json, just put {. Similarly, don't use ``` to end, just put a curly bracket ( } ). Also, don't use single quotes, its json you need to use "". The JSON should be wrapped in curly brackets. DO NOT INCLUDE ME (THE FIRST USER) IN THE JSON RESPONSE EVER, I AM NOT A MATCH FOR MYSELF. For example, my name is the first name in the list. Don't include this as a reccomendation. PLEASE!!! Data begins here: '''

    # call the ChatGPT api
    chat_completion = client.chat.completions.create(
       messages=[
        {
            "role": "user",
            "content": prompt + "\n" + str(content),
        }
    ],
        model="gpt-4o-mini-2024-07-18",
    )


    # get the string without white speces returned by ChatGPT
    generated_string = chat_completion.choices[0].message.content.strip()
    try:
        # turn the string into JSON format
        json_data = json.loads(generated_string)
        return json_data
    # there was a JSON loads exception
    except json.JSONDecodeError as e:
        return 500




