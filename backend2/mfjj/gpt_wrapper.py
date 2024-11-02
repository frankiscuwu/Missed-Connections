from openai import OpenAI
from dotenv import load_dotenv
import os

def call_gpt(content):
    load_dotenv()
    client = OpenAI(api_key=os.getenv("CHAT_KEY"))
    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": "Hello ChatGPT, the first person in this list is me. Then there is a list of other people and their profiles. Tell me which three of these people could good friends with me, based on our interests. Begin data: \n" + str(content),
            }
        ],
        model="gpt-4-1106-preview",
    )

    return chat_completion



