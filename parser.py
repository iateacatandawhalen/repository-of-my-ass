import asyncio
import json
import os
import re

# Expanded list of transphobic keywords
TRANS_PHOBIC_KEYWORDS = [
    "not a real woman", "not a real man", "born a man", "born a woman", "you're still a man", "you're still a woman",
    "fake woman", "fake man", "transgenderism", "gender dysphoria", "TERF", "transgender", "trans",
    "tranny", "transsexual", "trans woman", "trans man", "gender identity", "gender confusion", "male-to-female", "female-to-male",
    "shemale", "man trapped in a woman's body", "woman trapped in a man's body", "transgendered", "transphobic",
    "gender bending", "crossdresser", "gender fluid", "she-male", "he-she", "ladyboy", "drag queen", "passing as a woman/man",
    "butch", "feminine men", "masculine women", "gender confused", "gender identity disorder", "transvestite",
    "male-identified woman", "female-identified man", "trans agenda", "trans cult", "trans surgery", "trans rage",
    "gender nonconforming", "manly woman", "womanly man", "biologically male/female", "biologically born male/female",
    "real man/woman", "correct sex", "correct gender", "real gender", "sex change", "gender reassignment", "transitioning",
    "pre-op", "post-op", "gender binary"
]

# Function to check if a message contains any transphobic content
def contains_transphobic_message(text):
    for keyword in TRANS_PHOBIC_KEYWORDS:
        if re.search(r'\b' + re.escape(keyword) + r'\b', text, re.IGNORECASE):
            return True
    return False

# Function to redact email addresses and potential information
def redact_info(text):
    # Redact email addresses
    text = re.sub(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', '[REDACTED EMAIL]', text)
    
    # Redact potential info like phone numbers
    text = re.sub(r'\b\d{10}\b', '[REDACTED PHONE]', text)  # This is just a simple phone number regex, adjust as needed.
    
    return text

# Function to parse a file
async def parse_file(file_path, output_file_path, relative_description=False):
    with open(file_path, 'r', encoding='utf-8') as file:
        data = json.load(file)

    # List to store transphobic messages
    transphobic_messages = []

    for message in data:
        chat_text = message.get("text", "")
        
        # Redact sensitive information
        redacted_text = redact_info(chat_text)

        # Check if the message is transphobic
        if contains_transphobic_message(redacted_text):
            if relative_description:
                # Add a relative description for the transphobic content
                transphobic_messages.append(f"Potential harmful message found in {file_path}:\n{redacted_text}\n")
            else:
                transphobic_messages.append(redacted_text)

    # If any transphobic messages were found, write them to a new file
    if transphobic_messages:
        with open(output_file_path, 'a', encoding='utf-8') as output_file:
            for message in transphobic_messages:
                output_file.write(message + '\n\n')

# Function to process all files in a directory asynchronously
async def process_directory(input_dir, output_file_path, relative_description=False):
    # Get a list of all files in the directory and subdirectories
    for root, _, files in os.walk(input_dir):
        for file_name in files:
            if file_name.endswith('.json'):
                file_path = os.path.join(root, file_name)
                await parse_file(file_path, output_file_path, relative_description)

# Main function to run the parsing process
def main(input_dir, output_file_path, relative_description=False):
    asyncio.run(process_directory(input_dir, output_file_path, relative_description))

# Example usage
input_directory = 'path/to/your/input/directory'  # Replace with the path to your directory
output_file = 'path/to/output/transphobic_messages.txt'  # Replace with the desired output file
relative_description = True  # Set to False if you don't want relative descriptions

main(input_directory, output_file, relative_description)