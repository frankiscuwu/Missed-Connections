from openai import OpenAI
from dotenv import load_dotenv
import os
import json

def call_gpt(content, username):
    load_dotenv()
    client = OpenAI(api_key=os.getenv("CHAT_KEY"))

    print(content)

    prompt = '''You will be given a list of people. The first person in the list is me. Find three other people in the list that most share similar interests to me. Be optimistic. Format each person recomendation in a JSON format. This an an example of an output: ' ,   
                "Example: [{'person': 'person1', 'reason': 'Reason for person 1'}. In your JSON, dont put ```json, just put {. Similarly, don't use ``` to end, just put a curly bracket ( } ). Also, don't use single quotes, its json you need to use "". The JSON should be wrapped in curly brackets. Data begins here: '''
    chat_completion = client.chat.completions.create(
       messages=[
        {
            "role": "user",
            "content": prompt + "\n" + str(content),
        }
    ],
        model="gpt-4o-mini-2024-07-18",
    )


    generated_string = chat_completion.choices[0].message.content.strip()
    try:
        json_data = json.loads(generated_string)
        json_data["recommendations"] = [
        recommendation for recommendation in json_data["recommendations"]
        if recommendation["person"] != username
        ]
        return json.dumps(json_data, indent=4)
    except json.JSONDecodeError as e:
        return 404




