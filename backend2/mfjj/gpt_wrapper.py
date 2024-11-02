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
                "content": "Hello ChatGPT, the first person in this list is me. Then there is a list of other people and their profiles. Tell me which three of these people could be good friends with me, based on our interests. Remember that I am the first person in the list. Do not include me as a match. Always find at least one match and be optimistic. Only give up to at most 3 people to match with. Give back JSON with the at most three usernames (if no matches put None), and then put 'content' with your analysis. Begin data: \n" + str(content),
            }
        ],
        model="gpt-4o-mini-2024-07-18",
    )

    return chat_completion.choices[0].message.content



