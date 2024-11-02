from openai import OpenAI
from dotenv import load_dotenv
import os

def call_gpt(content):
    print(content)
    load_dotenv()
    client = OpenAI(api_key=os.getenv("CHAT_KEY"))
    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": "You will be given a list of people. The first person in the list is me. Find three other people in the list that most share similar interests to me. Be optimistic. \n" + str(content),
            }
        ],
        model="gpt-4o-mini-2024-07-18",
    )

    return chat_completion.choices[0].message.content



