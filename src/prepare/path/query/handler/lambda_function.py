import json
import os

import boto3

# class Event(TypedDict):
#     story: str
    
agent_profile ='You will be given a Story Paragraph and must mark phrases that sound like they are created by AI. \
You are only allowed to respond with a marked version of the Story Paragraph. \
You must mark phrases by enclosing each phrase in braces. \
The following text, enclosed in square brackets, includes high priority examples of phrases to be marked [$search_results$]. \
The following text, enclosed in square brackets, is the Story Paragraph for you to return marked [$query$].'

model_id = "amazon.nova-micro-v1:0"

session = boto3.Session()
bedrock = session.client('bedrock')
agent = session.client('bedrock-agent-runtime')

def handler(event, context) -> Respose:
    KB_ID = os.environ.get('KB_ID')
    response = {
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
                },
            'statusCode': 500,
            'body': 'Error on init'
        }

    marked = ''
    paragraphs = event["body"].split('\n')

    try:

        fm_res = bedrock.get_foundation_model(
            modelIdentifier=model_id
        )

        fm_arn = fm_res['modelDetails']['modelArn']

        for paragraph in paragraphs:
            if len(paragraph)<1:
                continue
            inference = agent.retrieve_and_generate(
                input={
                    'text': paragraph
                },
                retrieveAndGenerateConfiguration={
                    'type': 'KNOWLEDGE_BASE',
                    'knowledgeBaseConfiguration': {
                        'knowledgeBaseId': KB_ID,
                        'modelArn': fm_res['modelDetails']['modelArn'],
                        'retrievalConfiguration': {
                            'vectorSearchConfiguration': {
                                'numberOfResults': 5,
                                'overrideSearchType': 'SEMANTIC',
                            }
                        },
                        'generationConfiguration': {
                            'promptTemplate': {
                                'textPromptTemplate': agent_profile,
                            },
                            'inferenceConfig': {
                                'textInferenceConfig': {
                                    'temperature': 0.8,
                                    'topP': 0.1,
                                    'maxTokens': 512,
                                    'stopSequences': []
                                }
                            },
                            'performanceConfig': {
                                'latency': 'standard'
                            }
                        }
                    }
                }
            )

            marked += inference['output']['text']
            marked += '\n'

    except Exception as err:
        print(err.response)
        response["headers"]["X-Amzn-ErrorType"] = f"{type(err)}"
        response["statusCode"] = 500
        response["body"] = "KB error"
        return response

    response["statusCode"] = 200
    response["body"] = marked
    return response
